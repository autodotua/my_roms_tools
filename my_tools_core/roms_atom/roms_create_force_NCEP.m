function roms_create_force_NCEP(repeat_years)
    arguments
        repeat_years(1,1) double =1
    end
    offset=datetime(2020,1,1)-datetime(2020,1,1);
    tic
    configs

    nc =fullfile(roms.project_dir,roms.input.atom);

    if repeat_years>1 && roms.time.stop(1)>roms.time.start(1)
        roms.time.stop=[roms.time.start(1),12,31];
    end
    time_start = datenum(roms.time.start);
    time_end   = datenum(roms.time.stop);

    %确定网格

    [lon_rho,lat_rho]=roms_load_grid_rho(fullfile(roms.project_dir,roms.input.grid));

    level=1; %用师兄的代码跑不了，发现部分变量好像有好几层，所以加了一个选第一层的代码。

    times = (time_start:roms.res.force_ncep_step/24:time_end) - datenum(roms.time.base);
    nctimes=times;
    ntimes = length(times);

    %生成网格
    time = datestr(times(1) + datenum(roms.time.base)+offset,'yyyymmddTHHMMSS');
    file = fullfile(roms.res.force_ncep_dir, "fnl_"+string(time(1:8))+"_"+string(time(10:11))+"_"+string(time(12:13))+".grib2");
    geo = ncgeodataset(char(file));
    ncep_lon=double(geo{'lon'}(:));
    ncep_lat=flip(double(geo{'lat'}(:)));
    close(geo);
    [LON,LAT]=meshgrid(ncep_lon,ncep_lat);
    LON=LON';
    LAT=LAT';

    %计算ROMS网格范围
    lon_min=min(lon_rho,[],'all');
    lon_max=max(lon_rho,[],'all');
    lat_min=min(lat_rho,[],'all');
    lat_max=max(lat_rho,[],'all');

    %计算在ERA5网格中需要裁切的行列序号范围
    x1=find(ncep_lon>=lon_min,1)-2;
    x2=find(ncep_lon> lon_max,1)+1;
    y1=find(ncep_lat>=lat_min,1)-2;
    y2=find(ncep_lat> lat_max,1)+1;
    width=x2-x1+1;
    height=y2-y1+1;


    %预分配
    fill = zeros([width,height,ntimes*repeat_years]);
    rain = fill;
    Tair = fill;
    Pair = fill;
    Qair = fill;
    Uwind = fill;
    Vwind = fill;

    %开始处理
    for t = 1:ntimes
        time = datestr(times(t) + datenum(roms.time.base)+offset,'yyyymmddTHHMMSS');
        file = fullfile(roms.res.force_ncep_dir, "fnl_"+string(time(1:8))+"_"+string(time(10:11))+"_"+string(time(12:13))+".grib2");
        disp(['正在处理：',time])
        geo = ncgeodataset(char(file));

        %插值
        data=getGrib2Value(geo,'Temperature_height_above_ground',{@(var) var - 273.15,@(var) var(level,:,:)});
        Tair(:,:,t)=data(x1:x2,y1:y2);

        data=getGrib2Value(geo,'Pressure_surface', {@(var) var*0.01});
        Pair(:,:,t)=data(x1:x2,y1:y2);

        data=getGrib2Value(geo,'Relative_humidity_height_above_ground',{});
        Qair(:,:,t)=data(x1:x2,y1:y2);


        data=getGrib2Value(geo,'U-component_of_wind_height_above_ground',{@(var) var(level,:,:)});
        Uwind(:,:,t)=data(x1:x2,y1:y2);

        data=getGrib2Value(geo,'V-component_of_wind_height_above_ground',{@(var) var(level,:,:)});
        Vwind(:,:,t)=data(x1:x2,y1:y2);

        close(geo);
    end

    timeOffsets=times-times(1)+1;
    for repeat=1:repeat_years-1
        Tair(:,:,repeat*ntimes+1:(repeat+1)*ntimes)=Tair(:,:,1:ntimes);    
        Pair(:,:,repeat*ntimes+1:(repeat+1)*ntimes)=Pair(:,:,1:ntimes);    
        Qair(:,:,repeat*ntimes+1:(repeat+1)*ntimes)=Qair(:,:,1:ntimes);    
        Uwind(:,:,repeat*ntimes+1:(repeat+1)*ntimes)=Uwind(:,:,1:ntimes);    
        Vwind(:,:,repeat*ntimes+1:(repeat+1)*ntimes)=Vwind(:,:,1:ntimes);
        
        nctimes(end+1:end+ntimes)=nctimes(end)+timeOffsets;
    end 

    %异常值处理
    Tair(Tair<-100) = 0;
    Pair(Pair<0) = 0;
    Qair(Qair<0) = 0;
    Uwind(Uwind<-100) = 0;
    Vwind(Vwind<-100) = 0;
    Uwind(Uwind>100) = 0;
    Vwind(Vwind>100) = 0;
    rain(:)=0;


    %创建nc
    ncid = netcdf.create(nc,'NETCDF4');

    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'type', 'bulk fluxes forcing file');
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'gridid','combined grid');
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'history',['Created by "' mfilename '" on ' datestr(now)]);

    lon_dimID = netcdf.defDim(ncid,'xr',width);
    lat_dimID = netcdf.defDim(ncid,'er',height);
    t_dimID = netcdf.defDim(ncid,'time',ntimes*repeat_years);

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


    UwindID = netcdf.defVar(ncid,'Uwind','double',[lon_dimID lat_dimID t_dimID]);
    netcdf.putAtt(ncid,UwindID,'long_name','surface u-wind component');
    netcdf.putAtt(ncid,UwindID,'units','meter second-1');
    netcdf.putAtt(ncid,UwindID,'field','Uwind, scalar, series');
    netcdf.putAtt(ncid,UwindID,'coordinates','lon lat');
    netcdf.putAtt(ncid,UwindID,'time','time');

    VwindID = netcdf.defVar(ncid,'Vwind','double',[lon_dimID lat_dimID t_dimID]);
    netcdf.putAtt(ncid,VwindID,'long_name','surface v-wind component');
    netcdf.putAtt(ncid,VwindID,'units','meter second-1');
    netcdf.putAtt(ncid,VwindID,'field','Vwind, scalar, series');
    netcdf.putAtt(ncid,VwindID,'coordinates','lon lat');
    netcdf.putAtt(ncid,VwindID,'time','time');


    PairID = netcdf.defVar(ncid,'Pair','double',[lon_dimID lat_dimID t_dimID]);
    netcdf.putAtt(ncid,PairID,'long_name','surface air pressure');
    netcdf.putAtt(ncid,PairID,'units','millibar');
    netcdf.putAtt(ncid,PairID,'field','Pair, scalar, series');
    netcdf.putAtt(ncid,PairID,'coordinates','lon lat');
    netcdf.putAtt(ncid,PairID,'time','time');

    TairID = netcdf.defVar(ncid,'Tair','double',[lon_dimID lat_dimID t_dimID]);
    netcdf.putAtt(ncid,TairID,'long_name','surface air temperature');
    netcdf.putAtt(ncid,TairID,'units','Celsius');
    netcdf.putAtt(ncid,TairID,'field','Tair, scalar, series');
    netcdf.putAtt(ncid,TairID,'coordinates','lon lat');
    netcdf.putAtt(ncid,TairID,'time','time');

    QairID = netcdf.defVar(ncid,'Qair','double',[lon_dimID lat_dimID t_dimID]);
    netcdf.putAtt(ncid,QairID,'long_name','surface air relative humidity');
    netcdf.putAtt(ncid,QairID,'units','percentage');
    netcdf.putAtt(ncid,QairID,'field','Qair, scalar, series');
    netcdf.putAtt(ncid,QairID,'coordinates','lon lat');
    netcdf.putAtt(ncid,QairID,'time','time');

    rainID = netcdf.defVar(ncid,'rain','double',[lon_dimID lat_dimID t_dimID]);
    netcdf.putAtt(ncid,rainID,'long_name','rain fall rate');
    netcdf.putAtt(ncid,rainID,'units','kilogram meter-2 second-1');
    netcdf.putAtt(ncid,rainID,'field','rain, scalar, series');
    netcdf.putAtt(ncid,rainID,'coordinates','lon lat');
    netcdf.putAtt(ncid,rainID,'time','time');

    netcdf.close(ncid)

    %写入数据
    ncwrite(nc,'lon',LON(x1:x2,y1:y2));
    ncwrite(nc,'lat',LAT(x1:x2,y1:y2));
    ncwrite(nc,'time',nctimes);
    ncwrite(nc,'rain',rain);
    ncwrite(nc,'Tair',Tair);
    ncwrite(nc,'Pair',Pair);
    ncwrite(nc,'Qair',Qair);
    ncwrite(nc,'Uwind',Uwind);
    ncwrite(nc,'Vwind',Vwind);

    toc
end


function var=getGrib2Value(geo,var_name,var_funcs)
    var = double(squeeze(geo{var_name}(:)));
    for func=var_funcs
        var=func{1}(var);
    end
    var=rot90(squeeze(var),-1);
end