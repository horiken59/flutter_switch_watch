# Data Model (Realm) - SwitchWatch MVP

本書は、SwitchWatch（Work/Task の計測 → Finish で Session 保存 → 履歴閲覧）の **Realm スキーマ / ID方針 / 関係 / 制約（整合性）** を定義する。
実装は Flutter + Realm（ローカルのみ / 同期なし）を前提とする。

---

## 1. 方針（重要）

- **記録中はDBへ逐次書き込みしない**  
  記録状態（RecordState）はメモリで保持し、**Finish 時のみ Session をRealmへ保存**する。

- **履歴はスナップショット**  
  Work名やTask名を後から変更しても、保存済みSessionの表示が壊れないように  
  Sessionには `workNameSnapshot` / `taskNameSnapshot` を保存する。

- **整合性の最重要ルール**  
  `Session.totalMs` は常に `taskTotals.durationMs` の総和と一致していなければならない（不整合禁止）。

---

## 2. エンティティ一覧

- Work（計測対象のまとまり）
- TaskDef（Workに属するタスク定義）
- Session（1回分の計測結果）
- SessionTaskTotal（Session内のタスク別累積）

---

## 3. ID方針（ObjectId）

### 3.1 主キー
- **Work._id**：`ObjectId`（primary key）
- **Session._id**：`ObjectId`（primary key）

### 3.2 埋め込み要素のID
- TaskDef / SessionTaskTotal は **親ドキュメントに埋め込む（Embedded）** ことを想定する。  
  Embedded は primary key を持てないため、識別用に以下を持たせる：
  - `TaskDef.taskId: ObjectId`（Work内で一意）
  - `SessionTaskTotal.taskId: ObjectId`（Work時点のTaskDef.taskIdをコピー）

> 生成方法：`ObjectId()` をアプリ側で生成してフィールドにセットする（UUIDは不要）。

---

## 4. 関係（リレーション）

Realmの参照リンク（to-one/to-many）ではなく、**ID参照 + スナップショット** を基本にする。

- Work 1 —— * TaskDef（**Work.tasks に埋め込み**）
- Session 1 —— * SessionTaskTotal（**Session.taskTotals に埋め込み**）

Session は Work をリンクで参照しない（FK無し）：
- `Session.workId` は Work._id のコピー（参照用）
- `Session.workNameSnapshot` は Work.name のコピー（表示用・不変）

---

## 5. Realm スキーマ（提案）

### 5.1 Work（RealmObject）
| field | type | required | notes |
|---|---:|:---:|---|
| `_id` | ObjectId | ✅ | primary key |
| `name` | String | ✅ | Work名 |
| `tasks` | List<TaskDef> | ✅ | order順、1件以上 |
| `createdAt` | DateTime | ✅ | |
| `updatedAt` | DateTime | ✅ | |

### 5.2 TaskDef（EmbeddedObject）
| field | type | required | notes |
|---|---:|:---:|---|
| `taskId` | ObjectId | ✅ | Work内で一意 |
| `name` | String | ✅ | トリム後比較で重複禁止 |
| `order` | int | ✅ | 0..（入力順） |

### 5.3 Session（RealmObject）
| field | type | required | notes |
|---|---:|:---:|---|
| `_id` | ObjectId | ✅ | primary key |
| `workId` | ObjectId | ✅ | Work._id のコピー |
| `workNameSnapshot` | String | ✅ | 保存時点の Work名 |
| `startedAt` | DateTime | ✅ | 計測開始 |
| `endedAt` | DateTime | ✅ | Finish時刻 |
| `totalMs` | int | ✅ | taskTotals の総和と一致必須 |
| `taskTotals` | List<SessionTaskTotal> | ✅ | Work.tasks の order順で生成（0埋め） |

### 5.4 SessionTaskTotal（EmbeddedObject）
| field | type | required | notes |
|---|---:|:---:|---|
| `taskId` | ObjectId | ✅ | TaskDef.taskId のコピー |
| `taskNameSnapshot` | String | ✅ | 保存時点の Task名 |
| `durationMs` | int | ✅ | 0以上 |
| `order` | int | ✅ | 表示順固定用（Work.tasksのorderをコピー） |

> `order` は必須ではないが、将来の並び替えや仕様変更に強くするために保持を推奨。

---

## 6. 制約（バリデーション / 整合性）

### 6.1 Work 作成・更新時の制約
- `Work.name`：必須、`trim()` 後に空文字禁止
- `Work.tasks`：1件以上必須
- 同一Work内で `TaskDef.name` の重複禁止  
  - 比較キー：`trim()` 後の文字列
- `TaskDef.order`：入力順で `0..n-1` の連番（重複・欠番禁止）
- `TaskDef.taskId`：Work内で一意（重複禁止）

### 6.2 Session 保存時（Finish）の制約
- `startedAt` は null 不可、`endedAt` は null 不可
- `startedAt < endedAt`（同一は原則不可）
- `durationMs`：全て `>= 0`
- `taskTotals` は **Work.tasks（order順）のスナップショット**として生成する  
  - Workに存在するタスクは必ず1件ずつ作る（未計測は 0）
  - order順を保持する
- **整合性（最重要）**  
  - `totalMs == sum(taskTotals.durationMs)` を必ず満たすこと  
  - 保存直前に必ず再計算して格納する（信頼できる唯一のソースを sum に統一）

### 6.3 削除と参照整合性
- Work を削除しても、Session は残ってよい（スナップショットのため）。
- `Session.workId` は参照用に残るが、Workが消えていても表示は `workNameSnapshot` を使う。

---

## 7. インデックス / クエリ最適化（推奨）

- `Session.startedAt`：履歴一覧で `startedAt desc` を多用するため index 推奨
- `Session.workId`：将来「Work別履歴」を出すなら index 推奨

（Realm Dart の index 指定はアノテーションで行う）

---

## 8. マイグレーション指針（最低限）

- **スキーマ追加は後方互換**を基本（nullable追加、デフォルト付与）。
- `order` を後から追加する場合：
  - 既存 `taskTotals` は配列順を `order` にコピーして埋める。
- 破壊的変更（フィールド名変更/型変更）は避け、必要なら新フィールド追加 + 移行 + 旧フィールド廃止の手順を踏む。

---

## 9. 実装メモ（モデル設計の理由）

- TaskDef / SessionTaskTotal を Embedded にすることで、
  - Work と Session が自己完結し、読み取りが速い
  - 「スナップショット保持」と整合する
  - 記録中の状態はDBに載せない方針と矛盾しない

- “参照リンク”を使わないことで、
  - Work名/Task名変更や削除が履歴表示に影響しない
  - 外部キー整合性の破綻に悩まされにくい

---
