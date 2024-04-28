To create a shell script for automating daily backups on a CentOS server, including error logging, you can follow this basic framework. This script will handle the backup of a specified directory and log both the operations and any errors encountered.

### Script Overview:
1. Define the directory to back up and the backup destination.
2. Create a logfile to store the backup process details.
3. Use `rsync` for efficient backup, which only copies changed files.
4. Log both the output and errors to the logfile.

### Shell Script:
```bash
#!/bin/bash

# Set the date format, backup directory, destination, and the log file location
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/path/to/your/backup/source"
DEST_DIR="/path/to/your/backup/destination/$DATE"
LOG_FILE="/path/to/your/logfile/backup_log_$DATE.log"

# Ensure the destination directory exists
mkdir -p "$DEST_DIR"

# Starting the backup process
echo "Starting backup for $DATE" | tee -a $LOG_FILE

# Running rsync to perform the backup, logging stdout and stderr
rsync -av --delete $BACKUP_DIR $DEST_DIR >> $LOG_FILE 2>&1

# Check if rsync was successful
if [ $? -eq 0 ]; then
    echo "Backup successful for $DATE" | tee -a $LOG_FILE
else
    echo "Backup failed for $DATE. Check log file $LOG_FILE for errors." | tee -a $LOG_FILE
    exit 1
fi

echo "Backup process completed." | tee -a $LOG_FILE
```

### Explanation:
- **Date and Time**: This script uses the `date` command to append the current date and time to the backup folder, making it easier to organize and identify backups.
- **Directories**: You need to replace `/path/to/your/backup/source` with the actual directory you wish to back up. Similarly, update the destination path where backups should be stored.
- **Logging**: The `tee -a $LOG_FILE` command is used to append the output to a logfile while also displaying it on the screen.
- **Rsync**: This command is crucial for performing the backup. The `-av` option enables archive mode and verbose output. The `--delete` option ensures that files deleted in the source are also deleted in the backup.

### Deployment:
1. Replace the placeholder paths in the script with actual paths relevant to your server setup.
2. Make the script executable with `chmod +x script_name.sh`.
3. Test the script manually to ensure it works as expected.
4. Schedule the script using `cron` for daily execution. Example crontab entry to run at 1 AM daily:
   ```
   0 1 * * * /path/to/script/script_name.sh
   ```

This script provides a basic yet robust framework for backing up files with logging. Ensure to test in a development environment before deploying on a production server. Adjustments might be necessary based on specific server configurations or additional requirements.


----------


To address your server backup requirements, you can create a shell script that automates the process of creating a `.tar.gz` archive of your backup directory, and then copying this archive to an external USB HDD when it is mounted. This script will also handle the regular rsync backup to a dedicated device.

Here’s a step-by-step guide to creating the script:

### Script Requirements:
1. **Automated Backup Creation**: Create a `.tar.gz` archive of the specified backup directory.
2. **Error Handling and Logging**: Log all operations and capture any errors.
3. **External HDD Handling**: Detect when an external HDD is mounted and copy the backup archive to it.
4. **Rsync Backup**: Continuously mirror the main server to a dedicated backup device.

### Shell Script:
```bash
#!/bin/bash

# Variables
BACKUP_SRC="/path/to/backup/source"
BACKUP_DEST="/path/to/backup/destination"
ARCHIVE_NAME="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
LOG_FILE="/path/to/logfile/backup_$(date +%Y%m%d).log"
MOUNT_POINT="/mnt/usb"  # Adjust this to your actual mount point
RSYNC_DEST="/path/to/rsync/destination"

# Create a backup archive
echo "Creating backup archive..." | tee -a $LOG_FILE
tar -czf $BACKUP_DEST/$ARCHIVE_NAME $BACKUP_SRC 2>> $LOG_FILE

# Check if the external HDD is mounted
if mount | grep -q $MOUNT_POINT; then
    echo "External HDD is mounted. Copying backup archive..." | tee -a $LOG_FILE
    cp $BACKUP_DEST/$ARCHIVE_NAME $MOUNT_POINT 2>> $LOG_FILE
    echo "Backup archive copied to external HDD." | tee -a $LOG_FILE
else
    echo "External HDD not mounted. Skipping copy to HDD." | tee -a $LOG_FILE
fi

# Rsync to dedicated backup device
echo "Starting rsync to dedicated backup device..." | tee -a $LOG_FILE
rsync -av --delete $BACKUP_SRC $RSYNC_DEST >> $LOG_FILE 2>&1
if [ $? -eq 0 ]; then
    echo "Rsync completed successfully." | tee -a $LOG_FILE
else
    echo "Rsync failed. Check log file for errors." | tee -a $LOG_FILE
fi

echo "Backup process completed." | tee -a $LOG_FILE
```

