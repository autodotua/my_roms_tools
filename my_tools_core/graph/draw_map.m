function draw_map(data,mapElements,gridType,graph)
    arguments
        data(:,:) double =[] %二维数据
        mapElements (1,1) string ="" %用于控制地图元素的字符串。根据其中包含的字符，显示指定内容。
        % l: 坐标标签
        % g: 网格
        % f: 边框
        gridType(1,1) string {mustBeMember(gridType,["rho","psi"])}="rho";
        graph.color='GMT_haxby'
    end
    switch gridType
        case "rho"
            [lon,lat,mask]=roms_load_grid_rho;
        case "psi"
            [lon,lat,mask]=roms_load_grid_psi;
    end

    if isempty(data)
        data=mask;
    end
    data(mask==0)=nan;

    latlim=[min(lat(:))+.05,max(lat(:))-.05];
    lonlim=[min(lon(:))+.05,max(lon(:))-.05];
    axesm(MapProjection= 'mercator',MapLatLimit=latlim,MapLonLimit=lonlim)
    gray=data;
    gray(:)=1;
    geoshow(lat,lon,gray,[.75,.75,.75],'DisplayType','image')
    lat(isnan(data))=nan;
    geoshow(lat,lon,data,'DisplayType','texturemap')
    tightmap
    if contains(mapElements,'f')
        framem on
    end
    if contains(mapElements,'l')
        plabel on
        mlabel on
    end
    if contains(mapElements,'g')
        gridm on
    end
    box off
    axis off
    setm(gca,'FLineWidth',2)
    setm(gca,'MLineLocation',4)
    setm(gca,'PLineLocation',4)
    setm(gca,'PLabelLocation',4)
    setm(gca,'MLabelLocation',4)
    setm(gca,'MLabelParallel','south')
    color_ncl(graph.color)

     if contains(mapElements,'l')
        mlabels=findobj(gca,'-class','matlab.graphics.primitive.Text','Tag','MLabel');
        %plabels=findobj(tl,'-class','matlab.graphics.primitive.Text','Tag','pLabel');
        for i=1:length(mlabels)
            label=mlabels(i);
            s=get(label,'String');
            if iscell(s)
                s=s{2}; %我的R2021b版本好像有BUG（或Feature），经度标签会变成两行，第一行是空的
                set(label,'String',s);
            end
        end
    end