# docs/architecture.md

## 1. 全体方針（このアプリの設計ルール）
- **Flutter + Realm(ローカルのみ) + Riverpod + go_router** で構成する。
- **記録中はDBへ逐次書き込みしない**。Record画面の状態は **メモリ上の状態（RecordState）** として保持し、**Finish時にのみ Session をRealmへ保存**する。
- 履歴は **スナップショット方針**：Work名/Task名は Session 側に snapshot を保存し、後からWork/Taskを編集しても履歴表示が壊れないようにする。
- `totalMs` は **常に** `taskTotals.durationMs` の総和と一致させる（不整合禁止）。
- UIの時間表示は `hh:mm:ss`。内部は ms（int）で保持し、UI更新は **1秒ごと**で良い。

---

## 2. レイヤ構造（Layered Architecture）
本プロジェクトは「UI → Application(State) → Domain(モデル/ルール) → Data(永続化)」の4層で整理する。

### 2.1 Layers
#### UI層（Presentation）
- 画面（Screen / Widget）
- ユーザー操作を受けて、RiverpodのProvider/Controllerを呼ぶ
- UIは状態を表示するだけ（ロジックはControllerへ寄せる）

#### Application層（State / Controller）
- Riverpodの `Notifier` / `AsyncNotifier` / `Provider` で状態を管理
- 記録ロジック（状態機械 Idle/Running/Paused）を **RecordController** に集約
- Repositoryを呼び出して永続化（Finish時のみ）

#### Domain層（Model / Rules）
- Realmモデル（Work / TaskDef / Session / SessionTaskTotal）
- バリデーションや不変条件（例：Task名重複禁止、totalMs整合）を関数としてまとめる
- 「時間計算」「表示用ms計算」「合計ms」などの純粋関数を配置

#### Data層（Persistence / Repository）
- Realm初期化、スキーマ登録
- RealmのCRUDをRepositoryに隠蔽
- UI/ApplicationはRealm APIを直接触らない（Repository越し）

---

## 3. 依存方向（Dependency Rule）
依存は **外側 → 内側** のみ許可する。

- UI → Application → Domain → Data
- UI → Domain（表示整形などの純粋関数参照）は可（ただし原則はApplication経由が望ましい）
- Application → Data（Repository経由）は可
- Data → Application/UI への依存は禁止
- 画面（UI）は Repository を直接参照しない（Provider経由）

### 3.1 依存の具体例（Provider単位）
- `WorkListScreen` → `worksStreamProvider` → `WorkRepository` → `Realm`
- `RecordScreen` → `recordControllerProvider` → (Finish時) `SessionRepository` → `Realm`
- `HistoryListScreen` → `sessionsStreamProvider` → `SessionRepository` → `Realm`

---

## 4. 状態管理（Riverpod設計）
### 4.1 Provider一覧（必須）
- `realmProvider`
  - Realmインスタンスを提供（スキーマ設定済み）
- `workRepositoryProvider`
  - `WorkRepository` を提供（依存：Realm）
- `sessionRepositoryProvider`
  - `SessionRepository` を提供（依存：Realm）
- `worksStreamProvider`
  - Work一覧を stream で提供（一覧画面用）
- `sessionsStreamProvider`
  - Session一覧を startedAt desc で stream 提供（履歴一覧用）
- `recordControllerProvider`
  - 記録状態と記録ロジック（状態機械）を提供

> 注：Record中はDB書き込みをしないため、RecordControllerは基本的に「メモリ状態」を保持し、Finish時のみSessionRepositoryへ保存する。

### 4.2 RecordState（メモリ上の状態）
記録画面の状態は次の値を保持する（Domain/Applicationの境界は実装都合で調整可）:

- `workId: ObjectId`
- `workNameSnapshot: String`
- `taskDefs: List<TaskDef>`（order順）
- `startedAt: DateTime?`（nullならIdle）
- `activeTaskId: ObjectId?`（nullならPausedまたはIdle）
- `activeTaskStartedAt: DateTime?`
- `lastActiveTaskId: ObjectId?`（Paused時の最後のタスク）
- `accumulatedMsByTask: Map<ObjectId, int>`（確定済み累積）
- `ticker: Timer?`（UI更新のため。Stateに直接持たずController内部で管理しても良い）

### 4.3 状態機械（Idle / Running / Paused）
- **Idle**
  - `startedAt == null`
- **Running**
  - `startedAt != null && activeTaskId != null`
- **Paused**
  - `startedAt != null && activeTaskId == null`

#### 表示用計算（UIで使う値）
- 合計時間（表示用）:
  - `totalDisplayMs = sum(accumulated.values) + (Runningなら now - activeTaskStartedAt を activeTask 分に加算)`
- タスク行の表示時間:
  - `taskDisplayMs(taskId) = accumulated[taskId] + (taskId==activeTaskId ? now-activeTaskStartedAt : 0)`

---

## 5. 主要クラス/責務（Key Components）
### 5.1 Router（go_router）
**責務**
- 画面遷移の定義とURL設計を一元化
- ルート:
  - `/works` WorkListScreen
  - `/works/new` WorkCreateScreen
  - `/works/:workId` WorkDetailScreen
  - `/works/:workId/record` RecordScreen
  - `/sessions` HistoryListScreen
  - `/sessions/:sessionId` HistoryDetailScreen
  - `/sessions/:sessionId/result` ResultScreen（要件では Result は `/sessions/:sessionId/result`）

**注意**
- RecordScreenの「戻る」はガードが必要：
  - 記録を1度でも開始していたら確認ダイアログ「記録を破棄しますか？」
  - 破棄ならRecordStateを捨てて戻る（DB保存なし）

---

