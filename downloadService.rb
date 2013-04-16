#!/usr/bin/env ruby -w
require 'open-uri'
require 'mysql'
require 'drb'
require 'rinda/ring'
require 'rinda/tuplespace'
require 'mogilefs'


require_relative 'BingTile'
require_relative 'netUtil'

class DownloadService
#	@busy = false;
#	@dict 

	include DRbUndumped

	def self.start_downloader(downloaderCount)
		(0..downloaderCount).each do |d|
			Thread.new do
				DRb.start_service(get_available_druby_addr)
				downloader = DownloadService.new

				provider = Rinda::RingProvider.new :DownloadService, downloader, 'Downloader service'
				provider.provide

				DRb.thread.join
			end	
		end
	end

	def initialize
		@busy = false
		@dict = Hash.new
		@tileUtil = TileSystem.new
		@domain = 'bing_map'
		@hosts = %w[192.168.17.201:7001]
		@mg = MogileFS::MogileFS.new(:domain => 'bing_map', :hosts => @hosts)
		

		puts "service_started"
		ring_server = Rinda::RingFinger.primary
#		ring_finger = Rinda::RingFinger.new(['192.168.17.190','localhost'], 12315)
		
		puts "ring_serger built"
		@logger = ring_server.read([:name, :RindaLogger, nil, nil])[2]
		puts "ring_finger read"	
		#puts "logger_uri=>#{logger_uri.__drburi}"
		#@logger = DRbObject.new nil, logger_uri.__drburi
	end

		
	def busy?
		@busy
	end


	def getURI(aKey,serverNo)
		"http://ecn.t#{serverNo}.tiles.virtualearth.net/tiles/a#{aKey}.png?g=1191&n=z"
	end

	def do_download(akey,url)
		data = nil	
		puts url
		begin 
			url = URI.parse(url)
			open(url) do |http|
				data = http.read
			end
		rescue OpenURI::HTTPError => ex 
			puts ex
			log("#{akey}")	
		end
		return data;
	end


	def download(aKey)
		#try to get url from this downloader.
		url = getURI(aKey, Random.rand(0...5));
		data = do_download(aKey,url);
		puts data.size
		@dict[aKey] = data;					
	end

	def log(str)
		@logger.log(str)
	end

	def downloadAll(keys)
		@dict = Hash.new
		keys.each do |key|
			download(key)
			puts "#{key}"
		end
		yield(@dict)
	end

	def process(list)
		@busy = true
		Thread.new do 
			downloadAll(list) do |results|
			save_to_db(results)
			end	
		end
	end

	def process_from_mysql(startIdx,endIdx)
		@busy = true
		Thread.new do 		
		@dict = Hash.new
		count = endIdx - startIdx + 1
		count = 0 if count < 0
		con = Mysql.new '192.168.17.180','admin','hky123456','bing_map'
		con.set_server_option Mysql::OPTION_MULTI_STATEMENTS_ON
		rs = con.query "select * from tiles LIMIT #{startIdx},#{count}"
		rs.each_hash do |row|
			tileY = Integer(row['tile_row'])
			tileX = Integer(row['tile_column'])
			zoom =  Integer(row['zoom_level'])
			data =  row['tile_data']	
			tileY = (2**Integer(zoom) - 1) - Integer(tileY)
			quadKey = @tileUtil.tileXYToQuadKey(tileX, tileY, zoom)
			@dict[quadKey] = data	
		end
		
		save_to_db(@dict)	
		end
	end

	def transform_data(key, data)
		#make picture in current place.

	end

	def save_to_db(results)
	
		begin 
#			con = Mysql.new '192.168.17.180','admin','hky123456','bing_map'
#			con.set_server_option Mysql::OPTION_MULTI_STATEMENTS_ON
#			con.autocommit false
#			pst = nil
	#		pst = con.prepare("INSERT INTO tiles (zoom_level,tile_column, tile_row, tile_data) VALUES (?,?,?,?)") 
#SET zoom_level = ? tile_column = ? tile_row = ? tile_data = ?")
			
			results.keys.each do |key|
				@mg.store_content("#{key}.png",'bing_map', results[key])
=begin
				data = results[key]
				tileX, tileY, lod = @tileUtil.quadKeyToTileXY(key)

				open("#{key}.jpeg","wb"){|f| f.write(data)}	
				file_data = nil
				f = File.new("#{key}.jpeg",'rb')
				file_data = Mysql.escape_string(f.sysread(f.size))
				puts file_data[0..16]
				f.close
				File.delete("#{key}.jpeg")	

#				puts tileX, tileY, lod
				zoomlevelStr = "zoom_level = %d"%lod
				columnStr = "tile_column = %d"%tileX
				rowStr = "tile_row = %d"%tileY
				dataStr = "tile_data = '" + file_data + "'"
				
				pst = con.prepare("insert into tiles set #{zoomlevelStr}, #{columnStr}, #{rowStr}, #{dataStr}");
				pst.execute 
=end
			end
#			con.commit

		rescue Mysql::Error => e
			puts e
			log("#{e}")
#			con.rollback

		ensure
#			pst.close if pst
#			con.close if con
			@busy = false
		end		


	end


end

=begin
list = []

File.open("nehalam.data","r") do |file|
	count = 0
	file.each_line do |line|
		line = line.tr("\n","")
		break if count > 10
		count = count + 1
		list << line
	end
end
=end
#s = DownloadService.new
#s.downloadAll(list) do |results|
#	s.save_to_db(results)		
=begin
	results.keys.each do |key|
		data = results[key]
		open("#{key}.png","wb"){|f|f.write(data)}
	end
=end
#end


# try to put some error message to s

#s.log("hahahaha")
if __FILE__ == $0
#	DownloadService.start_downloader(2)
	DRb.start_service(get_available_druby_addr)
	downloader = DownloadService.new

	provider = Rinda::RingProvider.new :DownloadService, downloader, 'Downloader service'
	provider.provide

	DRb.thread.join
end
