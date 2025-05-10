Unraid Multi-Format Archive Extraction Script
Introduction
This project provides a multi-format archive extraction script designed for Unraid servers. It allows you to extract a wide range of archive types on your Unraid server without needing to install extra software on the host. The script leverages Docker containers to handle the extraction, meaning tools like 7-Zip and unRAR are fetched on-the-fly in containers rather than installed permanently on Unraid
reddit.com
. It runs extraction tasks in the background, writing progress and details to a log file, so you can kick off an extract and continue using your server. Additionally, it supports rich Discord webhook notifications – you can receive a Discord message when an extraction finishes or if an error occurs, with an embedded status message (including a colored indicator and footer for context). Key Features:
Multiple Archive Formats: Supports extracting .rar, .zip, .7z, .tar, .tar.gz, .tar.bz2, .tar.xz, .gz, .bz2, and .xz archives. This covers all common compression formats (7-Zip can unpack 7z, XZ, BZIP2, GZIP, TAR, ZIP, and RAR among others
quora.com
). You don't have to remember different tools for each format – the script handles it automatically.
Docker-Powered Extraction: Uses ephemeral Docker containers with the needed tools to perform the extraction. This means your Unraid system itself stays clean (no need to install unrar, 7zip, etc. via Nerd Tools or apt)
reddit.com
. The required Docker images are pulled and run on demand, then removed after use.
Background Operation with Logging: The extraction runs as a background process, so it won’t tie up your terminal or Unraid web UI. All output (progress, file names, errors) is saved to a log file for you to review at any time. This is ideal for large archives – start the extraction and let it work in the background.
File Overwrite Control: You can choose how the script handles files that already exist at the extraction destination. By default it will skip extracting files that are already present (to avoid overwriting anything unexpectedly), but you can enable an overwrite mode if you want to replace existing files with those from the archive. This option prevents accidental replacements while still giving you flexibility when needed.
Discord Webhook Notifications: Optionally integrate with Discord to get a notification when extraction completes or if it fails. The script sends a Discord webhook message with a rich embed – for example, a green-highlighted message for success or a red-highlighted one for errors, including details of the archive name and any error message, plus a footer (e.g. timestamp and server name) for context
gist.github.com
github.com
. This way, you can monitor long-running extractions remotely on your phone or PC via Discord.
Prerequisites
Before using the script, ensure the following:
Unraid Server: This script is intended for Unraid (6.x or newer) where the Docker service is available and enabled. It may work on any Linux system with Docker, but it’s tailored for Unraid’s environment.
Docker: Docker must be enabled on your server (on Unraid, Docker is enabled when the array is started in normal mode). No specific Docker containers need to be pre-installed; the script will pull required images automatically.
Access to Shell or User Scripts Plugin: You should have a way to run the script on Unraid. This can be via the Unraid web terminal / SSH, or through the Unraid User Scripts plugin (recommended for ease of use).
Discord Webhook URL (Optional): If you want Discord notifications, you’ll need a Discord webhook URL. You can set this up in your Discord server (see Discord Webhook Setup below for instructions). If you don’t need notifications, you can still use the script without a webhook – it will simply skip the notification step.
Installation
To install the archive extraction script on your Unraid server, follow these steps:
Download the Script: Obtain the script file (unraid-extract.sh for example) from this repository. You can download it via your web browser from the GitHub page, or use curl/wget. For instance, from the Unraid terminal you might run:
curl -o /boot/config/scripts/unraid-extract.sh https://raw.githubusercontent.com/<user>/<repo>/main/unraid-extract.sh
(Make sure to replace the URL with the actual raw link to the script in this repo.)
Location: Place the script in a persistent location on your Unraid server. A common place is the /boot/config/scripts/ directory (if using the User Scripts plugin, it will default to storing user scripts there). This ensures the script is retained between reboots.
Make it Executable: After uploading, set the execute permission so you can run it. In a terminal:
chmod +x /boot/config/scripts/unraid-extract.sh
(Optional) Set Up in User Scripts Plugin: If you have the Community Applications User Scripts plugin on Unraid, you can add this script there for easy execution and scheduling
github.com
. In the Unraid web UI: go to Settings > User Scripts, click “Add New Script”, give it a name (e.g. "Archive Extractor"), then click Edit Script and paste the contents of unraid-extract.sh. This allows you to run it from the GUI or even schedule it (for example, to periodically check a folder).
Configure Script Settings: Open the script in a text editor to review configurable settings (usually at the top of the script). Here you can set defaults like the Discord webhook URL, and choose the default behavior for overwriting files. For example, there may be a variable for DISCORD_WEBHOOK_URL – put your webhook URL there (inside quotes). There might also be a setting for default overwrite mode (e.g., OVERWRITE=false to skip by default). Adjust these as needed. (All these can also be overridden via command-line options at runtime, as described below.)
Now you’re ready to use the script for extracting archives!
Usage
You can run the extraction script manually from the command line or via the Unraid User Scripts interface. The basic usage syntax is:
./unraid-extract.sh [options] <path-to-archive-or-folder>
You can specify either a single archive file or a directory containing multiple archives as the target path.
The script will automatically detect the archive type by its extension and use the appropriate extraction method. All common formats are supported (.rar, .zip, .7z, .tar, .gz, .bz2, .xz, and combined formats like .tar.gz, .tar.bz2, .tar.xz) – there’s no need to manually pick a tool
quora.com
.
Multi-part archives (e.g., .r00/.r01... or .part1.rar sequences) are supported as well. Just point to the first file in the set (like the .rar or .part1.rar file) and the script will assemble the rest automatically during extraction.
Options:
-o, --overwrite – Enable overwrite mode. If this flag is used, any files that already exist at the destination will be replaced by the files from the archive. Use this if you want to update/replace files. Default behavior (if this flag is not used) is to skip extracting files that already exist, leaving any existing files intact.
-n, --no-overwrite – Opposite of overwrite: explicitly skip extraction of files that are already present. (This is the default mode, so you typically don’t need to specify it unless you want to be explicit.)
-d, --dest <folder> – Specify a destination directory for extraction. By default, the script will extract files into the same directory where the archive resides (or into a new folder named after the archive, depending on archive type). Use -d if you want to extract the contents to a specific folder elsewhere.
-w, --webhook <URL> – Provide a Discord webhook URL for this run. This overrides the URL configured in the script (or allows you to specify one if none was set in the script). If you haven’t configured the Discord webhook in the script, you can use this option to enable Discord notifications on the fly.
-q, --quiet – Quiet mode. Runs with minimal console output (useful if you’re running manually and don’t want a lot of messages). The log file will still capture everything.
-h, --help – Display a help message summarizing usage. (You can see all available options with a brief description.)
Examples:
Extract a single archive in place (skip existing files by default):
./unraid-extract.sh /mnt/user/Downloads/myarchive.rar
This will create a subfolder (if the archive contains multiple files or a folder structure) or extract files into the Downloads folder next to myarchive.rar. Existing files with the same name will not be overwritten.
Extract a .tar.gz archive to a specific directory, overwriting any files if necessary:
./unraid-extract.sh -o -d /mnt/user/Media/Movies /mnt/user/Backups/movie.tar.gz
In this example, the contents of movie.tar.gz will be extracted to /mnt/user/Media/Movies. Because -o is used, if any files inside Movies have the same names as files in the archive, they will be replaced with the archive’s version.
Extract all archives inside a folder (and its subfolders) to their respective locations, and send a Discord notification when done:
./unraid-extract.sh -w "https://discord.com/api/webhooks/XXX/YYY" /mnt/user/ToExtract/
Here we pointed the script at the /mnt/user/ToExtract/ directory. The script will find all archives in that folder (you can configure whether it searches recursively into subfolders if needed) and extract each. Because a webhook URL is provided with -w, the script will send status notifications to Discord (using that URL) for each archive processed. You could combine this with -o or -n as needed to control overwriting.
Running in Background: When executed from the command line, the script will automatically detach and run in the background (thanks to Unraid’s script settings or an internal nohup/background call). If you run it via the User Scripts plugin, be sure to select "Run in Background" if you want it to not tie up the browser. Once running, you can safely close the terminal or browser window. The output will be captured to a log file for later review.
The log file is typically named after the script (for example, unraid-extract.log or a timestamped log in a logs directory — check the script configuration for the exact path). Open this log to see detailed output of what was extracted, or any error messages in case something went wrong.
If running through User Scripts, you can also click “View Log” for the script to see the output.
Discord Webhook Setup
If you want to receive Discord notifications about the extraction jobs, you’ll need to set up a Discord webhook and tell the script about it. Here’s how to do that:
Create a Webhook in Discord: In your Discord server, go to Server Settings > Integrations > Webhooks. Click "New Webhook". Give it a name (for example, "Unraid Extractor") and select the text channel where you want to receive the notifications. Finally, click "Copy Webhook URL" to get the unique URL for this webhook
github.com
. Save this URL — it will look something like:
https://discord.com/api/webhooks/1234567890/abcdefg...
Configure the Script with the Webhook URL: There are two ways to do this:
Recommended: Edit the script file and find the configuration section at the top. There should be a variable like DISCORD_WEBHOOK_URL="". Paste your webhook URL inside the quotes. You can also enable/disable Discord notifications with a flag if available (some scripts have a toggle, e.g., USE_DISCORD=true). Ensure it’s enabled if such an option exists. Save the file.
OR you can supply the URL at runtime with the -w <URL> option each time you run the script (as shown in the usage examples above). This is handy if you don’t want to store the URL in the script or if you use different webhooks for different purposes.
Test the Webhook (Optional): It might be a good idea to test that the webhook is working. You can run a quick extraction on a small archive with the webhook configured. When the script finishes, check your Discord channel. You should see a message from the webhook bot. For example, on success it might say “Extraction Completed” with details, and on failure you’ll see an “Extraction Failed” message with an error description. The messages are sent as embeds, which means they have a colored stripe on the left side (usually green for success, red for error) and a footer text. The footer might include a timestamp or your server name for reference
gist.github.com
.
Customization (Optional): If you’re comfortable editing the script, you can customize the Discord notification content. For instance, you could change the embed color or text. By default, Discord embed colors are specified by an integer (not hex code) in the JSON payload
birdie0.github.io
 – the script already sets appropriate values, but you can adjust if desired (e.g., change the success color from green to another color by changing the number). You could also modify the footer text to add your own server name or remove it. However, these tweaks are optional – the default notifications should be informative enough for most users.
