function roms_add_radiations_NCEP
    %ds083.3
    configs
    frcfile=fullfile(roms.project_dir,roms.input.force);
    frclon=ncread(frcfile,"lon");
    frclat=ncread(frcfile,"lat");
    swrads=ncread(frcfile,"swrad");
    lwrads=ncread(frcfile,"lwrad");
    lwrad_downs=ncread(frcfile,"lwrad_down");
    i=0;
    for time=ncread(frcfile,'time')'
        dt=datetime(roms.time.base)+time;
        dt.Format="yyyyMMddHH";
        disp("正在处理"+string(dt));
        inputfile=replace(roms.res.force_ncep_radiation_files,'yyyymmddhh',char(dt));
        inputlon=double(ncread(inputfile,"lon"));
        inputlat=double(ncread(inputfile,"lat"));
        swrad=ncread(inputfile,"DSWRF_L1_Avg_1")-ncread(inputfile,"USWRF_L1_Avg_1");
        lwrad=ncread(inputfile,"DLWRF_L1_Avg_1")-ncread(inputfile,"ULWRF_L1_Avg_1");
        lwrad_down=ncread(inputfile,"DLWRF_L1_Avg_1");
        swrad=get_value(frclon,frclat,inputlon,inputlat,swrad);
        lwrad=get_value(frclon,frclat,inputlon,inputlat,lwrad);
        lwrad_down=get_value(frclon,frclat,inputlon,inputlat,lwrad_down);
        i=i+1;
        swrads(:,:,i)=swrad;
        lwrads(:,:,i)=lwrad;
        lwrad_downs(:,:,i)=lwrad_down;
    end

    ncwrite(frcfile,"swrad",swrads);
    ncwrite(frcfile,"lwrad",lwrads);
    ncwrite(frcfile,"lwrad_down",lwrad_downs);
end

function result=get_value(xr,er,lon,lat,value)
    if numel(lon)==length(lon)
        [lon,lat]=meshgrid(lon,lat);
    end
    F = scatteredInterpolant(lon(:),lat(:),value(:));
    result = F(xr,er);
    result(isnan(result)) = 0;
end
