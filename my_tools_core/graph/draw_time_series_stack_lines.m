function draw_time_series_stack_lines(filePath,vars,varNames,locations,locationNames,window,graph)
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
    if mod(window,2)~=1
        error("window需要为奇数")
    end
    xy=roms_get_xy_by_lonlat_core(locations,enable=0);
    clf
    [~,times]=roms_get_times(read_data(filePath,"ocean_time"));
    times=times-times(1);
    if isnumeric(graph.rowColumn)
        tl=tiledlayout(graph.rowColumn(1),graph.rowColumn(2));
    else
        tl=tiledlayout(graph.rowColumn);
    end
    set_tiledlayout_compact(tl);
    for i=1:size(xy,1)
        p=xy(i,:);
        nexttile
        t=table('Size',[length(times),length(vars)+1],'VariableTypes',["double",repmat("double",1,length(vars))],VariableNames=["Times",vars']);
        t.Times=times/31+1; %转为月份显示
        disp(locationNames(i))
        for j=1:length(vars)
            var=vars(j);
            disp(var)

            if window==1
                data=squeeze(read_data(filePath,var,[p(1),p(2),1],[1,1,0]));
            else
                data=squeeze(read_data(filePath,var,[p(1)-(window-1)/2,p(2)-(window-1)/2,1],[window,window,0]));
                data=squeeze(mean(data,[1,2],'omitnan'));
            end
            if graph.smooth>0
                data=smoothdata(data,1,"movmean",graph.smooth);
            end
            t.(var)=data;
        end
        s=stackedplot(t,XVariable='Times',DisplayLabels=repmat("",1,length(vars)), ...
            GridVisible=1,XLabel="",LineWidth=graph.lineWidth);
        ax=flipud(findobj(s.NodeChildren, 'Type','Axes'));
        set(ax,'XTick',1:12)
        labelContent= sprintf('(%s) %s', a2z_string(i), locationNames(i));
        text_corner(labelContent,ax=ax(1));
        for j=1:length(vars)
            s.LineProperties(j).Color=graph.lineColors(j,:);
            if startsWith(vars(j),"NP")
                s.AxesProperties(j).YLimits=[1,1024];
                s.AxesProperties(j).YScale='log';
                axeses=findobj(s.NodeChildren, 'Type','Axes');
                a=axeses(j);
                set(a,'YTick',[1,4,16,64,256])
            else
                y=s.AxesProperties(j).YLimits;
                s.AxesProperties(j).YLimits=[y(1),y(2)+(y(2)-y(1))/3]; %给标签留出一点空间
            end
            text_corner(varNames(j),'rt',ax=ax(j));
        end
        apply_font
    end

end