Once set up, every time you run an extraction, you’ll get near-instant notifications on Discord. This is particularly useful for long extractions – you don’t have to keep checking your server; a message will let you know when it’s done or if it needs attention
github.com
.
Additional Notes
Performance: Extraction speed will depend on your hardware and the size of archives. Using Docker for extraction adds a tiny overhead (for container startup), but the actual decompression runs at native speed. If you have many small archives, the container startup per file could add up; in such cases, extracting a whole folder in one go (so the script can reuse containers) is more efficient.
Disk Space: Make sure you have sufficient free space in the destination for the extracted files. If an archive is very large when uncompressed, you need that space available on the target drive. The script will report an error in the log/Discord if it runs out of space during extraction.
Permissions: Files extracted via this script will be created by the Docker container’s user. Typically this ends up being root or nobody user on Unraid, depending on how the Docker image is set up. In most cases, this means the files will be owned by nobody:users (the same as Unraid shares) – which is good. If you find the permissions are not what you expect, you might need to adjust UMASK or PUID/PGID settings in the script or the Docker command it uses. However, for the majority of use cases, you won’t need to tweak this.
Cleaning Up Archives: The script by default does not delete the original archive files. If you want it to remove archives after successful extraction (to save space), you could enable a cleanup option if available or manually delete them. We chose not to auto-delete by default for safety. You can always verify the extracted files and then remove archives manually or modify the script to do so.
Troubleshooting: If an extraction fails, check the log file for the specific error message. Common issues might be a corrupted archive or an unsupported format (e.g., some .rar files might be in an old or proprietary format that the open-source unrar can’t handle). The log will show the output from the extraction command (like a 7z or tar error). If you run into issues, you can also run the extraction manually inside the Docker container for debugging. For example, the script might use a command like docker run --rm -v /path/to/dir:/data alpine sh -c "apk add p7zip && 7z x file.rar" under the hood – you can mimic that step by step to see what’s going wrong.
Unraid Integration: Because this is a shell script, it integrates well with Unraid’s system. You can combine it with other automation. For instance, you could set up a scheduled User Script to scan a "watch folder" for new archives every night and extract them. Or call this script at the end of a download completion event (some download clients allow running a user script when a download finishes).
Contributing
Feel free to contribute to this project by opening issues or pull requests. If you encounter a bug or have an idea for an improvement (for example, support for another archive format or a new notification method), let us know. Contributions are welcome to make the script more robust and versatile.
