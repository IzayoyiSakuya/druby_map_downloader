#
require 'drb'
require 'rinda/ring'
require 'rinda/tuplespace'

require_relative 'netUtil'


class ServiceController
	def initialize(filename, level = 12)
		@ring_server = Rinda::RingFinger.primary	
		@next_process = 0
		@batch_count = 100
		@keys = []
		open(filename, "r") do |file|
			file.each_line do |line|
				key = line.tr("\n","")
				break if key.length > level
				@keys << key
			end
		end	
	end

	def find_available_downloader
		downloader = nil
		services = @ring_server.read_all [:name, :DownloadService, nil, nil]
		services.each do |service|
			downloader = service[2] unless service[2].busy?
			break if downloader
		end			
		downloader
	end

	def start_process(startEntry=0, endEntry=@keys.length)
		finish = false
		@next_process = startEntry	
		while(not finish) do 
			beginIdx = @next_process
			endIdx = beginIdx + @batch_count
			if (endIdx > endEntry)
				endIdx = endEntry
				finish = true
			end

			list_to_process = @keys[beginIdx..endIdx]
			downloader = nil
			begin
				downloader = find_available_downloader
			rescue Exception => ex
				puts "#{ex}"
			end
			
			if downloader
				downloader.process list_to_process
				puts "#{endIdx} / #{endEntry} is processing..."
				@next_process = endIdx+1	
				finish = true if @next_process > endEntry 
			else
				sleep(10.0)
			end		
		end
	end	
end

if __FILE__ == $0
	endlevel = 12
	endlevel = Integer(ARGV[0]) if ARGV.length > 0
	startrow = 0
	startrow = Integer(ARGV[1]) if ARGV.length > 1
	
	
	DRb.start_service(get_available_druby_addr)
	s = ServiceController.new "nehalam.data", endlevel
	s.start_process(startrow)
	#s.start_process(0,10)
end
