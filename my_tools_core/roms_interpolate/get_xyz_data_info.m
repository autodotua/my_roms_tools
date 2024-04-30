function xyz_data_info=get_xyz_data_info(file,roms_grid_info,xvar,yvar,zvar)
    arguments
        file(1,1) string
        roms_grid_info
        xvar(1,1) string
        yvar(1,1) string
        zvar(1,1) string
    end

    lon=ncread(file,xvar);
    lat=ncread(file,yvar);
    lat=lat';
    if zvar~=""
        depth=ncread(file,zvar);
    end
    %lon(lon>=180)=(lon(lon>=180)-360);

    %为了方便处理，需要保证所有经度都在0到360度。即，需要把西半球的经度进行翻转
    if lon(1)<0 %说明网格范围是-180到180。
        lon(lon<0)=lon(lon<0)+360;
    end

    %ROMS网格的范围
    xl=min(min(roms_grid_info.lon_rho));xr=max(max(roms_grid_info.lon_rho));
    yb=min(min(roms_grid_info.lat_rho));yt=max(max(roms_grid_info.lat_rho));

    %获取边界范围
    lon_indexs = find(lon>=xl & lon<=xr);
    lat_indexs = find(lat>=yb & lat<=yt);

    %获取边界索引
    lon_index1=min(lon_indexs)-1;
    lon_index2=max(lon_indexs)+1;
    lat_index1=min(lat_indexs)-1;
    lat_index2=max(lat_indexs)+1;

    lon_index1 = max(lon_index1, 1);
    lat_index1 = max(lat_index1, 1);
    lon_index2 = min(lon_index2, length(lon));
    lat_index2 = min(lat_index2, length(lat));

    %写入信息
    xyz_data_info.lons=double(lon(lon_index1:lon_index2));
    xyz_data_info.lats=double(lat(lat_index1:lat_index2));
    if zvar~=""
        xyz_data_info.depths=double(depth);
    end
    xyz_data_info.lon_index1=lon_index1;
    xyz_data_info.lon_index2=lon_index2;
    xyz_data_info.lat_index1=lat_index1;
    xyz_data_info.lat_index2=lat_index2;
end