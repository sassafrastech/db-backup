# db-backup
Simple Ruby script for doing regular, local DB backups and cleaning out old ones. By default, keeps hourly backups for a week, daily backups for 90 days, monthly backups forever.

You can specify retention periods for daily and weekly backups using `DAYS_TO_KEEP_HOURLY` and `DAYS_TO_KEEP_DAILY` env vars.

A typical cron job might look like this:

```
0 * * * * /bin/bash -l -c 'cd $HOME/db-backup; ./db-backup.rb ./backups "<dump-command>" >> backup.log 2>&1'
```
`0 * * * *` specifies how often the job will run - look at cron documentation for details. The line then loads bash, `cd`'s to the directory where the db-backup script is, and runs it, passing in the directory to write the back up to (here `./backups`), the dump command, and where to write the log to. 

Replace *`dump_command`* with a command to dump the desired database to **standard output**. Example:

```
mysqldump -u foo -ppass123 mydb
PGPASSWORD="pass123" pg_dump mydb
```

For mongodb, different arguments are required:

<pre>
0 * * * * /bin/bash -l -c 'cd $HOME/db-backup; ./db-backup.rb backups --dbms=mongo --db=<i>database_name</i> >> backup.log 2>&1'
</pre>

## Example Usage
Create a directory `db_backups` in $HOME. 
Copy this repository into `db_backups`
In the `db_backups` create a directory called `backups` 
Use `crontab -e` to add the cronjob. This opens a file where you add the line cron job line (startign with, for example, `0 * * * *`). Note that different files open with and without `sudo`. You probably want without `sudo` but check with project lead.  


## Notes

  * **IMPORTANT:** The directory passed as the first argument should ideally be **empty** except for backups created by this script. If not, it may get confused and **delete things it shouldn't**.
  * You may need to specify which ruby to use in the crontab, e.g. by adding `/usr/local/bin/ruby` right before `./db-backup.rb`.
