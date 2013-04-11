require 'open-uri'
require_relative 'BingTile'

a = TileSystem.new;
 
startPoint = [109.1166521084778, 40.4671049848856];
endPoint = [111.108242655933, 41.8650383258109];
 
 
upperLeftPoint = [endPoint[1], startPoint[0]];
bottomRightPoint = [startPoint[1], endPoint[0]];
 
#aKey = "1320111002011";
#tilex, tiley, level = a.quadKeyToTileXY(aKey);
#puts tilex, tiley, level;


 
#p = a.latLongToPixelXY(endPoint[1], startPoint[0], 13);
#puts p[0],p[1];
 
#gx,gy = a.pixelXYToTileXY(p[0],p[1]);
#puts gx, 2**13-1 - gy;
 
#q = a.tileXYToQuadKey(t[0],t[1],13);
#puts q;
 
#lod = 5;
 
#puts "xmin="+xRange[0].to_s;
#puts "xmax="+xRange[1].to_s;
#puts "ymin="+yRange[0].to_s;
#puts "ymax="+yRange[1].to_s;
count = 0;
 
#width = xmax-xmin;
#height = ymax-ymin;
#puts width*height;
projectName = "nehalam";
lodRange = [5,18];
 
r = Redis.new
r.del projectName

 
 
tileXYKey = "#{projectName}_tileXYKey";

open("#{projectName}.data","wb") do |file|
 
for lod in (lodRange[0]...lodRange[1]+1) do
ranges = a.getTileRange(upperLeftPoint, bottomRightPoint, lod);
 
 
xRange = ranges[0];
yRange = ranges[1];
 
 
 
xmin = xRange[0];
xmax = xRange[1];
ymin = yRange[0];
ymax = yRange[1];
 
list_name = "#{projectName}_#{lod}";
r.del list_name;	
for y in (ymin...ymax+1) do
for x in (xmin ... xmax+1) do
# puts "#{x}, #{y}";
 
# tileXY = a.pixelXYToTileXY(x,y);
quadKey = a.tileXYToQuadKey(x,y,lod);	
file.puts quadKey
url = getBingMapURL(quadKey);
#r.sadd list_name, url;
puts "#{count}:#{list_name}=>#{url}";
count = count + 1;
end
end
end
end
#puts count;

