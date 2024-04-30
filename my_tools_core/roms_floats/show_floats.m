function show_floats(nc,n,timeFilter,floatFilter,tile,namesLabel,timesLabel)
    arguments
        nc(1,1) string %漂浮子nc文件
        n(:,1) double {mustBeInteger,mustBePositive} %每组漂浮子的数量
        timeFilter(:,1)  =[] %时间筛选。可以提供一个数字n，表示显示每个粒子前n天的轨迹；
        % 也可以提供一个数字数组[n1,n2,...,nm]，表示绘制每个粒子前n1,n2,...,nm天的轨迹；
        % 也可以提供一个长度为2的datetime数字，表示只取该时间段内的粒子
        floatFilter double =[] %漂浮子筛选，提供一个[n,m]的logical数组，n表示组数，m表示每组数量。
        tile(2,1) double=[0,0] %绘图时的tile的行列
        namesLabel(:,1) string=[] %每个tile的标题
        timesLabel(:,1) string=[] %当timeFilter为数字数组时，需要提供每个时间的标签
    end
    configs

    %% 预处理
    [lon_rho,lat_rho,mask_rho]=roms_load_grid_rho;
    mask_rho(mask_rho==0)=nan;
    if tile(1)==0
        tile=[];
    end
    colormap([1,1,1])
    set_gcf_size(tile(2)*145,tile(1)*200)

    %% 不需要画多幅时，绘制底图
    if isempty(tile)
        clf
        draw_background(lon_rho,lat_rho)
        hold on;
        pcolorjw(lon_rho,lat_rho,mask_rho);
        equal_aspect_ratio(gca)
        xticks([]);
        yticks([]);
    else
        tl=tiledlayout(tile(1),tile(2));
        set_tiledlayout_compact(tl);
    end

    %% 读取轨迹
    lons=ncread(nc,'lon');
    lats=ncread(nc,'lat');

    %% 读取和处理时间
    [datetimes,timenums]=roms_get_times(ncread(nc,'ocean_time'),0);
    if exist('timeFilter','var') && ~isempty(timeFilter) && isdatetime(timeFilter) && length(timeFilter)==2
        timeFilter=datetimes>timeFilter(1) & datetimes<timeFilter(2);
        lons=lons(:,timeFilter);
        lats=lats(:,timeFilter);
    end
    timeStep=timenums(2)-timenums(1);

    %% 检查参数
    if size(lons,1)~=sum(n)
        warning("n的长度与实际不匹配");
    end

    if exist('floatFilter','var') && ~isempty(floatFilter)
        if numel(floatFilter)~=sum(n)
            error("floatFilter的长度与实际不匹配");
        end
    end

    %% 预置颜色
    colors = [
        0.00, 0.45, 0.74;   % 深蓝色
        0.85, 0.33, 0.10;   % 深橙色
        0.93, 0.69, 0.13;   % 深黄色
        0.49, 0.18, 0.56;   % 深紫色
        0.47, 0.67, 0.19;   % 深绿色
        0.30, 0.75, 0.93;   % 浅蓝色
        0.64, 0.08, 0.18;   % 深红色
        0.96, 0.51, 0.76;   % 浅粉色
        0.11, 0.62, 0.47;   % 深青色
        0.98, 0.60, 0.07;   % 橙色
        0.99, 0.75, 0.07;   % 金色
        0.67, 0.33, 0.00;   % 棕色
        0.94, 0.89, 0.26;   % 浅黄色
        0.89, 0.10, 0.11;   % 红色
        0.23, 0.44, 0.33;   % 深墨绿色
        0.89, 0.47, 0.20;   % 浅橙色
        0.52, 0.53, 0.53;   % 灰色
        0.83, 0.13, 0.19;   % 暗红色
        0.18, 0.55, 0.34;   % 深翠绿色
        0.80, 0.36, 0.36    % 深粉红色
        ];


    %% 绘制轨迹
    a2z=a2z_string;
    timesCount=1;
    if isvector(timeFilter) && isnumeric(timeFilter(1))
        timesCount=length(timeFilter);
    end
    for t=1:timesCount
    i=0;
    for j=1:length(n)

        %底图
        if ~isempty(tile)
            nexttile
            draw_background(lon_rho,lat_rho)
            hold on;
            pcolorjw(lon_rho,lat_rho,mask_rho);
            equal_aspect_ratio(gca)
            xticks([]);
            yticks([]);
        end

        % 同一个点出发的漂浮子作为一组
        for k=1:n(j)
            i=i+1;

            %筛选漂浮子
            if exist('floatFilter','var') && ~isempty(floatFilter)
                if ~floatFilter(j,k)
                    continue
                end
            end
            lonLine=lons(i,:);
            latLine=lats(i,:);

            %如果是指定时长，需要在此处筛选
            if exist('timeFilter','var') && ~isempty(timeFilter) && isnumeric(timeFilter(1))
                index1=find(lonLine>0,1);
                if isempty(index1)
                    continue
                end
                count=timeFilter(t)/timeStep;
                index2=index1+count;
                if index2>length(lonLine)
                    index2=length(lonLine);
                end
                index2=int32(index2);
                lonLine=lonLine(index1:index2);
                latLine=latLine(index1:index2);
            end

            %去除不需要画的线
            f=lonLine>0 & latLine>0;
            if isempty(find(f,1))
                continue
            end
            lonLine=lonLine(f);
            latLine=latLine(f);

            %绘制
            plot(lonLine,latLine,LineWidth=1,Color=[colors(j,:),0.5]);
        end
    end

    %% 绘制出发点
    i=1;
    for j=1:length(n)
        if ~isempty(tile)
            nexttile(j)
        end
        tempLons=lons(i+1,:);
        tempLats=lats(i+1,:);
        index=find(tempLons>0,1);
        if ~isempty(find(index,1))
            scatter(tempLons(index),tempLats(index),16,'filled',MarkerEdgeColor='w',MarkerFaceColor=colors(j,:))
            %plot(tempLons(index),tempLats(index),'.', MarkerEdgeColor='w',MarkerFaceColor=colors(j,:),MarkerSize=16);
        end
        i=i+n(j);
    end
    %% 绘制图元素

    if ~isempty(tile)
        for j=1:length(n)
            i=(t-1)*length(n)+j;
            nexttile(i)
%             if j==1 && timesCount>1
%                 ylabel(timesLabel(t))
%             end
            str="("+a2z(i)+") "+namesLabel(j);
            if timesCount>1
                str=str+" "+timesLabel(t);
            end
            if ~isempty(namesLabel)
                text_left_top(str)
            end
            draw_border
            apply_font
        end
    end

    end
end