# Usage:
# A typical cron job might look like this (for hourly backups):

# 0 * * * * /bin/bash -l -c 'cd $HOME/db-backup; ./db-backup.rb backups "mysqldump -u foo -ppass123 mydb" >> backup.log 2>&1'

#!/usr/bin/env ruby
require "date"
require "fileutils"

@dir = ARGV[0]
@db_cmd = ARGV[1]

def backup_dir_for_date(date)
  "#{@dir}/#{date.strftime('%Y/%m/%d')}"
end

def backup_file_list(dir)
  Dir["#{dir}/*.sql.gz"].sort
end

def has_hourly_backups?(dir)
  backup_file_list(dir).size > 1
end

def delete_old_hourly_backups
  i = 1
  while has_hourly_backups?(dir = backup_dir_for_date(Date.today - 7 - i)) do
    backup_file_list(dir)[1..-1].each{ |f| FileUtils.rm(f) }
    i += 1
  end
end

def delete_very_old_daily_backups
  i = 1
  while Dir.exist?(dir = backup_dir_for_date(Date.today - 90 - i)) do
    FileUtils.rm_rf(dir)
    i += 1
  end
end

def create_new_backup
  FileUtils.mkdir_p(dir = backup_dir_for_date(Date.today))
  `#{@db_cmd} | gzip -c > #{dir}/#{Time.now.strftime('%Y%m%d_%H%M%S')}.sql.gz`
end

delete_old_hourly_backups
delete_very_old_daily_backups
create_new_backup