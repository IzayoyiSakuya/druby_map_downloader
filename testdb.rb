#!/usr/bin/ruby

require 'mysql'


begin
    con = Mysql.new '192.168.17.180', 'admin', 'hky123456'
    puts con.get_server_info
    rs = con.query 'SELECT VERSION()'
    puts rs.fetch_row    
    
rescue Mysql::Error => e
    puts e.errno
    puts e.error
    
ensure
    con.close if con
end


puts ("abc").unpack("H*").class
puts ("Data='%s'" % ("abc").unpack('H*'))
