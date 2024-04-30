function roms_create_force_radiation_ERA5
    % 从ERA5的nc文件创建适用于ROMS的辐射强迫文件。时间与输入文件相同。区域与ROMS网格文件相同，但网格不一一对应。
    tic
    configs

    nc =fullfile(roms.project_dir,roms.input.atom_radiation);

    %确定网格
    disp("正在读取网格")
    [lon_rho,lat_rho]=roms_load_grid_rho(fullfile(roms.project_dir,roms.input.grid));

    %读取ERA5数据
    disp("正在读取ERA5数据")
    times_days=double(ncread(roms.res.force_era5_radiation_file,'time'))/24+datenum(1900,1,1);
    i1=find(times_days>datenum(roms.time.start),1)-1;
    if i1<=0
        i1=1;
    end
    i2=find(times_days<datenum(roms.time.stop),1,"last")+1;
    if i2>length(times_days)
        i2=length(times_days);
    end

    times_days=times_days(i1:i2);
    times=datetime(times_days,'ConvertFrom','datenum');
    lon=ncread(roms.res.force_era5_radiation_file,'longitude');
    lat=ncread(roms.res.force_era5_radiation_file,'latitude');
    ssr=ncread(roms.res.force_era5_radiation_file,'ssr',[1,1,i1],[length(lon),length(lat),i2-i1+1])/3600;
    str=ncread(roms.res.force_era5_radiation_file,'str',[1,1,i1],[length(lon),length(lat),i2-i1+1])/3600;
    strd=ncread(roms.res.force_era5_radiation_file,'strd',[1,1,i1],[length(lon),length(lat),i2-i1+1])/3600;
    
    times(end+1)=times(end)+(times(end)-times(end-1));
    times_days(end+1)=times_days(end)+(times_days(end)-times_days(end-1));
    ssr(:,:,end+1)=ssr(:,:,1);
    str(:,:,end+1)=str(:,:,1);
    strd(:,:,end+1)=strd(:,:,1);
    
    %纬度翻转，改为从小到大（从南到北）
    lat=flip(lat);
    ssr=flip(ssr,2);
    str=flip(str,2);
    strd=flip(strd,2);

    %生成二维坐标
    [LON,LAT]=meshgrid(lon,lat);
    LON=LON';
    LAT=LAT';

    %计算ROMS网格范围
    lon_min=min(lon_rho,[],'all');
    lon_max=max(lon_rho,[],'all');
    lat_min=min(lat_rho,[],'all');
    lat_max=max(lat_rho,[],'all');

    %计算在ERA5网格中需要裁切的行列序号范围
    x1=find(lon>=lon_min,1)-2;
    x2=find(lon> lon_max,1)+1;
    y1=find(lat>=lat_min,1)-2;
    y2=find(lat> lat_max,1)+1;
    width=x2-x1+1;
    height=y2-y1+1;

    %裁切
    swrad=ssr(x1:x2,y1:y2,:);
    lwrad_down=strd(x1:x2,y1:y2,:);
    lwrad=str(x1:x2,y1:y2,:);

    %异常值处理
    swrad(swrad<0) = 0;
    lwrad_down(lwrad_down<0) = 0;
    lwrad(lwrad<0) = 0;


    %创建nc
    disp("正在写入nc文件")
    ncid = netcdf.create(nc,'nc_clobber');

    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'type', 'radiation forcing file');
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'gridid','combined grid');
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'history',['Created by "' mfilename '" on ' datestr(now)]);

    lon_dimID = netcdf.defDim(ncid,'xr',width);
    lat_dimID = netcdf.defDim(ncid,'er',height);
    t_dimID = netcdf.defDim(ncid,'time',length(times));

    tID = netcdf.defVar(ncid,'time','double',t_dimID);
    netcdf.putAtt(ncid,tID,'long_name','atmospheric forcing time');
    netcdf.putAtt(ncid,tID,'units','days');
    netcdf.putAtt(ncid,tID,'field','time, scalar, series');

    lonID = netcdf.defVar(ncid,'lon','double',[lon_dimID lat_dimID]);
    netcdf.putAtt(ncid,lonID,'long_name','longitude');
    netcdf.putAtt(ncid,lonID,'units','degrees_east');
    netcdf.putAtt(ncid,lonID,'field','xp, scalar, series');

    latID = netcdf.defVar(ncid,'lat','double',[lon_dimID lat_dimID]);
    netcdf.putAtt(ncid,latID,'long_name','latitude');
    netcdf.putAtt(ncid,latID,'units','degrees_north');
    netcdf.putAtt(ncid,latID,'field','yp, scalar, series');


    swradID = netcdf.defVar(ncid,'swrad','double',[lon_dimID lat_dimID t_dimID]);
    netcdf.putAtt(ncid,swradID,'long_name','net solar shortwave radiation flux');
    netcdf.putAtt(ncid,swradID,'units','watt meter-2');
    netcdf.putAtt(ncid,swradID,'positive_value','downward flux, heating');
    netcdf.putAtt(ncid,swradID,'negative_value','upward flux, cooling');
    netcdf.putAtt(ncid,swradID,'field','swrad, scalar, series');
    netcdf.putAtt(ncid,swradID,'coordinates','lon lat');
    netcdf.putAtt(ncid,swradID,'time','time');

    lwradID = netcdf.defVar(ncid,'lwrad','double',[lon_dimID lat_dimID t_dimID]);
    netcdf.putAtt(ncid,lwradID,'long_name','net downward solar longwave radiation');
    netcdf.putAtt(ncid,lwradID,'units','Watts meter-2');
    netcdf.putAtt(ncid,lwradID,'positive_value','downward flux, heating');
    netcdf.putAtt(ncid,lwradID,'negative_value','upward flux, cooling');
    netcdf.putAtt(ncid,lwradID,'field','lwrad, scalar, series');
    netcdf.putAtt(ncid,lwradID,'coordinates','lon lat');
    netcdf.putAtt(ncid,lwradID,'time','time');

    lwradID = netcdf.defVar(ncid,'lwrad_down','double',[lon_dimID lat_dimID t_dimID]);
    netcdf.putAtt(ncid,lwradID,'long_name','downward solar longwave radiation');
    netcdf.putAtt(ncid,lwradID,'units','Watts meter-2');
    netcdf.putAtt(ncid,lwradID,'positive_value','downward flux, heating');
    netcdf.putAtt(ncid,lwradID,'negative_value','upward flux, cooling');
    netcdf.putAtt(ncid,lwradID,'field','lwrad_down, scalar, series');
    netcdf.putAtt(ncid,lwradID,'coordinates','lon lat');
    netcdf.putAtt(ncid,lwradID,'time','time');

    netcdf.close(ncid)

    %写入数据
    ncwrite(nc,'lon',LON(x1:x2,y1:y2));
    ncwrite(nc,'lat',LAT(x1:x2,y1:y2));
    ncwrite(nc,'time',times_days- datenum(roms.time.base));
    ncwrite(nc,'swrad',swrad);
    ncwrite(nc,'lwrad',lwrad);
    ncwrite(nc,'lwrad_down',-lwrad_down);

    toc
end
