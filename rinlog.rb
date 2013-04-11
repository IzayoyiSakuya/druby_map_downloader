#
require 'rinda/ring'
require 'rinda/tuplespace'

require_relative 'netUtil'

class RindaLogger
	include DRbUndumped

	def initialize
		@file = open("error_log.log","wb")
		@lock = Mutex.new
	end

	def log(str)
		@lock.synchronize do 
			@file.puts str	
		end
	end
end

DRb.start_service(get_available_druby_addr)

rlogger = RindaLogger.new
provider = Rinda::RingProvider.new :RindaLogger, rlogger, 'Error logger for exceptions.'
provider.provide
#renewer = Rinda::SimpleRenewer.new
#tuple = [:name, :RindaLogger, rlogger, 'Error logger for exceptions.']
#ring_server = Rinda::RingFinger.primary
#ring_server.write(tuple, renewer)

DRb.thread.join



