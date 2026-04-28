# Ointment Care Flutter MVP

軟膏使用管理アプリの Flutter / VS Code 向け MVP です。

## 実装済み

- 使用量の手動記録
- 今日、直近 7 日、週間合計のダッシュボード
- 使用履歴
- 肌状態の記録
- 達成バッジ
- 目標量とリマインダー予定の設定
- `shared_preferences` による端末内ローカル保存

## 開発

```bash
cd /Users/hirokikodama/ointment_flutter_mvp
code .
flutter run -d chrome
```

macOS アプリとして確認する場合:

```bash
flutter run -d macos
```

iPhone シミュレータで確認する場合は、先に Xcode の完全インストールが必要です。

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
flutter run -d ios
```

## 検証

```bash
flutter analyze
flutter test
flutter build web
```

## GitHub Pages

このリポジトリは GitHub Actions で Flutter Web を GitHub Pages に公開できます。

1. GitHub Desktop でこのフォルダをリポジトリとして追加
2. GitHub に publish
3. GitHub のリポジトリ画面で `Settings > Pages`
4. `Build and deployment` の `Source` を `GitHub Actions` に設定
5. `main` ブランチへ push

公開 URL は通常この形式です。

```text
https://<GitHubユーザー名>.github.io/<リポジトリ名>/
```

## 次フェーズ

- 写真保存
- Bluetooth LE デバイス連携
- 通知の実装
- 医師共有レポート
- 認証とクラウド同期
- 医療データとしてのセキュリティ、規制要件整理
