# db-backup

A simple Ruby script for doing regular, local database backups and cleaning out old ones.

By default, it keeps hourly backups for a week, daily backups for 90 days, and monthly backups forever. You can specify retention periods for daily and weekly backups using the `DAYS_TO_KEEP_HOURLY` and `DAYS_TO_KEEP_DAILY` env vars.

Backup files are compressed automatically after saving.

## Setup

1. Ensure ruby is installed: `ruby -v`
1. Switch to the database user if needed: `sudo -u deploy`
1. Clone this backup tool: `git clone https://github.com/sassafrastech/db-backup.git`
1. Tell linux to run it regularly: `crontab -e` or `sudo crontab -e` depending on whether you need root to run your dump_commands

In the crontab, add something similar to this line:

```
X * * * * /bin/bash -l -c 'cd $HOME/db-backup; DAYS_TO_KEEP_DAILY=30 ./db-backup.rb ./backups "<dump_commands>" >> backup.log 2>&1'
```

Replace `X` with the next minute in the hour so the job will run shortly after you save the crontab. It will then run every hour thereafter at the same minute.

Replace `<dump_commands>` with a command to dump the desired database to **standard output** where it will be captured and saved.

## Examples

### MySQL

```
./db-backup.rb ./backups "mysqldump -u my_user -pmy_password my_db"
```

### Postgres

```
./db-backup.rb ./backups "PGPASSWORD=my_password pg_dump my_db"
```

### Mongo

For mongodb, different arguments are required:

```
./db-backup.rb ./backups --dbms=mongo --db=my_db
```

## Notes

* **IMPORTANT:** The `$HOME/db-backup` directory passed as the first argument should ideally be **empty** except for backups created by this script. If not, it may get confused and **delete things it shouldn't**.
* You may need to specify which Ruby to use in the crontab, e.g. by adding `/usr/local/bin/ruby` right before `./db-backup.rb`.