### Explanation:
- **tar command**: Creates a compressed archive of your backup directory.
- **Mount Check**: The script checks if the external USB HDD is mounted at the specified mount point before attempting to copy the backup archive.
- **Rsync**: Continuously mirrors the backup source to a dedicated backup device.
- **Logging**: All operations and errors are logged to a file for review.

### Deployment:
1. Adjust the paths in the script to match your server's configuration.
2. Make the script executable: `chmod +x backup_script.sh`.
3. Test the script manually to ensure it functions as expected.
4. Automate the script using `cron` to run at your desired frequency.

### Cron Setup:
To run the backup script daily at a specific time (e.g., 2 AM), add the following line to your crontab:
```bash
0 2 * * * /path/to/script/backup_script.sh
```

This setup ensures that your backups are created regularly and are copied to an external HDD when available, while also maintaining a continuous rsync backup to a dedicated device. Adjustments may be needed based on the specific server setup or additional requirements.

----------

### Setting Up Remote Backup to a Dedicated Server with NAT IP

To set up a remote backup on a CentOS server that communicates with a dedicated backup server using a NAT IP, you'll need to use `rsync` over SSH for secure data transfer. This guide will walk you through the process of setting up the backup script and configuring SSH for secure communication.

#### Prerequisites:
- SSH access to both the local (source) and remote (dedicated backup) servers.
- `rsync` installed on both servers.
- Knowledge of the NAT IP address and any port forwarding configurations required for the dedicated backup server.

#### Step 1: Configure SSH Keys for Passwordless Login
To facilitate secure and automated backups, set up SSH key-based authentication between your local server and the dedicated backup server.

1. **Generate SSH Key on Local Server**:
   ```bash
   ssh-keygen -t rsa -b 4096 -C "backup@localserver"
   ```
   Press enter to accept the default file location and passphrase (leave the passphrase empty for automated scripts).

2. **Copy the Public Key to the Dedicated Backup Server**:
   ```bash
   ssh-copy-id -i ~/.ssh/id_rsa.pub user@backup-server-ip
   ```
   Replace `user@backup-server-ip` with the actual username and IP address of the dedicated backup server.

#### Step 2: Create the Backup Script
Create a script on your local server that uses `rsync` to transfer backups to the dedicated server.

```bash
#!/bin/bash

# Variables
BACKUP_SRC="/path/to/backup/source"
RSYNC_DEST="user@backup-server-ip:/path/to/backup/destination"
LOG_FILE="/path/to/logfile/rsync_backup_$(date +%Y%m%d).log"

# Start the backup process
echo "Starting remote backup..." | tee -a $LOG_FILE

# Execute rsync command
rsync -avz -e "ssh -p port_number" --delete $BACKUP_SRC $RSYNC_DEST >> $LOG_FILE 2>&1

# Check if rsync was successful
if [ $? -eq 0 ]; then
    echo "Remote backup completed successfully." | tee -a $LOG_FILE
else
    echo "Remote backup failed. Check log file for errors." | tee -a $LOG_FILE
fi
```
- Replace `user@backup-server-ip` with your backup server's SSH login details.
- Replace `port_number` with the SSH port if it's not the default (22).
- The `-avz` flags in the `rsync` command ensure archive mode, verbose output, and compression for the data transfer.

#### Step 3: Schedule the Backup with Cron
To automate the backup process, schedule the script using `cron`.

1. Open the crontab editor:
   ```bash
   crontab -e
   ```
2. Add a line to run the script at a scheduled time, for example, every day at 3 AM:
   ```bash
   0 3 * * * /path/to/script/remote_backup.sh
   ```

#### Step 4: Monitor and Maintain
- Regularly check the log files to ensure that backups are completing successfully.
- Verify the integrity of the backups periodically by restoring a backup to a test environment.

This setup ensures that your CentOS server's data is securely backed up to a dedicated server over a network, even through NAT, using `rsync` and SSH for efficient and secure data transfer.