# db-backup
Simple Ruby script for doing regular, local DB backups and cleaning out old ones. Keeps hourly backups for a week, daily backups for 90 days.

A typical cron job might look like this:

<pre>
0 * * * * /bin/bash -l -c 'cd $HOME/db-backup; ./db-backup.rb backups "<i>dump_command</i>" >> backup.log 2>&1'
</pre>

Replace *`dump_command`* with a command to dump the desired database to **standard output**.

Examples:
  * `mysqldump -u foo -ppass123 mydb`

**Note:** The directory passed as the second argument should ideally be empty except for backups created by this script. If not, it may get confused and delete things it shouldn't.
