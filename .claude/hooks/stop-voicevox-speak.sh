#!/bin/bash
#
# エージェント停止時に VOICEVOX で出力を読み上げる
#

set -euo pipefail

URL="${VOICEVOX_URL:-http://localhost:50021}"
SPEAKER="${VOICEVOX_SPEAKER:-3}"  # ずんだもん（ノーマル）
SPEED="${VOICEVOX_SPEED:-1.0}"    # 再生速度（0.5〜2.0）
MAX_LENGTH=50
DEBUG="/tmp/voicevox-hook-debug.log"

# VOICEVOX が起動しているか確認
if ! curl -s --max-time 1 "${URL}/version" > /dev/null 2>&1; then
    echo "VOICEVOX not running" >> "$DEBUG"
    afplay /System/Library/Sounds/Hero.aiff &
    exit 0
fi

# 標準入力から transcript_path を取得
input=$(cat)
echo "input: $input" >> "$DEBUG"
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
echo "transcript_path: $transcript_path" >> "$DEBUG"

if [[ -z "$transcript_path" || ! -f "$transcript_path" ]]; then
    echo "transcript not found" >> "$DEBUG"
    afplay /System/Library/Sounds/Hero.aiff &
    exit 0
fi

# transcript への書き込み完了を待つ
sleep 0.3

# transcript から直近の assistant テキストを抽出（user メッセージは除外）
response=$(tail -r "$transcript_path" 2>/dev/null | \
    grep -E '^\{.*"role":"assistant"' | head -1 | \
    jq -r '[.message.content[]? | select(.type == "text")] | .[0].text // empty' 2>/dev/null || true)

echo "response length: ${#response}" >> "$DEBUG"
echo "response: ${response:0:100}" >> "$DEBUG"

if [[ -z "$response" ]]; then
    echo "response empty" >> "$DEBUG"
    afplay /System/Library/Sounds/Hero.aiff &
    exit 0
fi

# Markdown 記号を除去して読みやすくする
text=$(echo "$response" | \
    sed 's/```[^`]*```//g' | sed 's/`[^`]*`//g' | \
    sed 's/\*\*\([^*]*\)\*\*/\1/g' | sed 's/\*\([^*]*\)\*/\1/g' | \
    sed 's/^#\+ //g' | sed 's/^- //g' | sed 's/^[0-9]\+\. //g' | \
    tr '\n' ' ' | sed 's/  */ /g')

# 長すぎる場合は切り詰め
[[ ${#text} -gt $MAX_LENGTH ]] && text="${text:0:$MAX_LENGTH}...以下省略"

# 空の場合はスキップ
if [[ -z "$text" || "$text" == " " ]]; then
    afplay /System/Library/Sounds/Hero.aiff &
    exit 0
fi

# VOICEVOX で読み上げ
(curl -s -X POST "${URL}/audio_query?speaker=${SPEAKER}" \
    --get --data-urlencode "text=${text}" | \
jq ".speedScale = ${SPEED}" | \
curl -s -X POST "${URL}/synthesis?speaker=${SPEAKER}" \
    -H "Content-Type: application/json" -d @- | \
play -t wav -q -) &

exit 0
