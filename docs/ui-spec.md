# docs/ui-spec.md

## 1. 目的 / スコープ
本書は、Flutter + Realm(ローカルのみ) + Riverpod + go_router で実装するMVPにおける **画面ごとのUI要件**、**タップ時挙動**、**表示形式（hh:mm:ss など）** を定義する。

対象ルート（フロー型 / タブUIなし）:
- WorkListScreen: `/works`
- WorkCreateScreen: `/works/new`
- WorkDetailScreen: `/works/:workId`
- RecordScreen: `/works/:workId/record`
- ResultScreen: `/sessions/:sessionId/result`
- HistoryListScreen: `/sessions`
- HistoryDetailScreen: `/sessions/:sessionId`

---

## 2. 共通UI仕様

### 2.1 時間表示フォーマット（必須）
- 表示形式: `hh:mm:ss`（常にゼロ埋め、2桁）
  - 例: `00:00:05`, `01:02:03`, `12:34:56`
- 内部はミリ秒（ms）で保持し、表示のみ `hh:mm:ss` に変換する。
- UI更新は **1秒ごと** でOK（内部はms精度のまま）。

#### 変換ルール（ms -> hh:mm:ss）
- `totalSeconds = floor(ms / 1000)`
- `hh = floor(totalSeconds / 3600)`
- `mm = floor((totalSeconds % 3600) / 60)`
- `ss = totalSeconds % 60`
- `hh:mm:ss` でゼロ埋めして表示する

### 2.2 ナビゲーション / AppBar
- 各画面は基本的に AppBar を持つ（MVPとして標準 `AppBar` でよい）。
- 画面遷移は go_router に従う（詳細は routing.md）。
- 「戻る」は原則 OS/アプリの標準バック（AppBar back / システム戻る）を使用。

### 2.3 入力バリデーション表示（共通）
- 入力必須/制約違反は、フィールド下のエラーテキストまたは `SnackBar` でユーザーに通知する。
- バリデーションは確定アクション（保存/作成）時に行う（入力中のリアルタイム検証は任意）。

---

## 3. 画面別UI仕様

## 3.1 WorkListScreen (`/works`)
### 目的
Workの一覧表示と、Work作成・履歴閲覧への起点となる画面。

### UI要件
- `ListView` で Work を表示する
  - 行の表示: `Work.name`
- 空状態:
  - Workが0件の場合、説明テキスト（例:「Workがありません。作成してください」）を表示
- 画面内アクション:
  - Work作成導線（例: AppBarの `+` / FAB / ボタンのいずれか）
  - 履歴一覧導線（例: AppBarのアイコン or ボタン）

### タップ挙動
- Work行タップ:
  - `WorkDetailScreen (/works/:workId)` へ遷移
- 「作成」タップ:
  - `WorkCreateScreen (/works/new)` へ遷移
- 「履歴」タップ:
  - `HistoryListScreen (/sessions)` へ遷移

---

## 3.2 WorkCreateScreen (`/works/new`)
### 目的
WorkとそのTask定義（TaskDef）を作成する。

### UI要件
- 入力フォーム（最低限）
  - Work名: `TextField`（必須）
  - Task入力: 1件以上
    - UIは以下いずれでもOK（MVP優先）
      - (A) Task名入力欄 + 追加ボタンで増やす
      - (B) 既存Taskリスト + 追加/削除
- Taskの並び順:
  - 入力順が `order = 0..` となる（UI上も入力順で表示）
- エラー表示:
  - Work名未入力: エラー
  - Task 0件: エラー
  - 同一Work内でTask名の重複は禁止（トリム後比較）
    - 例: `"切る"` と `" 切る "` は重複扱い

### アクション
- 「保存/作成」ボタン（例: AppBar action / 画面下ボタン）
- 「キャンセル」（任意。戻るで代替可）

### タップ挙動
- 「保存/作成」:
  - バリデーションOK → RealmにWork保存 → `WorkDetailScreen` へ（workIdで遷移）
  - バリデーションNG → エラー表示して遷移しない
