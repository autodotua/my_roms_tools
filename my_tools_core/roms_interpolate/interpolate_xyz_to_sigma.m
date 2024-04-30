function result=interpolate_xyz_to_sigma(nc,xvar,yvar,zvar,var,type,dim,roms_grid_info,output_order,interpolate_method,depthValueFunc)
    %将XYZ网格插值为ROMS网格
    arguments
        nc(1,1) string %输入的XYZ坐标的nc文件
        xvar(1,1) string %nc文件的经度变量名
        yvar(1,1) string %nc文件的纬度变量名
        zvar(1,1) string %nc文件的深度变量名
        var(1,1) string %nc文件的值变量名
        type(1,1) string {mustBeMember(type,["u","v","rho",""])} %坐标类型
        dim(1,1) double {mustBeInRange(dim,2,3),mustBeInteger} %维度
        roms_grid_info struct =[] %ROMS网格信息。如果不提供，则自动检测
        output_order(1,1) string {mustBeMember(output_order,["xyz","zxy"])} ="zxy"; %返回值的维度顺序，深度优先或水平优先
        interpolate_method(1,1) string {mustBeMember(interpolate_method,["linear","nearest","natural","spline"])} ="spline"; %z转σ坐标的插值方法
        depthValueFunc(2,:) double=[];  %如果是二维的，可以通过指定一些深度以及每个深度的比值来扩充成三维并按三维进行处理
    end
    configs
    if isempty(roms_grid_info)
        roms_grid_info=get_roms_grid_info(roms.input.grid);
    end
    if dim==2
        zvar="";
    end
    input_info=get_xyz_data_info(nc,roms_grid_info,xvar,yvar,zvar);
    %创建XYZ数据大小的XZ坐标
    X=repmat(input_info.lons,1,length(input_info.lats));
    Y=repmat(input_info.lats,length(input_info.lons),1);
    if dim==3 || dim==2 && ~isempty(depthValueFunc) %三维数据，包括U、V、温度、盐度、示踪剂
        if dim==3
            levels=length(input_info.depths);
            %获取nc文件内的数据
            data=ncread(nc,var, ...
                [input_info.lon_index1 input_info.lat_index1 1 1], ...
                [input_info.lon_index2-input_info.lon_index1+1, ...
                input_info.lat_index2-input_info.lat_index1+1, ...
                levels,1 ]);
        else
            levels=size(depthValueFunc,2);
            input_info.depths=depthValueFunc(1,:);
            data=ncread(nc,var, ...
                [input_info.lon_index1 input_info.lat_index1 1], ...
                [input_info.lon_index2-input_info.lon_index1+1, ...
                input_info.lat_index2-input_info.lat_index1+1, ...
                1 ]);
            data=repmat(data,1,1,levels);
            for i=1:levels
                data(:,:,i)=data(:,:,i)*depthValueFunc(2,i);
            end
        end
        value=zeros(levels,roms_grid_info.Lm+2,roms_grid_info.Mm+2);
        %进行z坐标上的平面插值，从XYZ坐标转为ROMS坐标

        disp(['正在插值',char(var),'数据（共',num2str(levels),'层）']);
        lon_rho=roms_grid_info.lon_rho;
        lat_rho=roms_grid_info.lat_rho;
        X2=X(:);
        Y2=Y(:);
        disp("正在水平插值")
        parfor k=1:levels
            %fprintf([num2str(k),' '])
            tmp=double(squeeze(data(:,:,k))); %该层数据
            F = scatteredInterpolant(X2,Y2,tmp(:)); %创建插值函数
            r = F(lon_rho,lat_rho); %平面插值
            value(k,:,:)=fill_invalid_data(r); %外插到全部位置。这个外插和scatteredInterpolant用的不太一样，效果更好            
        end
        for k=1:levels
            if all(isnan(value(k,:,:)))
                if k==1
                    error("表层值为NaN")
                end
                value(k,:,:)=value(k-1,:,:);
            end
        end
        disp("正在垂直插值")
        result=interpolate_z_to_sigma(roms_grid_info,input_info.depths,value,type,interpolate_method); %在垂直方向上进行插值

        if output_order=="xyz"
            result=shiftdim(result,1); %从zxy转为xyz
        end

    elseif dim==2 %二维数据，主要是zeta
        data=ncread(nc,var, ...
            [input_info.lon_index1 input_info.lat_index1 1], ...
            [input_info.lon_index2-input_info.lon_index1+1, ...
            input_info.lat_index2-input_info.lat_index1+1, ...
            1 ]);
        disp(['正在插值',char(var),'数据']);
        tmp=double(squeeze(data(:,:)));
        F = scatteredInterpolant(X(:),Y(:),tmp(:)); %创建插值函数
        r = F(roms_grid_info.lon_rho,roms_grid_info.lat_rho); %平面插值
        result=fill_invalid_data(r); %外插到全部位置。这个外插和scatteredInterpolant用的不太一样，效果更好
    end
end