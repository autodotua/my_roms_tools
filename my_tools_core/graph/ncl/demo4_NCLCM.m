% demo4
% 需要mapping toolbox
[Z,R]=readgeoraster('n39_w106_3arc_v2.dt1','OutputType','double');

key.GTModelTypeGeoKey  = 2;
key.GTRasterTypeGeoKey = 2;
key.GeographicTypeGeoKey = 4326;

filename='southboulder.tif';
geotiffwrite(filename,Z,R,'GeoKeyDirectoryTag',key)

usamap([39 40],[-106 -105])
g=geoshow(filename,'DisplayType','mesh');


% 190 300 363
colormap(nclCM(15,200))