- 戻る:
  - 変更破棄確認は任意（MVPではなしでも可）

---

## 3.3 WorkDetailScreen (`/works/:workId`)
### 目的
Workの詳細（Work名・Task一覧）を確認し、記録開始へ進む。

### UI要件
- 表示:
  - Work名
  - Task一覧（`order`順）
- アクション:
  - 「記録する」ボタン（Record開始）
  - （任意）Work編集はMVPスコープ外でもOK

### タップ挙動
- 「記録する」タップ:
  - `RecordScreen (/works/:workId/record)` へ遷移

---

## 3.4 RecordScreen (`/works/:workId/record`)
### 目的
タスク行タップで計測の開始/切替/一時停止を行い、FinishでSessionを保存する。

### レイアウト要件（必須）
記録画面は **リスト形式** で以下の見た目：

#### (1) ヘッダー行（固定）
- 左: `Work名（workNameSnapshot）`
- 右: `合計時間 (hh:mm:ss)`
  - 合計時間は「各タスクの累積時間の総和」
  - Running中は **アクティブタスクの進行分も含めて** 表示
  - Paused中は進行分を加算しない
- 表示例: `料理        00:12:34`

#### (2) タスク行（ListView）
- 各行:
  - 左: Task名
  - 右: そのタスクの表示時間 `hh:mm:ss`
- 行全体がタップ領域
- アクティブ（動作中）のタスク行は強調表示（下記いずれか）
  - 背景色の変更、太字、左インジケータ、アイコン等（実装容易な方法でOK）

#### (3) 画面下固定エリア
- `Finish` ボタン（画面下固定）
- 押下可能条件:
  - startedAt が null（完全Idle）でも押せる/押せないは実装方針で決めてよいが、
    - **推奨**: startedAt==null の場合は `Finish` を無効（または「記録が開始されていません」表示）

### 表示更新
- 1秒ごとに画面表示を更新する（Ticker/Timer）
- 内部はms保持。表示の`hh:mm:ss`は秒単位更新でOK。

### 記録状態と表示（必須）
状態: `Idle / Running / Paused`

- Idle: `startedAt == null`
  - すべてのタスク時間は `00:00:00`
  - 合計時間も `00:00:00`
- Running: `activeTaskId != null`
  - アクティブタスク行: 強調表示
  - 合計時間/該当タスク時間は「進行分」を含めて表示
- Paused: `startedAt != null && activeTaskId == null`
  - 強調表示なし（または「一時停止中」表示は任意）
  - 表示時間は累積のみ（進行分なし）

#### タスク行の表示時間（taskDisplayMs）
- `accumulated[taskId] + (taskId == activeTaskId ? (now - activeTaskStartedAt) : 0)`

#### 合計時間表示（totalDisplayMs）
- `sum(accumulated.values) + (Runningなら (now - activeTaskStartedAt) を activeTask分として加算)`
- Pausedでは加算しない

### タップ挙動（必須）
#### タスク行タップ: `onTapTask(T)`
A) Idle（`startedAt == null`）
- `startedAt = now`
- `activeTaskId = T`
- `activeTaskStartedAt = now`
- `lastActiveTaskId = T`
- 状態=Running

B) Running（`activeTaskId != null`）
- B-1) `T == activeTaskId`（動いているタスクをタップ）
  - `elapsed = now - activeTaskStartedAt`
  - `accumulated[activeTaskId] += elapsed`
  - `lastActiveTaskId = activeTaskId`
  - `activeTaskId = null`
  - `activeTaskStartedAt = null`
  - 状態=Paused
- B-2) `T != activeTaskId`（動いていないタスクをタップ）
  - `A = activeTaskId`
  - `elapsed = now - activeTaskStartedAt`
  - `accumulated[A] += elapsed`
  - `activeTaskId = T`
  - `activeTaskStartedAt = now`
  - `lastActiveTaskId = T`
  - 状態=Running（切替）

