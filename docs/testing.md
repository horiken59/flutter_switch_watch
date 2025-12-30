# Testing Strategy（docs/testing.md）

本ドキュメントは、**仕様書駆動開発**の手順に従い、本アプリにおいて  
- どこを **ユニットテスト** で担保するか  
- どこを **Widgetテスト** で担保するか  
- CI で実行する **テストコマンド**  

を明確に定義する。

---

## 1. テスト方針の全体像

### 基本原則
- **ロジックは必ずユニットテストで担保**
- **画面遷移・ユーザ操作の成立はWidgetテストで担保**
- 時間計測の正確性・状態機械の正当性を最重要とする
- Realm / Timer / 現在時刻などの外部依存は **テストダブル** に置き換える

### テストレイヤ対応表

| レイヤ | テスト種別 | 主目的 |
|------|-----------|--------|
| Domain / Controller | Unit Test | 状態遷移・時間計算・不変条件 |
| Repository | Unit Test | 保存内容・整合性 |
| UI（Screen） | Widget Test | 画面遷移・操作成立 |
| ルーティング | Widget Test | go_router の遷移保証 |

---

## 2. ユニットテストで担保する範囲

### 2.1 RecordController（最重要）

#### 対象
- `recordControllerProvider`
- 内部状態 `RecordState`
- タスクタップ・Finish の振る舞い

#### テスト観点（必須）

##### 状態遷移テスト
- Idle → Running
- Running → Paused
- Paused → Running
- Running → Running（タスク切替）

##### タスクタップ仕様
- Idleでタスクをタップすると startedAt / activeTaskId が設定される
- Running中に同一タスクをタップすると Paused になる
- Running中に別タスクをタップすると累積加算後に切替される
- Paused中にタスクをタップすると再開される

##### 時間計算の正当性
- accumulatedMsByTask が正しく加算される
- Running中の表示用時間が  
  `accumulated + (now - activeTaskStartedAt)` になる
- Paused中は加算されない

##### Finish処理
- Running中なら最後の区間が加算される
- totalMs == sum(taskTotals.durationMs) が必ず成立する
- taskTotals が Work.tasks の order 順で生成される
- Paused時間が totalMs に含まれない

#### テスト技法
- `DateTime.now()` は injectable にし、固定時刻で検証
- Timer / Ticker は Fake または manual trigger

---

### 2.2 duration フォーマット関数

#### 対象
- `formatDuration(ms) -> hh:mm:ss`

#### テスト観点
- 0 ms → `00:00:00`
- 999 ms → `00:00:00`
- 1000 ms → `00:00:01`
- 3661000 ms → `01:01:01`
- 桁あふれ・マイナス値が発生しない

---

### 2.3 Repository 層

#### 対象
- `WorkRepository`
- `SessionRepository`

#### テスト観点
- Work 作成時のバリデーション
  - Work名必須
  - Task 1件以上必須
  - Task名重複禁止（trim後）
- Session 保存時
  - workNameSnapshot が保存される
  - taskNameSnapshot が保存される
  - totalMs と taskTotals の整合性

#### 補足
- Realm は in-memory Realm を使用
- DB I/O の成功・失敗を明示的に検証

---

## 3. Widgetテストで担保する範囲

### 3.1 画面遷移（go_router）

#### 対象ルート
- `/works`
- `/works/new`
- `/works/:workId`
- `/works/:workId/record`
- `/sessions`
- `/sessions/:sessionId`
- `/sessions/:sessionId/result`

#### テスト観点
- 正しい画面が表示される
- 戻る操作で想定ルートに戻る
- Record → Finish → Result の遷移が成立する

---

### 3.2 記録画面 UI

#### テスト観点
- タスク行が ListView で表示される
- タスクタップで表示時間が進行する
- アクティブタスクが視覚的に識別できる
- 合計時間が各タスク総和と一致して表示される

---

### 3.3 Back 操作の確認ダイアログ

#### テスト観点
- 記録未開始 → 確認なしで戻れる
- 一度でも開始 → 確認ダイアログが表示される
- 「破棄」を選ぶと RecordState が破棄される
- 「キャンセル」で記録画面に留まる

---

## 4. テスト対象外（MVPでは担保しない）

- UI の色・アニメーション・レイアウト細部
- ミリ秒単位の表示精度
- Realm の内部実装そのもの

---

## 5. CI で実行するテストコマンド

### 基本コマンド
```bash
flutter test
