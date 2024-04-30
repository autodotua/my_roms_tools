function r=show_value_change_core(options)
    %显示某一点或某一柱或某一片的值随时间的变化
    arguments
        options.file(1,1) string="" %nc文件名
        options.varname(1,1) string="" %变量名。如果是uv，则是u和v的平方和的平方根。
        options.data(:,:,:,:) double=[] %直接提供数据
        options.step_per_day(1,1) double {mustBePositive}=1, %每一天包含多少个时间步长
        options.position(:,1) int16 {mustBeInteger,mustBePositive}=[] %位置。如果为空，则为全部区域。1/2/3维分别为整层/柱/点
        options.type(1,1) string {mustBeMember(options.type,["sum","ave"])}="sum" %sum或ave，表示总和（用于质量/体积）或平均（用于浓度/速度/温度/盐度等）
        options.show_graph logical=true %是否显示图表
        options.smooth(1,1) double {mustBeInteger}=0 %平滑窗口大小，0为不平滑
        options.time_range(:,1) double {mustBeInteger,mustBePositive}=[] %时间范围，分别为开始时刻和结束时刻
        options.ratio(1,1) double=1
        options.legend_name(1,1) string='', %图例名
    end
    if isempty(options.data)
        if string(options.varname)=="uv"
            if ~isnumeric(options.position)|| numel(options.position)~=2 && numel(options.position)~=3
                error("uv时，必须指定位置或坐标");
            end
            p=options.position; u1=read_nc_data(options.file,'u',p,options.time_range);
            p(2)=p(2)+1; u2=read_nc_data(options.file,'u',p,options.time_range);
            u=0.5*(u1+u2);
            p=options.position; v1=read_nc_data(options.file,'v',p,options.time_range);
            p(1)=p(1)+1; v2=read_nc_data(options.file,'v',p,options.time_range);
            v=0.5*(v1+v2);
            data=u.^2+v.^2;
            clear u1 u2 v1 v2 u v
            data=sqrt(data);
        else
            data=read_nc_data(options.file,options.varname,options.position,options.time_range);
        end
    else
        data=read_memory_data(options.data,options.position,options.time_range);
    end

    info=whos('data');
    disp("数据加载完成，大小："+string(info.bytes/(1024*1024))+"MB")

    s=size(data);

    if isequal(options.position,'all')
        r=squeeze(sum(data,[1,2,3],'omitnan'));
        if options.type=="ave"
            r=r/(s(1)*s(2)*s(3));
        end
    elseif isnumeric(options.position)
        switch numel(options.position)
            case 2
                r=squeeze(sum(data(1,1,:,:),3,'omitnan'));
                if options.type=="ave"
                    r=r/s(3);
                end
            case 3
                r=squeeze(data);
        end

    else
        error('未知位置格式');
    end
    if options.smooth>0
        r=smoothdata(r,'gaussian',options.smooth);
    end
    r=r.*options.ratio;
    disp("数据处理完成")
    if options.show_graph
        x=0:1/options.step_per_day:numel(r)/options.step_per_day;
        x=x(2:end)';
        figure(1)
        hold on
        plot(x,r,'-',"DisplayName",options.legend_name);
        xlabel('时间（天）')
        ylabel('值')
        legend
        hold off
    end
end

function r=read_memory_data(data,position,time_range)
    if ndims(data)~=4
        error("数据维度必须为4");
    end

    switch numel(time_range)
        case 2
            data=data(:,:,:,time_range(1):time_range(2));
        case 1
            data=data(:,:,:,1:time_range);

    end

    switch numel(position)
        case 1
            data=data(:,:,position,:);
        case 2
            data=data(position(1),position(2),:,:);
        case 3
            data=data(position(1),position(2),position(3),:);
    end
    r=data;
end

function r=read_nc_data(file,var,position,time_range)
    try
        nc=netcdf.open(file);
        var_id=netcdf.inqVarID(nc,var);
        [~,~,dimids,~] = netcdf.inqVar(nc,var_id);

        if numel(dimids)~=4
            error("数据维度必须为4");
        end
        start=ones(4,1);
        count=ones(4,1);
        i=0;
        for id=dimids
            i=i+1;
            [~,count(i)]=netcdf.inqDim(nc,id);
        end

        switch numel(position)
            case 1
                start(3)=position(1);
                count(3)=1;
            case 2
                start=[position(1:2)',start(3),start(4)];
                count=[1,1,count(3),count(4)];
            case 3
                start=[position(1:3)',start(4)'];
                count=[1,1,1,count(4)];
        end
        switch numel(time_range)
            case 2
                start(end)=time_range(1);
                count(end)=time_range(2)-time_range(1)+1;
            case 1
                count(end)=time_range(2);

        end

        r=netcdf.getVar(nc,var_id,start-1,count);
        netcdf.close(nc);
    catch ex
        netcdf.close(nc);
        rethrow(ex)
    end
end
