function draw_time_series_maps(filePath,zIndex,vars,names,months,monthNames,graph)
    arguments
        filePath(1,1) string %mat或nc文件
        zIndex(1,1) double %要取的层。如果zIndex>0，那么zIndex代表nc文件中实际索引（从深到浅）。如果zIndex<=0，则0代表表层，-1代表表层以下一层，以此类推。
        vars %变量名。
        % 可以提供字符串数组，每个变量一行。
        % 也可以提供字符串元胞，每个cell内包含一个或多个字符串。
        % 如果是1个字符串，那么该字符串就是变量名。
        % 如果提供多个字符串，本函数将读取这些字符串代表的变量然后相加后绘制。
        names(:,1) string %每个（对于cell类型的vars，组）变量的显示名称。
        months %指定每一个tile的时间。
        % 选择1：提供一个向量，对months中的每个month取平均绘图，每个month一列（例如1:12）。
        % 选择2：提供一个包含若干个double向量的cells（例如{3:5,6:8,9:11,[12,1,2]}），每个tile将绘制每个cell包含的月份的平均值
        monthNames(:,1) string=strings(0) %每个时间的显示名称。若months为向量，可省略。
        graph.colorRange(:,2)=[] %length(vars)行2列，表示每个变量的colormap范围。若为[]，表示自动。
        graph.colorBarLabels=[]
        graph.useSameColorRange(1,1) logical=0 %指定是否用一个(1,2)大小的colorRange表示所有变量的统一范围。
        graph.usePercentageColorRange(1,1) logical =0 %指定colorRange是否提供排序后值的百分位范围而非绝对值范围。
        % 如果usePercentageColorRange==true，
        % 那么colorRange(i,2)的两个值a，b分别表示colormap下限和上写分别为[a%, b%]
        % 例如，colorRange(i,2)=[2,98]，则表示将数据重新排序后，以最小2%为下限，最大2%为上限
        % 无论usePercentageColorRange==true或false，colorRange(i,:)均可为nan，表示自动取[0.1,99.9]的百分位。
        graph.labelPosition(1,1) string {mustBeMember(graph.labelPosition, {'title', 'rb', 'lt', 'rt', 'lb'})} = 'lt'
        graph.labelOffset(1,:) double=[0.03,0.03]
        graph.labelBackgroundTransparent=0
        graph.labelFontColor='black'
        graph.colorType='GMT_haxby'; %NCL colormap
    end

    if ~isempty(graph.colorRange)
        r=graph.colorRange;
        s=size(r);
        if graph.usePercentageColorRange
            assert(~any(isnan(r)),"colorRange not nan")
            if graph.useSameColorRange
                assert(isequal(s,[1,2]),"colorRange(1,2)")
            else
                assert(s(1)==length(vars),"colorRange row error")
                for i=1:s(1)
                    assert(r(i,1)+r(i,2)==100,"row "+string(i)+" sum != 100")
                end
            end
        else

            if graph.useSameColorRange
                assert(isequal(s,[1,2]),"colorRange(1,2)")
            else
                assert(s(1)==length(vars),"colorRange row error")
            end
        end
    end

    project_data
    tl=tiledlayout(length(vars),length(months));
    set_tiledlayout_compact(tl)
    times=roms_get_times(read_data(filePath,'ocean_time'));
    fileMonths=month(times);
    index=0;
    for i=1:length(vars)
        var=vars(i);
        if iscell(var)
            var=var{1};
        end
        minValue=1e10;
        maxValue=-1e10;
        minPercent=1;
        maxPercent=100-1;
        if graph.usePercentageColorRange && ~isempty(graph.colorRange)
            if graph.useSameColorRange
                minPercent=graph.colorRange(1,1);
                maxPercent=graph.colorRange(1,2);
            else
                minPercent=graph.colorRange(i,1);
                maxPercent=graph.colorRange(i,2);
            end
        end

        %读取数据
        varData=[];
        for k=1:length(var)
            disp(var(k))
            s=read_data(filePath,var(1),[],[],1);
            if length(s)==4
                tempVarData=read_data(filePath,var(1),[1,1,zIndex,1],[0,0,1,0]);
            else
                tempVarData=read_data(filePath,var(1));
            end
            if isempty(varData)
                varData=tempVarData;
            else
                varData=varData+tempVarData;
            end
        end

        for j=1:length(months)
            index=index+1;
            m=months(j);
            nexttile;
            if iscell(m)
                if isempty(monthNames)
                    error("当months为cells时，monthNames必须提供");
                end
                monthFilter=ismember(fileMonths,m{1});
            else
                monthFilter=fileMonths==m;
            end
            varDataT=varData(:,:,monthFilter);
            varDataT=mean(varDataT,3);
            minValue=min([prctile(varDataT,minPercent,'all'),minValue]);
            maxValue=max([prctile(varDataT,maxPercent,'all'),maxValue]);
            draw_map(varDataT,color=graph.colorType)
            hold on
            labelContent= sprintf('(%s) %s ', a2z_string(index), names(i));
            if iscell(months)
                labelContent=labelContent+monthNames(j);
            else
                labelContent=labelContent+strs.title_monthOf(m);
            end
            if graph.labelPosition=="title"
                title(labelContent);
            else
                text_corner(labelContent,graph.labelPosition,...
                    marginX=graph.labelOffset(1),marginY=graph.labelOffset(2), ...
                    backgroundTransparent=graph.labelBackgroundTransparent, ...
                    fontColor=graph.labelFontColor)
            end
            apply_font
        end
        c=colorbar;
        if ~isempty(graph.colorBarLabels)
            c.Label.String=graph.colorBarLabels(i);
        end
        for j=1:length(months)
            nexttile((i-1)*length(months)+j)
            if graph.usePercentageColorRange
                caxis([minValue,maxValue])
            elseif ~isempty(graph.colorRange)
                if graph.useSameColorRange
                    caxis(graph.colorRange(1,:));
                elseif ~isnan(graph.colorRange(i,1)) && ~isnan(graph.colorRange(i,2))
                    caxis(graph.colorRange(i,:));
                end
            end
        end
    end
end