### 5.2 Realmモデル（Domain/Data境界）
#### Work
- `_id: ObjectId (primary key)`
- `name: String`
- `tasks: RealmList<TaskDef>`
- `createdAt: DateTime`
- `updatedAt: DateTime`

#### TaskDef
- `_id: ObjectId`
- `name: String`
- `order: int`

#### Session（履歴スナップショット）
- `_id: ObjectId (primary key)`
- `workId: ObjectId`
- `workNameSnapshot: String`
- `startedAt: DateTime`
- `endedAt: DateTime`
- `totalMs: int`（必ず taskTotals の総和）
- `taskTotals: RealmList<SessionTaskTotal>`

#### SessionTaskTotal
- `taskId: ObjectId`
- `taskNameSnapshot: String`
- `durationMs: int`

---

### 5.3 Repository
#### WorkRepository
**責務**
- WorkのCRUD
- Work作成バリデーション（Work名必須、Task1件以上、Task名重複禁止、order=入力順）
- Work一覧取得（Streamで供給）

**代表API例**
- `Stream<List<Work>> watchWorks()`
- `Future<ObjectId> createWork({required String name, required List<String> taskNames})`
- `Future<Work?> getWork(ObjectId id)`
- （MVPでは編集/削除は後回しでも良い）

#### SessionRepository
**責務**
- Sessionの保存（Finish時のみ）
- Session一覧取得（startedAt desc）
- Session詳細取得（Result/HistoryDetail用）

**代表API例**
- `Stream<List<Session>> watchSessions()`
- `Future<ObjectId> saveSession(Session session)`
- `Future<Session?> getSession(ObjectId id)`

---

### 5.4 RecordController（最重要）
**責務**
- RecordStateの生成・保持・破棄
- タスクタップによる状態遷移（Idle/Running/Paused）
- 1秒TickerによるUI更新（「表示用now」を進める）
- Finish時のSession生成と保存
- 戻る操作時の「破棄確認」が必要かどうかの判定

**公開メソッド例**
- `void start(ObjectId workId)` または `Future<void> loadWorkForRecord(ObjectId workId)`
- `void onTapTask(ObjectId taskId)`
- `Future<ObjectId> finish()`（Session保存→sessionId返却）
- `void discard()`（RecordState破棄）
- `bool get hasStartedOnce`（startedAt != null で判定）

**Finishの不変条件**
- Runningなら最後の区間を必ず `accumulated` に加算
- `totalMs = sum(accumulated.values)`
- `taskTotals` は Work.tasks の order順で生成（存在しない/未実施は0）
- `totalMs == sum(taskTotals.durationMs)` を必ず満たす

---

## 6. 画面ごとの責務（UI）
### WorkListScreen（/works）
- Work一覧表示（`worksStreamProvider`）
- Work作成へ遷移
- WorkDetailへ遷移
- HistoryListへ遷移（フロー型UIだが一覧起点から履歴へ行ける）

### WorkCreateScreen（/works/new）
- Work名、Task入力
- バリデーションエラー表示
- 作成成功でWorkDetailへ

### WorkDetailScreen（/works/:workId）
- Work名とTask一覧表示
- Record開始（RecordScreenへ）

### RecordScreen（/works/:workId/record）
- `recordControllerProvider` の状態を表示
- タスク行タップで開始/切替/一時停止
- Finishで保存→Resultへ
- 戻る時の破棄確認（開始済みなら必須）

### ResultScreen（/sessions/:sessionId/result）
- 保存したSessionを読み、合計と内訳を表示
- 「履歴詳細へ」「履歴一覧へ」ボタン

### HistoryListScreen（/sessions）
- Session一覧（startedAt desc）
- 行をタップしてHistoryDetailへ

### HistoryDetailScreen（/sessions/:sessionId）
- workNameSnapshot, startedAt, endedAt, totalMs
- taskTotals内訳表示（保存順＝Work.tasks順でOK）

---

## 7. 例外・エラーハンドリング方針
- バリデーション（Work作成）はUIで即時表示しつつ、最終的にRepositoryでも防御する（二重化）
- Realm例外はRepositoryで捕捉し、UIへは「保存に失敗しました」等のメッセージへ変換
- Record中の破棄は「未保存である」ことが前提なので、discardは必ず安全に実行可能にする

---

## 8. ディレクトリ配置（例）
※あくまで例。`lib/` 配下で責務が見えることを優先する。

- `lib/app/router.dart`（go_router定義）
- `lib/app/providers.dart`（realmProvider / repositoryProvider / streamProvider集約）
- `lib/domain/models/`（Realmモデル定義 ※@RealmModel）
- `lib/domain/validation/`（Work作成バリデーションなど純粋関数）
- `lib/domain/time/format_duration.dart`（ms→hh:mm:ss）
- `lib/data/realm/realm_config.dart`（Realm初期化・スキーマ）
- `lib/data/repositories/work_repository.dart`
- `lib/data/repositories/session_repository.dart`
- `lib/application/record/record_state.dart`
- `lib/application/record/record_controller.dart`
- `lib/ui/screens/works/`（WorkList, WorkCreate, WorkDetail）
- `lib/ui/screens/record/record_screen.dart`
- `lib/ui/screens/sessions/`（HistoryList, HistoryDetail, Result）

---

## 9. テスト観点（アーキ観点の最小）
- RecordControllerの状態機械（Idle/Running/Paused）はユニットテスト対象：
  - タップ操作ごとの `accumulatedMsByTask` の更新
  - `totalMs` と `taskTotals` の整合
  - Running→Finish時に最後の区間が加算されること
- Repositoryは最低限「作成/取得/一覧」が動くかをテスト（Realmをテスト用設定で起動）

---
