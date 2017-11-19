#!/bin/bash

HOMEDIR=/home/arnoldas
BACKUP_NAME=backup-$(date -u +"%Y-%m-%d-%H-%M-%S-%Z")

# Ensure the passphrase file is set up
PWD_PATH=$HOMEDIR/.backup_password
if ! [ -f $PWD_PATH ]; then
    echo "Exiting: create a file $PWD_PATH with a password inside which will be used to
encrypt the archived backup, set its permissions to 600."
    exit
fi;
if [ $(stat -c %a "$PWD_PATH") != 600 ]; then
    echo "Exiting: set up permissions 600 the password file."$PWD_PATH
    exit
fi;

# Ensure the backup root dirs set up
BACKUP_ROOT_DIR=$HOMEDIR/backups
if ! [ -d "$BACKUP_ROOT_DIR" ]; then
    mkdir "$BACKUP_ROOT_DIR"
fi

# Archive
BACKUP_ARCHIVED_FILE="$BACKUP_ROOT_DIR/$BACKUP_NAME.tar.gz"
tar czf "$BACKUP_ARCHIVED_FILE" $HOMEDIR/Documents $HOMEDIR/Desktop # ADD MORE HERE

# Encrypt the archive
if ! [ -x "$(command -v gpg)" ]; then
    echo "Warning: not encrypting file because gpg is not installed."
else
    gpg --symmetric --cipher-algo AES256 --passphrase $(cat "$PWD_PATH") "$BACKUP_ARCHIVED_FILE" 
fi

# Delete old files
if ! [ -x "$(command -v srm)" ]; then
    echo "Warning: using insecure delete via rm. Install srm."
    rm -r "$BACKUP_ARCHIVED_FILE"
else
    srm -r "$BACKUP_ARCHIVED_FILE"
fi

echo "Done"

