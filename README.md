# garmin-color-util

Garmin vivoactive 5 の OLED 実機で色の見え方を確認するための Connect IQ アプリです。

## 仕様

- 背景色と中央正方形の色を独立して設定
- 中央正方形タップで編集対象を切り替え
	- `R` → `G` → `B` → `背景R` → `背景G` → `背景B` → 繰り返し
- 正方形の上をタップ: 選択中の値を `+20`
- 正方形の下をタップ: 選択中の値を `-20`
- 正方形の左をタップ: 選択中の値を `-1`
- 正方形の右をタップ: 選択中の値を `+1`
- 値は `0..255` にクランプ

## ビルド

Connect IQ SDK をインストールし、`monkeyc` コマンドが使える状態で実行します。

```bash
monkeyc -f monkey.jungle -d vivoactive5 -o bin/OledColorProbe.prg -y /path/to/developer_key
```

## 実行

- Connect IQ Simulator で `vivoactive5` を選択して読み込み
- または実機へ転送して動作確認