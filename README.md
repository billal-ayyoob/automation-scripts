# Automation Scripts
---

This is a Linux `shell/bash script`. Which assumes that there is a backup directory on a remote Linux server. The directory contains daily backups in this format: `{yyyy-mm-dd}.tar.gz`

## Here’s what the script does,

1. Takes a date as input in the yyyy-mm-dd format.

2. The script then verifies whether the backup exists on the remote server. If the backup doesn’t exist, the script fails with an error message.

3. If the backup exists, it downloads the files locally.

4. Next, the script extracts files from the backup, replaces the password in the `wp-config.php` file.

5. Then script recreates the backup archive.

6. Finally, creates an entry, in a local text file named backup-log.log, which will state that the backup for XX date has been verified and downloaded. We can simply append new entries to the log file. If the file doesn’t exist, the script will create one.
