require_relative 'downloadService'

download_count = ARGV[0]

#ARGV.each do |arg|
#puts arg
#end
#puts download_count
puts download_count
(0...Integer(download_count)).each do |count|
	pid = spawn("ruby downloadService.rb")
	puts pid
end