C) Paused（`startedAt != null && activeTaskId == null`）
- `activeTaskId = T`
- `activeTaskStartedAt = now`
- `lastActiveTaskId = T`
- 状態=Running（再開）

#### Finishボタン: `finish()`
- Runningなら最後の区間を加算
  - `elapsed = now - activeTaskStartedAt`
  - `accumulated[activeTaskId] += elapsed`
- `endedAt = now`
- `totalMs = sum(accumulated.values)`（Paused時間は含めない）
- `taskTotals` は `Work.tasks` の order順で生成
  - 該当タスクが未実施なら `durationMs = 0`
- SessionをRealmへ保存（記録中は逐次書き込みしない）
- `ResultScreen (/sessions/:sessionId/result)` へ遷移（保存したsessionIdを渡す）

### 戻る操作（必須）
- 記録が1度でも開始（`startedAt != null`）していたら、戻る時に確認ダイアログを表示:
  - 文言: 「記録を破棄しますか？」
  - 選択肢:
    - 「破棄して戻る」: Record状態を捨てて前画面へ（DB保存なし）
    - 「キャンセル」: 画面に留まる
- `startedAt == null` の場合は通常の戻るでOK。

---

## 3.5 ResultScreen (`/sessions/:sessionId/result`)
### 目的
直近保存したSessionの結果（合計・内訳）を提示し、履歴へ誘導する。

### UI要件
- 表示:
  - `workNameSnapshot`
  - `totalMs (hh:mm:ss)`
  - `taskTotals` 一覧（保存順=Work.tasks順）
    - 左: `taskNameSnapshot`
    - 右: `durationMs (hh:mm:ss)`
- ボタン:
  - 「履歴詳細へ」→ HistoryDetail
  - 「履歴一覧へ」→ HistoryList

### タップ挙動
- 「履歴詳細へ」:
  - `HistoryDetailScreen (/sessions/:sessionId)` へ遷移
- 「履歴一覧へ」:
  - `HistoryListScreen (/sessions)` へ遷移

---

## 3.6 HistoryListScreen (`/sessions`)
### 目的
Sessionの一覧を閲覧する。

### UI要件
- `startedAt desc` で一覧表示
- 各行の表示項目（必須）:
  - `startedAt`（見やすく整形。フォーマットは実装に委ねる）
  - `workNameSnapshot`
  - `totalMs (hh:mm:ss)`
- 空状態:
  - Sessionが0件なら「履歴がありません」等を表示

### タップ挙動
- 行タップ:
  - `HistoryDetailScreen (/sessions/:sessionId)` へ遷移

---

## 3.7 HistoryDetailScreen (`/sessions/:sessionId`)
### 目的
Sessionの詳細（合計とタスク内訳、開始/終了時刻）を表示する。

### UI要件
- 表示項目（必須）:
  - `workNameSnapshot`
  - `startedAt`
  - `endedAt`
  - `totalMs (hh:mm:ss)`
  - `taskTotals`（保存順またはWork.tasks順。MVPは保存順=Work.tasks順）
    - 左: `taskNameSnapshot`
    - 右: `durationMs (hh:mm:ss)`

### タップ挙動
- 追加操作は不要（戻るでOK）

---

## 4. UIの整合性制約（必須）
- `totalMs` は常に `taskTotals.durationMs` の総和と一致させる（不整合禁止）
- 記録中（RecordState）はRealmへ逐次保存しない
  - Finish時のみ `Session` を保存する
- 表示時間は `hh:mm:ss`、更新は1秒ごとでOK（内部ms保持）

---

## 5. MVP実装メモ（UI観点）
- アクティブ行の強調は「背景色変更 or 左の細いバー」など、実装が軽い方法で良い。
- 記録画面のヘッダー行は `ListView` の外に置き、`Column + Expanded(ListView) + BottomButton` の構成を推奨。
- Finishボタンは `SafeArea` 内で画面下固定にする（ナビゲーションバー被り防止）。
