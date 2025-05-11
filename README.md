# 🗂️ Unraid Multi-Format Archive Extractor

**Unraid Multi-Format Archive Extractor** is a Bash script designed to automatically extract a variety of archive formats on Unraid servers with ease. It leverages Docker containers to perform the heavy lifting of extraction, so you **don’t need to install** tools like `unrar` or `7z` on the host.

The script runs in the background, logs its progress, and can send you **Discord notifications** when extractions complete (or if they fail) using rich embed messages. This makes managing large archives on your Unraid server simple and efficient.

---

## ✨ Features

- 🧩 **Multi-format support:**  
  Extracts `.rar`, `.zip`, `.7z`, `.tar`, `.tar.gz`, `.tar.bz2`, `.tar.xz`, `.gz`, `.bz2`, and `.xz` archives – all with one script.  
  *(Supports multi-part RAR volumes like `.part001.rar` too.)*

- 🐳 **Docker-powered extraction:**  
  Uses lightweight Docker containers per job. No need to permanently install or maintain `unrar`, `7z`, etc. The tools are pulled and used on demand.

- 🏃 **Background operation:**  
  Kick off an extraction and continue with other tasks. The script detaches and runs the job in the background automatically, freeing up your terminal or UI.

- 📜 **Detailed logging:**  
  All actions and results are written to a timestamped log file. You can monitor progress and catch errors after the job finishes.

- 🔄 **Overwrite control:**  
  By default, the script skips existing files. But you can enable overwrite mode to replace them as needed.

- 🔔 **Discord notifications (optional):**  
  Get notified when extractions complete with rich Discord embeds:
  - ✅ Green for success
  - ❌ Red for errors
  - Includes archive name, status title, and a footer like `"ChonkyVibes Unraid Server"`

---

## 🧰 Prerequisites

Before using the script, ensure you have:

- ✅ **Unraid 6.x or newer**  
  Docker must be enabled. The script is tailored for Unraid’s environment.

- 🐳 **Docker Engine running**  
  Required to run temporary containers for extraction (e.g., Alpine, Ubuntu).

- 🐚 **Bash shell**  
  Default on Unraid — no extra languages or interpreters needed.

- 💬 **Discord webhook URL (optional)**  
  For push notifications to your server’s Discord channel (see [Discord Webhook Setup](#discord-webhook-setup)).

---

## 📦 Installation

1. **Download the script**  
   Place it on your Unraid server under `/boot/config/` or a persistent share:
   ```bash
   curl -o /boot/config/extract-any.sh https://raw.githubusercontent.com/YOUR_REPO_HERE/extract-any.sh
   chmod +x /boot/config/extract-any.sh
   ```

2. **(Optional) Set it up as a command**  
   ```bash
   ln -s /boot/config/extract-any.sh /usr/local/bin/extract
   ```

3. **(Optional) Add to User Scripts**  
   Go to *Settings → User Scripts* and add it for click-to-run access in the Unraid UI.

---

## 🚀 Usage

```bash
extract-any.sh [archive path] [destination]
```

You’ll be prompted to:

- Select **overwrite behavior** (`overwrite`, `skip`, or `ask`)
- See logs in `/mnt/user/extract-log-*.log`
- View errors in `/mnt/user/unrar-errors-*.log`

It supports:
- `.rar`, `.zip`, `.7z`
- `.tar`, `.tar.gz`, `.tar.bz2`, `.tar.xz`
- `.gz`, `.bz2`, `.xz`

---

## 🔔 Discord Webhook Setup

1. In your Discord server:
   - Go to *Channel Settings → Integrations → Webhooks*
   - Click *New Webhook*, choose a name & channel
   - Click *Copy Webhook URL*

2. Paste it into the script:
   ```bash
   DISCORD_WEBHOOK="https://discord.com/api/webhooks/XXXXXXXXX"
   ```

3. You’ll now receive:
   - ✅ Green: Success
   - ❌ Red: Failed
   - Message with title, timestamp, and `ChonkyVibes Unraid Server` footer

---

## 🛠 Optional Improvements

- Show duration of extraction
- Auto-detect `.part001.rar` in default folders
- Smart overwrite (only if newer or larger)
- Slack or email notification support

---

## 🤝 Contributing

Pull requests welcome! Bug fixes, enhancements, or better logging/output formatting are all appreciated.

---

## 📄 License

MIT License — free for personal or commercial use.

---

**Happy extracting!** 🎉  
— Built for Unraid by the ChonkyVibes crew 💪
