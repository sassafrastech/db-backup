#!/usr/bin/env ruby

DAYS_TO_KEEP_HOURLY = ENV['DAYS_TO_KEEP_HOURLY'] || 7
DAYS_TO_KEEP_DAILY = ENV['DAYS_TO_KEEP_DAILY'] || 30

require "date"
require "fileutils"
require "optparse"

OptionParser.new do |opts|
  opts.banner = "Usage: db-backup.rb [options] target-dir [dump-command]"

  opts.on("--dbms=DBMS", 'Database management system (if not given, second argument is required)') do |a|
    @dbms = a
  end

  opts.on("-d", "--db=DATABASE", 'Name of database to backup') do |a|
    @db = a
  end
end.parse!

raise "Database required" if @dbms && !@db
@dir = ARGV[0] || raise("Target directory required")
@db_cmd = ARGV[1]
raise "Dump command required if DBMS not given" if !@dbms && !@db_cmd

def backup_dir_for_date(date)
  "#{@dir}/#{date.strftime('%Y/%m/%d')}"
end

def backup_file_list(dir)
  Dir["#{dir}/*.gz"].sort_by { |f| File.mtime(f) }
end

def timestamp
  Time.now.strftime('%Y-%m-%d-%H%M%S')
end

def has_hourly_backups?(dir)
  backup_file_list(dir).size > 1
end

def delete_old_hourly_backups
  i = 1
  while has_hourly_backups?(dir = backup_dir_for_date(Date.today - DAYS_TO_KEEP_HOURLY - i)) do
    backup_file_list(dir)[1..-1].each{ |f| FileUtils.rm(f) }
    i += 1
  end
end

def delete_very_old_daily_backups
  i = 1
  while Dir.exist?(dir = backup_dir_for_date(Date.today - DAYS_TO_KEEP_DAILY - i)) &&
      # keep one per month (parent dir) (ideally the first of the month)
      dir.split('/')[-1] != '01' && Dir[File.expand_path('../*', dir)].size > 1 do
    FileUtils.rm_rf(dir)
    i += 1
  end
end

def create_new_backup
  FileUtils.mkdir_p(dir = backup_dir_for_date(Date.today))
  FileUtils.cd dir
  filename = "#{@db}-#{timestamp}"

  case @dbms
  when nil
    full_filename = "#{timestamp}.sql.gz"
    `#{@db_cmd} | gzip -c > #{full_filename}`
  when 'mongo'
    full_filename = "#{filename}.tar.gz"
    `/usr/bin/env mongodump -h 127.0.0.1 -d #{@db} -o .`
    # Mongodump names backup directory after db, no choice. Add timestamp before tar-ing.
    FileUtils.mv @db, filename
    `tar -czf #{full_filename} #{filename}`
    FileUtils.rm_rf(filename)
  else
    raise "DBMS not implemented"
  end
  puts "Finished backup to #{FileUtils.pwd}/#{full_filename}"
end

delete_old_hourly_backups
delete_very_old_daily_backups
create_new_backup
