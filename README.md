# Flutter Switch Watch（仮）

Work（作業）とその中の Task（工程）ごとに時間を計測し、  
1回分の記録を **Session** として保存・履歴閲覧できる Flutter アプリ（MVP）です。

タブUIは使わず、一覧 → 詳細 → 記録 → 結果 → 履歴、という **フロー型UI** を採用しています。

---

## アプリ概要

- Work（例：料理）を作成
- Work 内に複数の Task（例：切る / 煮る / 盛り付け）を定義
- 記録画面で **タスク行をタップ** して、開始 / 切替 / 一時停止を制御
- Finish で **1回分の記録（Session）を保存**
- 保存した履歴は一覧・詳細で閲覧可能
- 合計時間は「**各タスクの累積時間の総和**」
  - 一時停止中の時間は含めない

---

## 技術スタック

- **Flutter**
- **DB**: Realm（ローカルのみ、同期なし）
- **状態管理**: flutter_riverpod
- **ルーティング**: go_router
- **ID**: Realm ObjectId（UUID必須ではない）
- **時間表示**: `hh:mm:ss`
- **UI更新**: 1秒ごと（Timer / Ticker）
- 記録中は **DBへ逐次書き込みしない**
  - メモリ上で保持し、Finish 時にのみ Session を保存

---

## 画面構成とルーティング

### 画面一覧

| Screen | Path |
|------|------|
| WorkListScreen | `/works` |
| WorkCreateScreen | `/works/new` |
| WorkDetailScreen | `/works/:workId` |
| RecordScreen | `/works/:workId/record` |
| ResultScreen | `/sessions/:sessionId/result` |
| HistoryListScreen | `/sessions` |
| HistoryDetailScreen | `/sessions/:sessionId` |

### 画面遷移フロー

WorkList
└─ WorkDetail
└─ Record
└─ Finish
└─ Result
├─ HistoryDetail
└─ HistoryList

WorkList
└─ HistoryList
└─ HistoryDetail


### 記録画面の戻る操作

- 記録が一度でも開始されている場合：
  - 「記録を破棄しますか？」確認ダイアログを表示
- 破棄を選択した場合：
  - 記録状態を破棄し、DBには保存せず戻る

---

## 記録画面 UI 仕様

### ヘッダー

- 左：Work名
- 右：合計時間（Running 中は進行中のタスク分も含む）

例：料理 00:12:34


### タスク行（ListView）

- 左：タスク名
- 右：そのタスクの累積時間（必要に応じて進行分を加算）
- 行全体がタップ領域
- アクティブ（動作中）のタスクは強調表示

### 下部

- Finish ボタン（画面下固定）

---

## データモデル（Realm / スナップショット方針）

履歴は **スナップショット保存** します。  
後から Work 名や Task 名を変更しても、過去の履歴表示は壊れません。

### Work

- `_id`: ObjectId（primary key）
- `name`: String
- `tasks`: List<TaskDef>
- `createdAt`: DateTime
- `updatedAt`: DateTime

### TaskDef

- `_id`: ObjectId
- `name`: String
- `order`: int

### Session

- `_id`: ObjectId（primary key）
- `workId`: ObjectId
- `workNameSnapshot`: String
- `startedAt`: DateTime
- `endedAt`: DateTime
- `totalMs`: int  
  - ※必ず taskTotals.durationMs の総和と一致
- `taskTotals`: List<SessionTaskTotal>

### SessionTaskTotal

- `taskId`: ObjectId
- `taskNameSnapshot`: String
- `durationMs`: int

---

## Work 作成時のバリデーション

- Work 名：必須
- Task：1件以上必須
- 同一 Work 内で Task 名の重複禁止
  - トリム後の文字列で比較
- `order` は入力順（0,1,2,...）

---

## 記録ロジック（状態機械・要点）

状態は以下の3つ：

- **Idle**
- **Running**
- **Paused**

- 記録状態はすべて **メモリ上で管理**
- DB への保存は Finish 時のみ
- 合計時間 = 各タスクの累積時間の総和
- Running 中は、表示上のみ進行中タスクの時間を加算

※ 詳細な状態遷移・ロジックは `docs/architecture.md` に記載します。

---

## 履歴表示

### HistoryList

- Session を `startedAt desc` で一覧表示
- 表示項目：
  - 開始時刻
  - Work名（スナップショット）
  - 合計時間（hh:mm:ss）

### HistoryDetail

- Work名（スナップショット）
- startedAt / endedAt
- totalMs
- タスク別内訳（保存順）

### ResultScreen

- 今回保存した Session を表示
- ボタン：
  - 履歴詳細へ
  - 履歴一覧へ

---

## 実装上の注意

- 記録中の状態は **DBに保存しない**
- `totalMs` は常に taskTotals の合計と一致させる
- UI 更新は 1 秒ごとで問題ない
- 内部ではミリ秒精度で保持する

---

## 開発の進め方

- Flutter プロジェクト作成後、`lib/` 配下に必要なファイルを配置
- Realm モデル定義後、`build_runner` でコード生成
- 起動時は `/works` が表示され、
  - Work 作成 → 記録 → 保存 → 履歴閲覧
  が一通り動作することを MVP のゴールとします

---

## 関連ドキュメント

- アーキテクチャ: `docs/architecture.md`
- テスト方針: `docs/testing.md`
- 開発ルール: `CONTRIBUTING.md`
