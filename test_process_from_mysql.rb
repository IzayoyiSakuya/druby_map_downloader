require_relative 'downloadService'

d = DownloadService.new

d.process_from_mysql(102000,10)
