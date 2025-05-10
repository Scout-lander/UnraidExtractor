#!/bin/bash

# ======= CONFIG =======
DISCORD_WEBHOOK="https://discord.com/api/webhooks/your_webhook_here"
FOOTER_TEXT="ChonkyVibes Unraid Server"
# ======================

echo -e "\n===== Multi-Format Archive Extractor for Unraid =====\n"
read -rp "📦 Enter full path to archive: " ARCHIVE_PATH
read -rp "📁 Enter destination directory: " DEST_PATH

if [ ! -f "$ARCHIVE_PATH" ]; then
  echo "❌ Error: File '$ARCHIVE_PATH' not found."
  exit 1
fi

if [ ! -d "$DEST_PATH" ]; then
  echo "❌ Error: Destination '$DEST_PATH' not found."
  exit 1
fi

# Get extension and base name
BASENAME=$(basename "$ARCHIVE_PATH")
EXT_LOWER=$(echo "$BASENAME" | awk -F. '{print tolower($NF)}')
[[ "$BASENAME" =~ \.tar\.gz$ || "$BASENAME" =~ \.tgz$ ]] && EXT_LOWER="tar.gz"
[[ "$BASENAME" =~ \.tar\.bz2$ ]] && EXT_LOWER="tar.bz2"
[[ "$BASENAME" =~ \.tar\.xz$ ]] && EXT_LOWER="tar.xz"

ARCHIVE_NAME="$BASENAME"
JOB_ID=$(date +%s)
LOG_FILE="/mnt/user/extract-log-$JOB_ID.log"
ERROR_LOG="/mnt/user/unrar-errors-$JOB_ID.log"

# ======= Discord Embed Function =======
function discord_embed_notify() {
  local title="$1"
  local description="$2"
  local color="$3"

  curl -s -H "Content-Type: application/json" -X POST \
  -d "{
    \"username\": \"Unraid Extractor\",
    \"embeds\": [{
      \"title\": \"$title\",
      \"description\": \"$description\",
      \"color\": $color,
      \"timestamp\": \"$(date -Iseconds)\",
      \"footer\": {
        \"text\": \"$FOOTER_TEXT\"
      }
    }]
  }" "$DISCORD_WEBHOOK" > /dev/null
}

# ======= Overwrite Mode =======
OVERWRITE_FLAG=""
if [[ "$EXT_LOWER" =~ ^(rar|zip|7z)$ ]]; then
  echo -e "\nChoose overwrite mode:"
  echo "  [1] Overwrite all"
  echo "  [2] Skip existing files"
  echo "  [3] Ask before overwriting"
  read -rp "Enter your choice [1-3]: " OVERWRITE_MODE
  case $OVERWRITE_MODE in
    1) OVERWRITE_FLAG="-o+" ;;
    2) OVERWRITE_FLAG="-o-" ;;
    3) OVERWRITE_FLAG="" ;;
    *) echo "Invalid choice. Defaulting to skip."; OVERWRITE_FLAG="-o-" ;;
  esac
fi

# ======= Start Notification =======
discord_embed_notify "🔄 Extraction Started" \
"📦 \`$ARCHIVE_NAME\`\n📁 Destination: \`$DEST_PATH\`" \
3447003

# ======= Extraction Command =======
echo -e "\n🔧 Extracting '$ARCHIVE_PATH' to '$DEST_PATH'..."
echo "📜 Log: $LOG_FILE"
echo

case "$EXT_LOWER" in
  rar)
    nohup docker run --rm -v /mnt:/mnt ubuntu bash -c "\
      apt update && apt install -y software-properties-common && \
      add-apt-repository multiverse && apt update && \
      apt install -y unrar && \
      unrar x $OVERWRITE_FLAG \"$ARCHIVE_PATH\" \"$DEST_PATH\"" > "$LOG_FILE" 2>&1 &
    ;;
  zip)
    nohup docker run --rm -v /mnt:/mnt ubuntu bash -c "\
      apt update && apt install -y unzip && \
      unzip $OVERWRITE_FLAG \"$ARCHIVE_PATH\" -d \"$DEST_PATH\"" > "$LOG_FILE" 2>&1 &
    ;;
  7z)
    nohup docker run --rm -v /mnt:/mnt alpine sh -c "\
      apk add p7zip && \
      7z x $OVERWRITE_FLAG \"$ARCHIVE_PATH\" -o\"$DEST_PATH\"" > "$LOG_FILE" 2>&1 &
    ;;
  tar)
    nohup docker run --rm -v /mnt:/mnt alpine sh -c "\
      apk add tar && \
      tar -xf \"$ARCHIVE_PATH\" -C \"$DEST_PATH\"" > "$LOG_FILE" 2>&1 &
    ;;
  tar.gz|tgz)
    nohup docker run --rm -v /mnt:/mnt alpine sh -c "\
      apk add tar && \
      tar -xzf \"$ARCHIVE_PATH\" -C \"$DEST_PATH\"" > "$LOG_FILE" 2>&1 &
    ;;
  tar.bz2)
    nohup docker run --rm -v /mnt:/mnt alpine sh -c "\
      apk add tar && \
      tar -xjf \"$ARCHIVE_PATH\" -C \"$DEST_PATH\"" > "$LOG_FILE" 2>&1 &
    ;;
  tar.xz)
    nohup docker run --rm -v /mnt:/mnt alpine sh -c "\
      apk add tar xz && \
      tar -xJf \"$ARCHIVE_PATH\" -C \"$DEST_PATH\"" > "$LOG_FILE" 2>&1 &
    ;;
  gz)
    nohup docker run --rm -v /mnt:/mnt alpine sh -c "\
      apk add gzip && \
      gunzip -c \"$ARCHIVE_PATH\" > \"$DEST_PATH/${BASENAME%.gz}\"" > "$LOG_FILE" 2>&1 &
    ;;
  bz2)
    nohup docker run --rm -v /mnt:/mnt alpine sh -c "\
      apk add bzip2 && \
      bunzip2 -c \"$ARCHIVE_PATH\" > \"$DEST_PATH/${BASENAME%.bz2}\"" > "$LOG_FILE" 2>&1 &
    ;;
  xz)
    nohup docker run --rm -v /mnt:/mnt alpine sh -c "\
      apk add xz && \
      unxz -c \"$ARCHIVE_PATH\" > \"$DEST_PATH/${BASENAME%.xz}\"" > "$LOG_FILE" 2>&1 &
    ;;
  *)
    echo "❌ Unsupported file extension: $EXT_LOWER"
    exit 1
    ;;
esac

# ======= Background Monitoring =======
echo -e "\n✅ Extraction started in background."
echo "👉 Monitor full log: tail -f $LOG_FILE"

# Collect error log
(sleep 2 && grep -iE 'error|cannot|denied|fail' "$LOG_FILE" > "$ERROR_LOG") &

# Wait for process to finish and notify
(
  while pgrep -f "$ARCHIVE_PATH" > /dev/null; do sleep 5; done

  if [ -s "$ERROR_LOG" ]; then
    discord_embed_notify "⚠️ Extraction Completed with Errors" \
    "\`$ARCHIVE_NAME\` finished with issues.\n🧾 See log: \`$ERROR_LOG\`" \
    16776960
  else
    discord_embed_notify "✅ Extraction Completed" \
    "\`$ARCHIVE_NAME\` was extracted successfully." \
    3066993
  fi
) &
