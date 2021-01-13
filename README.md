# postgres-backup-sidecar
A postgres sidecar for backups to a borg repository

## Backup Config
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-backup-config
  namespace: postgres-servers
  labels:
    app: postgres
data:
  BORG_PASSPHRASE: somepasswordhere
  BACKUP_DIR: /backups/
  SCHEMA_ONLY_LIST: ""
  ENABLE_CUSTOM_BACKUPS: "yes"
  ENABLE_PLAIN_BACKUPS: "yes"
  ENABLE_GLOBALS_BACKUPS: "yes"
  config.yml: |
    # Where to look for files to backup, and where to store those backups. See
    # https://borgbackup.readthedocs.io/en/stable/quickstart.html and
    # https://borgbackup.readthedocs.io/en/stable/usage.html#borg-create for details.
    location:
        # List of source directories to backup (required). Globs and tildes are expanded.
        source_directories:
            - /backups/

        # Paths to local or remote repositories (required). Tildes are expanded. Multiple
        # repositories are backed up to in sequence. See ssh_command for SSH options like
        # identity file or port.
        repositories:
            - target-repor
    storage:
      ssh_command: ssh -o "StrictHostKeyChecking=no"

    # Retention policy for how many backups to keep in each category. See
    # https://borgbackup.readthedocs.org/en/stable/usage.html#borg-prune for details.
    # At least one of the "keep" options is required for pruning to work. See
    # https://torsion.org/borgmatic/docs/how-to/deal-with-very-large-backups/
    # if you'd like to skip pruning entirely.
    retention:
        # Number of daily archives to keep.
        keep_daily: 7
---
```
## Initialize borg repository and do first backup
For the first time before the first backup you have to initialize the borg repository

```
## Initialize only the first time
borgmatic init -e repokey-blake2
## Run first backup
/etc/periodic/daily/pg_backup
```

## How to restore a backup

```
borgmatic extract --archive latest|archivename
cd $BACKUP_DIR && gunzip *.gz
DB=databasename && dropdb -h localhost -U postgres $DB && psql -h localhost -U postgres -f $DB.sql

```
