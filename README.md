# db-backup
Simple Ruby script for doing regular, local DB backups

A typical cron job might look like this:

```
0 * * * * /bin/bash -l -c 'cd $HOME/db-backup; ./db-backup.rb backups "mysqldump -u foo -ppass123 mydb" >> backup.log 2>&1'
```
