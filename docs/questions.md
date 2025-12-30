# 未決事項・検討中事項（Questions）

本ドキュメントは、仕様書駆動開発における **未決事項・判断保留事項の集約場所** である。  
内容が確定次第、適切な仕様書（requirements / ui-spec / architecture / data-model 等）へ反映し、
本ファイルからは削除する。

---

## 1. Work / Task 定義に関する未決事項

### Q1. Work名・Task名の最大文字数制限は設けるか？
- 現状: 明示的な制限なし
- 検討点:
  - UI崩れ防止のための上限（例: 30文字 / 50文字）
  - Realm保存上の制約は特に不要
- 反映先（決定後）:
  - docs/requirements.md
  - docs/ui-spec.md

---

### Q2. Taskの並び替え（order変更）はMVPで対応するか？
- 現状:
  - orderは「Work作成時の入力順」で固定
- 検討点:
  - MVPでは並び替え不要とするか
  - 将来的な編集画面追加を前提にするか
- 反映先:
  - docs/requirements.md
  - docs/ui-spec.md

---

## 2. 記録ロジック・挙動に関する未決事項

### Q3. 記録中にアプリがバックグラウンドに回った場合の扱い
- 現状:
  - 明示的な仕様なし
- 検討点:
  - バックグラウンド移行時に自動Pauseするか
  - OS任せでTimerが止まる前提でよいか
- 反映先:
  - docs/architecture.md
  - docs/requirements.md

---

### Q4. 画面ロック・スリープ時の記録継続可否
- 現状:
  - 想定未定義
- 検討点:
  - MVPでは「画面ON中のみ正確」と割り切るか
  - 将来対応（keepAlive / background task）を考慮するか
- 反映先:
  - docs/requirements.md
  - docs/architecture.md

---

## 3. UI / UX に関する未決事項

### Q5. アクティブタスクの強調表示方法
- 現状:
  - 「背景色 / 太字 / 左インジケータ等で可視化」とだけ定義
- 検討点:
  - 背景色のみで統一するか
  - 複数表現を組み合わせるか
- 反映先:
  - docs/ui-spec.md

---

### Q6. Finishボタンの有効/無効条件
- 現状:
  - 常に表示される想定
- 検討点:
  - 一度も記録していない場合は無効化するか
  - Idle状態でのFinish押下を許可するか
- 反映先:
  - docs/ui-spec.md
  - docs/requirements.md

---

## 4. 履歴・データ保持に関する未決事項

### Q7. Sessionの削除機能はMVPで実装するか？
- 現状:
  - 閲覧のみ想定
- 検討点:
  - MVPでは削除不可で割り切るか
  - HistoryDetailに削除ボタンを置くか
- 反映先:
  - docs/requirements.md
  - docs/ui-spec.md

---

### Q8. 履歴表示における並び順・グルーピング
- 現状:
  - startedAt desc の単純リスト
- 検討点:
  - 日付ごとのグループ表示を将来対応とするか
- 反映先:
  - docs/ui-spec.md

---

## 5. 技術・実装方針に関する未決事項

### Q9. RiverpodのProvider粒度
- 現状:
  - RecordControllerは1つのProviderとして設計
- 検討点:
  - 状態とロジックを分離するか
  - MVPでは単一Controllerで十分か
- 反映先:
  - docs/architecture.md

---

### Q10. テスト範囲（MVP）
- 現状:
  - 明示的なテスト方針は未定義
- 検討点:
  - RecordControllerの状態遷移のみテスト対象にするか
  - UIテストはMVP外とするか
- 反映先:
  - docs/testing.md

---

## 6. 本ドキュメント運用ルール

- 本ファイルは **「決まっていないことだけを書く」**
- 決定事項は必ず以下へ転記する:
  - 要件 → docs/requirements.md
  - UI → docs/ui-spec.md
  - 設計 → docs/architecture.md / docs/data-model.md
- 決定後、このファイルから該当項目を削除する

