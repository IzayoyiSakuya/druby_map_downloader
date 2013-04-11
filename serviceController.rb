#
require 'drb'
require 'rinda/ring'
require 'rinda/tuplespace'

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

			downloader = find_available_downloader
			
			if downloader
				downloader.process list_to_process
				puts "#{endIdx} / #{endEntry-startEntry} is processing..."
				@next_process = endIdx+1	
				finish = true if @next_process > endEntry 
			else
				sleep(10.0)
			end		
		end
	end	
end

DRb.start_service("druby://192.168.17.190:32874")
s = ServiceController.new "nehalam.data"
s.start_process
#s.start_process(0,10)
