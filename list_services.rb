require 'rinda/ring'

DRb.start_service
#ring_finger = Rinda::RingFinger.new(['192.168.17.190','localhost'], 51499)
#puts ring_finger.primary.inspect
#puts ring_finger.lookup_ring_any.inspect
#ring_server = ring_finger.lookup_ring_any

#ring_finger.each do |aserver|
#	puts aserver.__drburi
#end	

#broadcast = Rinda::RingFinger.finger.broadcast_list
#puts broadcast
puts "start"
#finger = Rinda::RingFinger.new(['192.168.17.255','localhost'],12315)

#finger.each do |server|
#	server.read([nil,nil,nil,nil])
#end

ring_server = Rinda::RingFinger.primary

#puts Rinda::RingFinger.finger.port

services = ring_server.read_all [nil, nil, nil, nil]
puts services.inspect
puts "===="
puts ring_server.inspect
puts "Services on #{ring_server.__drburi}"
services.each do |service|
	puts "#{service[1]} on #{service[2].__drburi} - #{service[3]}"
end
