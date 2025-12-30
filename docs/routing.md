# docs/routing.md

このドキュメントは、本アプリ（Flutter + go_router）の**ルート定義**と**画面遷移**、および**戻る（Back）挙動**を仕様として固定する。

- UIは**タブUIを使わない（フロー型）**
- 起点は **Work 一覧（/works）**
- ID は Realm の `ObjectId` を URL パラメータとして扱う（`String`化して渡す）

---

## 1. ルート表（go_router）

| 画面 | Route name | Path | Params | 想定用途 |
|---|---|---|---|---|
| WorkListScreen | `works` | `/works` | - | 起点。Work一覧を表示 |
| WorkCreateScreen | `workNew` | `/works/new` | - | Work作成 |
| WorkDetailScreen | `workDetail` | `/works/:workId` | `workId` | Work詳細（Task一覧等） |
| RecordScreen | `record` | `/works/:workId/record` | `workId` | 記録（タスクタップで開始/切替/一時停止） |
| HistoryListScreen | `sessions` | `/sessions` | - | Session履歴一覧 |
| HistoryDetailScreen | `sessionDetail` | `/sessions/:sessionId` | `sessionId` | Session履歴詳細 |
| ResultScreen | `sessionResult` | `/sessions/:sessionId/result` | `sessionId` | Finish直後の結果表示 |

### パスパラメータの型
- `:workId` / `:sessionId` は **URL上は String** として保持し、Repository 層で `ObjectId.fromHexString(...)` 相当へ復元して使う。
- 変換不能な場合は「不正ID」としてハンドリング（例：エラーダイアログ or NotFound 表示）。

---

## 2. 画面遷移仕様

### 2.1 基本フロー（記録 → 保存 → 結果 → 履歴）
**主フロー:**
1. `WorkListScreen (/works)`
2. `WorkDetailScreen (/works/:workId)`
3. `RecordScreen (/works/:workId/record)`
4. `Finish` で Session 保存（Realm）
5. `ResultScreen (/sessions/:sessionId/result)`
6. 結果画面から
   - `HistoryDetailScreen (/sessions/:sessionId)` または
   - `HistoryListScreen (/sessions)`

**補助フロー:**
- `WorkListScreen (/works)` → `WorkCreateScreen (/works/new)` → 作成後は `WorkDetailScreen` へ（推奨）または `/works` へ戻る（仕様選択可）

### 2.2 履歴閲覧フロー
- `WorkListScreen (/works)` → `HistoryListScreen (/sessions)` → `HistoryDetailScreen (/sessions/:sessionId)`

---

## 3. 戻る（Back）挙動の仕様

### 3.1 原則
- **RecordScreen以外**は通常の戻る挙動（`context.pop()` / OS Back）。
- **RecordScreenのみ特別扱い**：記録が1度でも開始されていた場合、戻る時に破棄確認を行う。

### 3.2 RecordScreen の戻る挙動（破棄確認）
**条件:**
- RecordState の `startedAt != null`（= 1度でも開始している）なら、戻る操作時に確認ダイアログを表示する。

**表示文言:**
- タイトル: `記録を破棄しますか？`
- 本文例: `この記録は保存されません。戻りますか？`
- ボタン:
  - `キャンセル`（戻らない）
  - `破棄して戻る`（状態を捨てて戻る）

**破棄して戻る時の処理:**
- Record のメモリ状態を破棄（例：`recordController.reset()`）
- DB保存は行わない（Sessionは作らない）
- `pop()` で `WorkDetailScreen` に戻る（基本）

**startedAt == null の場合（未開始）:**
- 確認なしで即 `pop()`（状態破棄が必要なら同様に reset してよい）

---

## 4. 遷移APIの指針（実装ルール）

### 4.1 画面遷移の原則
- 「一覧 → 詳細 → 記録」は**push**（履歴として戻れる）
- 「Finish → Result」は **replace/pushReplacement** を推奨  
  - 目的：記録画面へ戻って二重保存などを避ける
- Result から履歴へは基本 push

### 4.2 推奨する遷移メソッド
- 一般的な画面遷移: `context.pushNamed(...)`
- 置き換え遷移（Finish後）: `context.goNamed(...)` もしくは `pushReplacement` 相当（採用方針に統一）
  - **推奨:** `goNamed`（スタックを期待どおりに整理しやすい）

---

## 5. 画面ごとの遷移詳細

### 5.1 WorkListScreen（/works）
- Workをタップ → `WorkDetailScreen`
  - `pushNamed('workDetail', pathParameters: {'workId': workIdHex})`
- 追加（+） → `WorkCreateScreen`
  - `pushNamed('workNew')`
- 履歴へ → `HistoryListScreen`
  - `pushNamed('sessions')`

### 5.2 WorkCreateScreen（/works/new）
- 作成成功後:
  - 方針A（推奨）: 作成した Work の詳細へ
    - `goNamed('workDetail', pathParameters: {'workId': createdIdHex})`
  - 方針B: 一覧へ戻す
    - `pop()` or `goNamed('works')`
- キャンセル → `pop()`

### 5.3 WorkDetailScreen（/works/:workId）
- 記録開始ボタン（または任意UI） → `RecordScreen`
  - `pushNamed('record', pathParameters: {'workId': workIdHex})`
- 戻る → `pop()`（WorkListへ）

### 5.4 RecordScreen（/works/:workId/record）
- Finish（保存成功） → `ResultScreen`
  - `goNamed('sessionResult', pathParameters: {'sessionId': savedSessionIdHex})`
- 戻る（Back）:
  - `startedAt == null` → そのまま `pop()`
  - `startedAt != null` → 破棄確認（OKなら `recordController.reset()` + `pop()`）

### 5.5 ResultScreen（/sessions/:sessionId/result）
- 「履歴詳細へ」→ `HistoryDetailScreen`
  - `goNamed('sessionDetail', pathParameters: {'sessionId': sessionIdHex})`
  - ※Resultを残したいなら `pushNamed` でも良いが、通常は結果→詳細へ遷移して戻り導線を単純化する
- 「履歴一覧へ」→ `HistoryListScreen`
  - `goNamed('sessions')`

### 5.6 HistoryListScreen（/sessions）
- 行タップ → `HistoryDetailScreen`
  - `pushNamed('sessionDetail', pathParameters: {'sessionId': sessionIdHex})`
- 戻る → `pop()`（WorkListへ）

### 5.7 HistoryDetailScreen（/sessions/:sessionId）
- 戻る → `pop()`（HistoryListへ）

---

## 6. ルーティング実装上の注意（仕様としての制約）

1. **Record中はDBへ逐次書き込みしない**
   - RecordScreen の state はメモリのみ（RiverpodのController/Notifier）
2. **FinishのみがSession永続化の入口**
   - Finish成功後は必ず `ResultScreen` へ（sessionId必須）
3. **totalMs整合性**
   - ルーティング仕様としても、Finish時は `totalMs == sum(taskTotals.durationMs)` を満たすこと（不整合禁止）
4. **Deep Linkの取り扱い（最低限）**
   - `/works/:workId/record` や `/sessions/:sessionId/result` への直接遷移が来た場合でも、IDが無効ならエラー表示（クラッシュしない）

---

## 7. go_router 構成方針（設計メモ）

- `GoRouter` は `routes.dart` 等で一元定義
- `name` を必ず付け、アプリ内部は基本 `pushNamed/goNamed` を使用
- `RecordScreen` は `PopScope`（または `WillPopScope` 相当）で戻るをフックし、仕様通りに破棄確認する
- パラメータ文字列（hex）→ `ObjectId` 変換は共通関数化する（例：`parseObjectId(String)`）

---
