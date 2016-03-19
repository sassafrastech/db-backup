# db-backup
Simple Ruby script for doing regular, local DB backups and cleaning out old ones. Keeps hourly backups for a week, daily backups for 90 days, monthly backups forever.

A typical cron job might look like this:

```
0 * * * * /bin/bash -l -c 'cd $HOME/db-backup; ./db-backup.rb ./backups "<dump-command>" >> backup.log 2>&1'
```

Replace *`dump_command`* with a command to dump the desired database to **standard output**. Example:

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
