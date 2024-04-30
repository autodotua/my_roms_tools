function [lon,lat,dem_lon2,dem_lat2,dem_alt]=roms_get_grid_details(roms)
    xl=roms.grid.longitude(1); xr=roms.grid.longitude(2); %经度边界
    yb= roms.grid.latitude(1); yt= roms.grid.latitude(2); %纬度边界
    dx=(xr-xl)/(roms.grid.size(1)+1); dy=(yt-yb)/(roms.grid.size(2)+1); %经纬度的分辨率

    dem_lon=ncread(roms.res.elevation,roms.res.elevation_longitude); %DEM中的经度
    dem_lat=ncread(roms.res.elevation,roms.res.elevation_latitude); %DEM中的纬度
    hx1=find(dem_lon>xl,1)-1; hx2=find(dem_lon<xr,1,'last')+1; %寻找经度在DEM中的范围
    hy1=find(dem_lat>yb,1)-1; hy2=find(dem_lat<yt,1,'last')+1; %寻找纬度在DEM中的范围
    dem_alt=ncread(roms.res.elevation,roms.res.elevation_altitude, ...
        [hx1,hy1],[hx2-hx1+1,hy2-hy1+1]); %提取高程

    [dem_lon2,dem_lat2]=meshgrid(dem_lon(hx1:hx2),dem_lat(hy1:hy2)); %生成DEM二维网格
    dem_lon2=dem_lon2.';dem_lat2=dem_lat2.'; %DEM二维网格转置，原来是[南北,东西]，改为[东西,南北]
    [lon, lat]=meshgrid(xl:dx:xr, yb:dy:yt); %生成ROMS二维网格
    lon=lon.'; lat=lat.'; %原来是[南北,东西]，改为[东西,南北]