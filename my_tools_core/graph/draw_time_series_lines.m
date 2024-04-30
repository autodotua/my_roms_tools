function draw_time_series_lines(filePath,vars,varNames,locations,locationNames,window,graph)
    arguments
        filePath(1,1) string
        vars(:,1) string
        varNames(:,1) string
        locations(:,2) double
        locationNames(:,1) string
        window(1,1) double=1 %空间采样窗口。若为1，表示仅取指定点。若为n，表示取n*n的范围做平均。
        graph.logY(1,1) logical =0 %是否使用log坐标的Y轴
        graph.smooth(1,1) double =0 %平滑窗口，0表示不平滑
        graph.rawLines(1,1) logical =0 %当开启平滑时，是否显示未平滑的折线
        graph.lineWidth(1,1) double=2 %线宽
        graph.lineColors=[] %指定线条颜色，一行一个颜色，行数=length(positions)。若为空，则自动。
        graph.minData(1,1) double=1e-6 %限制数据最小值放置在平滑、log坐标时出现问题
        graph.rowColumn='flow' %行列配置
    end
    clf
    if mod(window,2)~=1
        error("window需要为奇数")
    end
    if isempty(vars)
        [vars,descs]=get_all_biology_vars;
    end
    times=roms_get_times(read_data(filePath,"ocean_time"));
    if isnumeric(graph.rowColumn)
        tl=tiledlayout(graph.rowColumn(1),graph.rowColumn(2));
    else
        tl=tiledlayout(graph.rowColumn);
    end
    set_tiledlayout_compact(tl);
    xy=roms_get_xy_by_lonlat_core(locations,enable=0);
    for i=1:length(vars)
        var=vars(i);
        if exist("descs","var")
            desc=descs(i);
        end
        disp(var)
        nexttile;
        if graph.smooth>0 && graph.rawLines
            for p=xy'
                data=squeeze(read_data(filePath,var,[p(1),p(2),1],[1,1,0]));
                if graph.logY
                    semilogy(times,data,Color=[.9,.9,.9],LineWidth=1.5*graph.lineWidth)
                else
                    plot(times,data,Color=[.9,.9,.9],LineWidth=1.5*graph.lineWidth)
                end
                hold on
            end
        end
        minValue=1e10;
        maxValue=1e-10;
        for j=1:size(xy,1)
            p=xy(j,:);
            if window==1
                data=squeeze(read_data(filePath,var,[p(1),p(2),1],[1,1,0]));
            else
                data=squeeze(read_data(filePath,var,[p(1)-(window-1)/2,p(2)-(window-1)/2,1],[window,window,0]));
                data=squeeze(mean(data,[1,2],'omitnan'));
            end
            if graph.smooth>0
                if graph.logY
                    data(data<graph.minData)=graph.minData;
                end
                data=smoothdata(data,1,"movmean",graph.smooth);
            end
            if graph.logY
                g=semilogy(times,data,LineWidth=graph.lineWidth);
            else
                g=plot(times,data,LineWidth=graph.lineWidth);
            end
            if ~isempty(graph.lineColors)
                g.Color=graph.lineColors(j,:);
            end
            hold on
            minValue=min([minValue;data]);
            maxValue=max([maxValue;data]);
        end

        minValue=minValue*0.9;
        maxValue=maxValue*1.1;
        ylim([minValue,maxValue])
        yticks([1e-4,2e-4,5e-4, ...
            1e-3,2e-3,5e-3, ...
            0.01,0.02,0.05, ...
            0.1,0.2,0.5, ...
            1,2,5, ...
            10,20,50,100])

        text_corner(varNames(i),"lt")
        if exist("desc","var")
            title(desc)
        end
        draw_border
        apply_font
        %set(gca,'XGrid','on')
        grid on
    end


    l=legend(locationNames,Location="east",Orientation="horizontal");
    l.Layout.Tile = 'south';
    apply_font

end
