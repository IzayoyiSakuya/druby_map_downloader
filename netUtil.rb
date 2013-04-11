require 'socket'
require 'timeout'


def my_first_private_ipv4
	Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
end

def my_first_public_ipv4
	Socket.ip_address_list.detect{|intf| intf.ipv4? and !intf.ipv4_loopback? and !intf.ipv4_multicast? and !intf.ipv4_multicast? and !intf.ipv4_private?}
end


def local_ip
	orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true

	UDPSocket.open do |s|
		s.connect '64.233.187.99',1
		s.addr.last
	end
	ensure
		Socket.do_not_reverse_lookup = orig
end

def get_ip
	my_first_public_ipv4.ip_address unless my_first_public_ipv4.nil?
end

def is_port_open?(ip, port)
	begin 
		Timeout::timeout(1) do
			begin
				s = UDPSocket.open
				s.bind('',port)
				#s.bind(ip,port)
				s.close
				return true
			rescue Errno::ECONNREFUSED => ex
				puts "ECONNREFUSED"
				return false
			rescue Errno::EHOSTUNREACH => ex2
				puts "EHOSTUNREACH"
				return false
			rescue Exception => ex3
				return false
			end
		end
	rescue Timeout::Error
	end
	return false
end

def get_available_druby_addr
	ip = local_ip	
	available_addr = false
	while not available_addr
		port = Random.rand(20000...65000)
		if is_port_open?(ip, port)
			return "druby://#{ip}:#{port}"
		end
	end
end


#a = my_first_public_ipv4
#puts a.class
#puts my_first_public_ipv4.ip_address
#puts my_first_private_ipv4.ip_address
if __FILE__ == $0
	port = Random.rand(10000..65000)
	puts port
	ip = local_ip
	if is_port_open?(ip, 22335)
		puts "#{port} is available for ip #{ip}."
	else
		puts "#{port} is not available for ip #{ip}."
	end

	puts get_available_druby_addr
end
#puts local_ip