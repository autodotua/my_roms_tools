function roms_create_grid_core
    configs
    hold on
    cd(roms.project_dir)
    [lon,lat,dem_lon2,dem_lat2,dem_alt]=roms_get_grid_details(roms);
    mask=dem_alt<0; %将海拔<0的网格设置为1
    pcolorjw(dem_lon2,dem_lat2,mask);
    plot(lon,lat,'k-'); plot(lon',lat','k-');

    rho.lat=lat; rho.lon=lon;
    rho.depth=zeros(size(rho.lon))+100; % for now just make zeros
    rho.mask=zeros(size(rho.lon)); % for now just make zeros
    spherical='T';
    %projection='lambert conformal conic';
    projection='mercator';
    save temp.mat rho spherical projection %将三个变量保存到mat文件中
    mat2roms_mw('temp.mat',roms.input.grid);
    !del temp.mat %!用于调用cmd，删除mat

    F = scatteredInterpolant(dem_lon2(:),dem_lat2(:), double(mask(:)),'nearest'); %创建一个拟合函数
    %X(:)是将X变为列向量。
    %F = scatteredInterpolant(x,y,v) 创建一个拟合 v = F(x,y) 形式的曲面的插值。向量 x 和 y 指定样本点的 (x,y) 坐标。v 是一个包含与点 (x,y) 关联的样本值的向量。
    %Method 可以是 'nearest'、'linear' 或 'natural'。这里选择最邻近，是不连续的插值。猜测这么做是因为将二维的变为列向量以后，拥有突变点，所以只能使用最邻近方法。
    roms_mask=F(lon,lat); %
    %figure
    %pcolorjw(lon,lat,roms_mask)

    water = double(roms_mask); %从logical变成double
    u_mask = water(1:end-1,:) & water(2:end,:); %第一个是前n-1列，第二个是后n-1列，这个操作有点类似去尾法的取平均数
    v_mask= water(:,1:end-1) & water(:,2:end); %类似，取行的中间值，若一个1一个0则取0
    psi_mask= water(1:end-1,1:end-1) & water(1:end-1,2:end) & water(2:end,1:end-1) & water(2:end,2:end); %类似，取了单元格的中间值，若四个角有一个0则为0
    ncwrite(roms.input.grid,'mask_rho',roms_mask);
    ncwrite(roms.input.grid,'mask_u',double(u_mask));
    ncwrite(roms.input.grid,'mask_v',double(v_mask));
    ncwrite(roms.input.grid,'mask_psi',double(psi_mask));

    editmask(roms.input.grid,'f');
end