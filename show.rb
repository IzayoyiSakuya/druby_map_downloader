

open("nehalam.data") do |file|
	count = 0
	file.each_line do |line|
		count = count + 1
		a = line.tr"\n",""
		break if a.length > 15
	end
	puts count
end
