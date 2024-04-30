function [points,waterPoint,outOfRange]=roms_get_xy_by_lonlat_core(locations,grid,type,from0,water,graph)
    arguments
        locations %位置坐标，支持字符串数组（["经度, 纬度"...]），或者数值矩阵（2列，先经度后纬度）
        grid="" %网格的经纬度、水陆掩膜信息，或用于读取坐标的nc文件，若不指定则为ROMS的grid文件
        type (1,1) string {mustBeMember(type,{'rho','u','v','psi'})} = 'rho' %坐标点类型
        from0 (1,1) logical=1 %索引是否从0开始
        water(1,1) logical=0 %是否只选择水点
        graph.enable(1,1) logical=1 %是否显示示意图
        graph.style_normal(1,1) string ='xr',
        graph.style_out_of_range(1,1) string ='xg',
        graph.label(1,1) logical=1
        graph.showWarnings(1,1) logical=1
    end

    configs
    lonlats=get_lonlat(locations);
    s=size(lonlats);
    points=zeros(s(1),2);
    waterPoint=false(s(1),1);
    outOfRange=zeros(s(1),1);
    if iscell(grid)
        lon_rho=grid{1};
        lat_rho=grid{2};
        mask=grid{3};
    else
        if isempty(grid) || grid==""
            grid=fullfile(roms.project_dir,roms.input.grid);
        end
        switch type
            case "rho"
                [lon_rho,lat_rho,mask]=roms_load_grid_rho(grid);
            case "psi"
                [lon_rho,lat_rho,mask]=roms_load_grid_psi(grid);
            otherwise
                error("不支持的坐标类型")
        end
    end
    if graph.enable
        pcolorjw(lon_rho,lat_rho,mask);
        hold on
    end
    s=size(lon_rho);

    i=0;
    if water
        for i=1:numel(lon_rho)
            if mask(i)==0
                lon_rho(i)=nan;
                lat_rho(i)=nan;
            end
        end
    end

    i=0;
    for location=lonlats'
        i=i+1;
        %         minDistance=1e100;
        %         minX=-1;
        %         minY=-1;
        %         tic
        %         for x=1:s(1)
        %             for y=1:s(2)
        %                 lon=lon_rho(x,y);
        %                 lat=lat_rho(x,y);
        %                 distance=sqrt((lon-location(1))^2+(lat-location(2))^2);
        %                 if distance<minDistance && (~water || mask(x,y)==1)
        %                     minDistance=distance;
        %                     minX=x;
        %                     minY=y;
        %                 end
        %             end
        %         end
        %         toc
        lonDistance=lon_rho-location(1);
        latDistance=lat_rho-location(2);
        %totalDistance=abs(lonDistance)+abs(latDistance);
        totalDistance=lonDistance.^2+latDistance.^2;
        [minDistance,minIndex]=min(totalDistance(:));
        minDistance=sqrt(minDistance);
        [minX,minY]=ind2sub(s,minIndex);

        points(i,:)=[minX-double(from0),minY-double(from0)];
        waterPoint(i)=logical(mask(minX,minY));
        if minDistance>0.05
            outOfRange(i)=1;
            if graph.showWarnings
                warning(['第',num2str(i),'个位置',char(strjoin(string( num2str(location)),',')),'可能位于网格以外，距离为',num2str(minDistance)]);
            end
            if graph.enable
                plot(lon_rho(minX,minY),lat_rho(minX,minY),graph.style_normal,'MarkerSize',16);
                if graph.label
                    text(lon_rho(minX,minY),lat_rho(minX,minY),num2str(i),'Color','g')
                end
            end
        else
            if graph.enable
                plot(lon_rho(minX,minY),lat_rho(minX,minY),graph.style_out_of_range,'MarkerSize',16);
                if graph.label
                    text(lon_rho(minX,minY),lat_rho(minX,minY),num2str(i),'Color','r')
                end
            end
        end
    end
    %disp(r);
end

function lonlat=get_lonlat(locations)
    if iscell(locations)
        locations=string(locations);
    end
    size_loc=size(locations);
    if isstring(locations)
        locations=reshape(locations,1,[]);
        n=numel(locations);
        lonlat=zeros(n,2);
        i=0;
        for location=locations
            i=i+1;
            parts=strsplit(location,',');
            if numel(parts)~=2
                error("无法解析位置字符串："+location)
            end
            lon=parts(1); lon=str2double(lon);
            lat=parts(2); lat=str2double(lat);
            lonlat(i,:)=[lon,lat];
        end
    elseif isnumeric(locations)
        if size_loc(2)~=2
            error("位置矩阵错误，需要有2列，每一行一个经纬度");
        end
        lonlat=locations;
    end
end