function hycom_info=get_hycom_info(file,roms_grid_info,xvar,yvar,zvar)
    % 获取HYCOM文件的网格信息
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
    depth=ncread(file,zvar);
    lon(lon>=180)=(lon(lon>=180)-360);
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
    hycom_info.lons=double(lon(lon_index1:lon_index2));
    hycom_info.lats=double(lat(lat_index1:lat_index2));
    hycom_info.depths=double(depth);
    hycom_info.lon_index1=lon_index1;
    hycom_info.lon_index2=lon_index2;
    hycom_info.lat_index1=lat_index1;
    hycom_info.lat_index2=lat_index2;
end
