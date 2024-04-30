function draw_monthly_profile(filePath,var,direction,degrees,months,colorRange)
    arguments
        filePath(1,1) string %nc文件或mat文件
        var(1,1) string %变量名
        direction(1,1) string {mustBeMember(direction,["lon","lat"])} %剖面方向，沿什么方向切割
        degrees(:,1) double %需要剖的经度/纬度
        months(:,1) double {mustBeInteger} %需要显示的月份
        colorRange(2,1) double %色条的最小值和最大值
    end
    project_data
    configs
    tl=tiledlayout(length(degrees),length(months));
    set_tiledlayout_compact(tl);
    [lon_rho,lat_rho]=roms_load_grid_rho;
    %grid=get_roms_grid_info(fullfile(roms.project_dir,roms.input.grid));
    %z_rho=grid.z_r;  %z-lon-lat
    gridfile=fullfile(roms.project_dir,roms.input.grid);
    h=read_data(gridfile,'h');
    s_rho=read_data(gridfile,'Cs_r'); %这里用Cs_r好像是不均匀网格，s_rho是均匀网格，可能和Tcline有关。用s_rho是错误的（至少在h>Tcline的海域）。
    s_rho=reshape(s_rho,[1,1,length(s_rho)]);
    z_rho=repmat(h,1,1,length(s_rho)) .* repmat(s_rho,[size(h),1]);
    %这里的z_rho求出来和通过get_roms_grid_info的z_r相比，差了1.001~1.005倍，不清楚原因
    times=roms_get_times(read_data(filePath,"ocean_time"));
    fileMonths=month(times);
    rawVarData=read_data(filePath,var);
    for i=1:length(degrees)
        degree=degrees(i);
        disp("degree = "+degree)
        %只支持横平竖直的网格
        if direction=="lon"
            X=lat_rho(1,:);
            index=find(squeeze(lon_rho(:,1))>=degree,1);
            Y=z_rho(index,:,:);
        elseif direction=="lat"
            X=lon_rho(:,1);
            index=find(squeeze(lat_rho(1,:))>=degree,1);
            Y=z_rho(:,index,:);
        end
        X=repmat(X(:),1,size(z_rho,3)+1);
        Y=squeeze(Y);
        Y(:,end+1)=0;
        for j=1:length(months)
            m=months(j);
            disp("month = "+m)
            t=nexttile;
            monthFilter=fileMonths==m;
            varData=rawVarData(:,:,:,monthFilter);
            varData=mean(varData,4);
            if direction=="lon"
                Z=squeeze(varData(index,:,:));
                xlim([min(lat_rho,[],'all'),max(lat_rho,[],'all')])
            elseif direction=="lat"
                Z=squeeze(varData(:,index,:));
                xlim([min(lon_rho,[],'all'),max(lon_rho,[],'all')])
            end
            Z(:,end+1)=Z(:,end);

            hold on
            pcolorjw(X,Y,Z)
            color_red_yellow_green(20);
            title(var+" "+strs.title_monthOf(m) + "  " + degree + "°")
            apply_font
            ylim([min(Y,[],"all"),0])
            
            caxis(colorRange);
        end
    end
    c=colorbar;
    c.Layout.Tile = 'east';
    set_gcf_size(200*length(degrees),160*length(months))