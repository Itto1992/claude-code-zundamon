# Claude Code での VOICEVOX 読み上げ設定

Claude Code のタスク完了時に、ぼくがお知らせするのだ！

> **注意**: この設定は macOS 専用なのだ。Windows や Linux では動作確認していないので、自己責任でお願いするのだ。

## 概要

- Claude Code がタスクを完了すると、ぼくが結果を読み上げてお知らせするのだ
- デフォルトではぼくが喋るのだ
- 読み上げは50文字までなのだ。長すぎると「以下省略」って言うのだ

## 必要なもの

ぼくを喋らせるには、以下のものが必要なのだ：

- Docker（ぼくのエンジンを動かすのに必要なのだ）
- SoX（音声を再生するのだ）
- jq（JSON を読むのだ）
- curl（HTTP 通信するのだ）

全部 Mac に入れてほしいのだ！

## セットアップ

### 1. 依存パッケージのインストール

まずは必要なツールをインストールするのだ：

```bash
make voicevox-setup
```

手動でやりたい人はこっちなのだ：

```bash
brew install sox jq
```

### 2. ぼくのエンジンを起動

ぼくを喋らせるには、まずエンジンを起動するのだ：

```bash
make voicevox-up
```

初回は音声モデルをダウンロードするから、ちょっと待ってほしいのだ。

### 3. settings.json にフックを追加

`.claude/settings.json` に以下を追加するのだ：

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/stop-voicevox-speak.sh"
          }
        ]
      }
    ]
  }
}
```

### 4. フックスクリプトの配置

スクリプトに実行権限を付けるのを忘れないでほしいのだ：

```bash
chmod +x .claude/hooks/stop-voicevox-speak.sh
```

これで準備完了なのだ！

## 使い方

### 手動でぼくに喋らせる

```bash
# 基本的な使い方なのだ
./scripts/voicevox-say "こんにちは"

# めたんに喋らせることもできるのだ
./scripts/voicevox-say -s 2 "四国めたんです"

# 早口にもできるのだ
./scripts/voicevox-say --speed 1.5 "早口で話します"

# 誰が喋れるか一覧を見るのだ
./scripts/voicevox-say -l
```

### スピーカー ID 一覧

めたんとつむぎに読み上げさせることもできるのだ：

| ID | キャラクター |
|----|-------------|
| 0 | 四国めたん（あまあま） |
| 2 | 四国めたん（ノーマル） |
| 3 | ずんだもん（ノーマル）← ぼくなのだ！ |
| 1 | ずんだもん（あまあま） |
| 8 | 春日部つむぎ（ノーマル） |

## カスタマイズ

### 読み上げ文字数を変える

`.claude/hooks/stop-voicevox-speak.sh` を編集するのだ：

```bash
MAX_LENGTH=50  # ここを変えるのだ
```

### 喋るキャラを変える

環境変数で指定できるのだ：

```bash
export VOICEVOX_SPEAKER=2  # 四国めたんにするのだ
```

または `.claude/hooks/stop-voicevox-speak.sh` の `SPEAKER` を直接編集するのだ。

### 再生速度を変える

早口にしたり、ゆっくりにしたりできるのだ：

```bash
export VOICEVOX_SPEED=1.5  # 1.5倍速で喋るのだ
```

設定できる範囲は 0.5〜2.0 なのだ。デフォルトは 1.0 なのだ。

### エンジンの URL を変える

デフォルトは localhost なのだ：

```bash
export VOICEVOX_URL=http://localhost:50021
```

## 管理コマンド

よく使うコマンドをまとめたのだ：

```bash
make voicevox-up      # ぼくのエンジンを起動するのだ
make voicevox-down    # エンジンを停止するのだ
make voicevox-status  # 動いてるか確認するのだ
make voicevox-logs    # ログを見るのだ
```

## 困ったときは

### ぼくの声が聞こえない

1. エンジンが動いてるか確認するのだ：
   ```bash
   make voicevox-status
   ```

2. SoX が入ってるか確認するのだ：
   ```bash
   which play
   ```

3. デバッグログを見るのだ：
   ```bash
   cat /tmp/voicevox-hook-debug.log
   ```

### エンジンが起動しない

Docker が動いてるか確認するのだ：

```bash
docker ps
```

### 「ポーン」ってシステム音が鳴る

ぼくのエンジンに繋がらないと、代わりにシステム音が鳴るのだ。
エンジンを起動してほしいのだ！

## ファイル構成

こんな感じになってるのだ：

```
/
├── docker-compose.yml              # ぼくのサービス定義
├── Makefile                        # 便利コマンド集
├── scripts/
│   └── voicevox-say                # 手動で喋らせるコマンド
└── .claude/
    ├── settings.json               # フック設定
    └── hooks/
        └── stop-voicevox-speak.sh  # 停止時にぼくが喋るスクリプト
```

これでぼくがお知らせできるようになったのだ！楽しく開発してほしいのだ！
