require 'rubygems'
require 'redis'


class TileSystem
@@EarthRadius = 6378137;
@@MinLatitude = -85.05112878;
@@MaxLatitude = 85.05112878;
@@MinLongitude = -180;
@@MaxLongitude = 180;
 
 
 
	def clip(n, minValue, maxValue)
		[[n, minValue].max, maxValue].min;
	end
 
def mapSize(levelOfDetail)
256 * (2**levelOfDetail)
end
 
def groundResolution(latitude, levelOfDetail)
latitudeC = clip(latitude, @@MinLatitude, @@MaxLatitude);
Math.cos(latitudeC * Math::PI / 180.0) * 2.0 * Math::PI * @@EarthRadius / mapSize(levelOfDetail);
end
 
def mapScale(latitude, levelOfDetail, screenDpi)
groundResolution(latitude, levelOfDetail) * screenDpi / 0.0254;
end
 
def latLongToPixelXY(latitude, longitude, levelOfDetail)
latitudeC = clip(latitude, @@MinLatitude, @@MaxLatitude);
longitudeC = clip(longitude, @@MinLongitude, @@MaxLongitude);
 
x = (longitudeC + 180) / 360;
sinLatitude = Math.sin(latitudeC * Math::PI / 180);
y = 0.5 - Math.log(( 1+sinLatitude ) / ( 1-sinLatitude)) / (4 * Math::PI);
mapSizeC = mapSize(levelOfDetail);
pixelX = Integer(clip(x * mapSizeC + 0.5,0, mapSizeC -1));
pixelY = Integer(clip(y * mapSizeC + 0.5,0, mapSizeC -1));
return [pixelX, pixelY];
end
 
def pixelXYToLatLong(pixelX, pixelY, levelOfDetail)
mapSizeC = mapSize(levelOfDetail);
x = (clip(pixelX, 0, mapSizeC-1) / mapSizeC) - 0.5;
y = 0.5 - (clip(pixelY, 0, mapSizeC-1) / mapSizeC);
 
latitude = 90 - 360 * Math.atan(Math.exp(-y * 2 * Math::PI)) / Math::PI;
longitude = 360 * x;
return [latitude, longitude];
end
 
def pixelXYToTileXY(pixelX, pixelY)
tileX = Integer(pixelX / 256);
tileY = Integer(pixelY / 256);
return [tileX, tileY];
end
 
def tileXYToPixelXY(tileX, tileY)
pixelX = Integer(tileX * 256);
pixelY = Integer(tileY * 256);
return [pixelX, pixelY];
end
 
def tileXYToQuadKey(tileX, tileY, levelOfDetail)
i = levelOfDetail;
quadKey = "";
begin
digit = 0;
mask = (2**(i-1));
if((tileX & mask) != 0)
digit = digit + 1;
end
if((tileY & mask) != 0)
digit = digit + 2;
end
i = i-1;
quadKey = quadKey + digit.to_s;
 
end while i > 0
 
return quadKey;
end
 
def quadKeyToTileXY(quadKey)
tileX = 0;
tileY = 0;
levlOfDetail = quadkey.Length;
i = levelOfDetail;
begin
mask = 2**(i-1);
case quadKey[levelOfDetail-i]
when '0'
break;
when '1'
tileX |= mask;
break;
when '2'
tileY |= mask;
break;
when '3'
tileX |= mask;
tileY |= mask;
break;
else
puts "Invalid QuadKey digit sequence.";
end
i = i-1;
end while i > 0
return [tileX, tileY, levelOfDetail];
end


	def getTileRange(upperLeftPoint, bottomRightPoint, levelOfDetail)
		p0 = latLongToPixelXY(upperLeftPoint[0], upperLeftPoint[1], levelOfDetail);
		r0 = pixelXYToTileXY(p0[0],p0[1]);
		
	p1 = latLongToPixelXY(bottomRightPoint[0], bottomRightPoint[1], levelOfDetail);
		r1 = pixelXYToTileXY(p1[0],p1[1]);
		xRange = [r0[0], r1[0]];
		yRange = [r0[1], r1[1]];	
		return [xRange, yRange];
	end
 
 
end

def getBingMapURL(quadKey)
	return "ecn.t#{Random.rand(0...4)}.tiles.virtualearth.net/tiles/a#{quadKey}.png?g=1191&n=z";
end

a = TileSystem.new;

startPoint = [109.1166521084778, 40.4671049848856];
endPoint = [111.108242655933, 41.8650383258109];


upperLeftPoint = [endPoint[1], startPoint[0]];
bottomRightPoint = [startPoint[1], endPoint[0]];


=begin
p = a.latLongToPixelXY(startPoint[1], startPoint[0], 13);
puts p[0],p[1];

t = a.pixelXYToTileXY(p[0],p[1]);
puts t[0],t[1];

q = a.tileXYToQuadKey(t[0],t[1],13);
puts q;
=end

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

for lod in (lodRange[0]...lodRange[1]+1) do 
	
	ranges =  a.getTileRange(upperLeftPoint, bottomRightPoint, lod);


	xRange = ranges[0];
	yRange = ranges[1];



	xmin = xRange[0];
	xmax = xRange[1];
	ymin = yRange[0];
	ymax = yRange[1];

	list_name = "#{projectName}_#{lod}";
	r.del list_name;	
for y in (ymin...ymax) do
 for x in (xmin ... xmax) do
#	puts "#{x}, #{y}";	

#	tileXY = a.pixelXYToTileXY(x,y);
	quadKey = a.tileXYToQuadKey(x,y,lod);	
	if(r.sismember(tileXYKey,quadKey))
		next
	end
	
	url = getBingMapURL(quadKey);
	r.sadd list_name, url;
	puts "#{count}:#{list_name}=>#{url}";
	count = count + 1;
 end
end
end
#puts count;

