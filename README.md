# db-backup
Simple Ruby script for doing regular, local DB backups and cleaning out old ones. By default, keeps hourly backups for a week, daily backups for 90 days, monthly backups forever.

You can specify retention periods for daily and weekly backups using `DAYS_TO_KEEP_HOURLY` and `DAYS_TO_KEEP_DAILY` env vars.

```
sudo su - deploy
git clone https://github.com/sassafrastech/db-backup.git
crontab -e
```

In the crontab, add:

```
<min> * * * * /bin/bash -l -c 'cd $HOME/db-backup; ./db-backup.rb ./backups "<dump-command>" >> backup.log 2>&1'
```
Replace `<min>` with the next minute in the hour so the job will run shortly after you save the crontab. It will subsequently run every hour thereafter at the same minute.

Replace `<dump_command>` with a command to dump the desired database to **standard output**. Example:

```
mysqldump -u foo -ppass123 mydb
PGPASSWORD="pass123" pg_dump mydb
```

For mongodb, different arguments are required:

<pre>
0 * * * * /bin/bash -l -c 'cd $HOME/db-backup; ./db-backup.rb backups --dbms=mongo --db=<i>database_name</i> >> backup.log 2>&1'
</pre>

## Notes

  * **IMPORTANT:** The directory passed as the first argument should ideally be **empty** except for backups created by this script. If not, it may get confused and **delete things it shouldn't**.
  * You may need to specify which ruby to use in the crontab, e.g. by adding `/usr/local/bin/ruby` right before `./db-backup.rb`.
