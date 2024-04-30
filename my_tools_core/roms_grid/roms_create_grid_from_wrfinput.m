function roms_create_grid_from_wrfinput
    configs
    cd(roms.project_dir)
    netcdf_load('wrfinput_d01') %会加载所有变量到工作区
    figure %生成绘图窗口
    pcolorjw(XLONG,XLAT,double(1-LANDMASK)) %pcolorjw是pcolor的一个扩展，能接受二维参数，绘制弯曲的网格
    hold on

    xl=roms.grid.longitude(1); xr=roms.grid.longitude(2);
    yb= roms.grid.latitude(1); yt= roms.grid.latitude(2);
    numx=roms.grid.size(1)+1; numy=roms.grid.size(2)+1;
    dx=(xr-xl)/numx; dy=(yt-yb)/numy; %x和y的分辨率
    [lon, lat]=meshgrid(xl:dx:xr, yb:dy:yt); %meshgrid将一维扩展到二维，lon的每一列都相等，lat的每一行都相等。都是65*87。
    lon=lon.';
    lat=lat.';
    %经过转置以后，都变为87*65，lon的每一行都相等，lat的每一列都相等
    plot(lon,lat,'k-')
    plot(lon',lat','k-')


    roms_grid=roms.input.grid;
    rho.lat=lat; rho.lon=lon;
    rho.depth=zeros(size(rho.lon))+100; % for now just make zeros
    rho.mask=zeros(size(rho.lon)); % for now just make zeros
    spherical='T';
    %projection='lambert conformal conic';
    projection='mercator';
    save temp_jcw33.mat rho spherical projection %将三个变量保存到mat文件中
    eval(['mat2roms_mw(''temp_jcw33.mat'',''',roms_grid,''');']) %用于将mat中的网格数据转为ROMS文件。执行mat2roms_mw('temp_jcw33.mat',roms_grid);
    !del temp_jcw33.mat %!用于调用cmd，删除mat
    !del roms_grid_ijcst_f.mat

    F = scatteredInterpolant(double(XLONG(:)),double(XLAT(:)), double(1-LANDMASK(:)),'nearest'); %创建一个拟合函数
    %X(:)是将X变为列向量。
    %F = scatteredInterpolant(x,y,v) 创建一个拟合 v = F(x,y) 形式的曲面的插值。向量 x 和 y 指定样本点的 (x,y) 坐标。v 是一个包含与点 (x,y) 关联的样本值的向量。
    %Method 可以是 'nearest'、'linear' 或 'natural'。这里选择最邻近，是不连续的插值。猜测这么做是因为将二维的变为列向量以后，拥有突变点，所以只能使用最邻近方法。
    roms_mask=F(lon,lat); %
    %figure
    %pcolorjw(lon,lat,roms_mask)

    water = double(roms_mask);
    u_mask = water(1:end-1,:) & water(2:end,:); %第一个是前n-1列，第二个是后n-1列，这个操作有点类似去尾法的取平均数
    v_mask= water(:,1:end-1) & water(:,2:end); %类似，取行的中间值，若一个1一个0则取0
    psi_mask= water(1:end-1,1:end-1) & water(1:end-1,2:end) & water(2:end,1:end-1) & water(2:end,2:end); %类似，取了单元格的中间值，若四个角有一个0则为0
    ncwrite(roms_grid,'mask_rho',roms_mask);
    ncwrite(roms_grid,'mask_u',double(u_mask));
    ncwrite(roms_grid,'mask_v',double(v_mask));
    ncwrite(roms_grid,'mask_psi',double(psi_mask));

    editmask(roms_grid,'f');
end