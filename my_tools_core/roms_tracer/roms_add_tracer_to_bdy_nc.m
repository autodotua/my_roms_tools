function roms_add_tracer_to_bdy_nc(ncfile,varName,value,times,units,nc_dims)
    arguments
        ncfile(1,1) string
        varName(1,1) string
        % value值可以有多种选择。
        % (1,1) (1,t): 表示对所有边界、所有时间使用一个恒定值
        % (n,1) (n,t): 表示对所有边界，每一个高度层使用相同的相同的值。其中n为层数，顺序与ROMS顺序相同（从底到顶）
        % (x,y,z) (x,y,z,t): 表示提供与ROMS网格大小相同的数据范围，由程序切割
        % 结构体，包含east、west、south、north四个字段
        %       其中east、west字段为(height,n) (height,n,t)，south、north字段为(width,n) (width,n,t)。
        %       也可以都为(1,1) (1,t)或(n,1) (n,t)
        % 所有类型的数组可以在最后增加一个时间维度，若不加的话，所有时间维度将使用相同值
        value
        times(1,:) double
        units(1,1) string
        nc_dims.dim_x(1,1) string="xrho"
        nc_dims.dim_y(1,1) string="erho"
        nc_dims.dim_z(1,1) string="s_rho"
    end

    configs
    value=normalizeValue(value,length(times));
    info=ncinfo(ncfile);
    nc=netcdf.open(ncfile,'WRITE');
    try
        timeName=varName+"_time";
        if(~any(ismember({info.Dimensions.Name},timeName)))
            bio_time_dim = netcdf.defDim(nc,timeName,length(times));
            bio_time_var = netcdf.defVar(nc,timeName,'double',bio_time_dim);
            netcdf.putAtt(nc,bio_time_var,'long_name',timeName);
            netcdf.putAtt(nc,bio_time_var,'units','days');
            netcdf.putAtt(nc,bio_time_var,'field',timeName+", scalar, series");
        end
        create_single_bdy_var(nc,info,varName,units,nc_dims,timeName,"east");
        create_single_bdy_var(nc,info,varName,units,nc_dims,timeName,"west");
        create_single_bdy_var(nc,info,varName,units,nc_dims,timeName,"north");
        create_single_bdy_var(nc,info,varName,units,nc_dims,timeName,"south");
        netcdf.close(nc)
    catch ex
        netcdf.close(nc)
        rethrow(ex)
    end

    ncwrite(ncfile,timeName,times)
    for side=["east","west","south","north"]
        varSideName=varName+"_"+side;
        ncwrite(ncfile,varSideName,value.(side))
        disp("已写入到"+varSideName)
    end
end

function result=normalizeValue(value,timeLength)
    configs
    romsGridInfo=get_roms_grid_info(roms.input.grid);
    s=size(value);
    if isstruct(value)
        result.east=checkAndNormalizeBasicValue(value.east,timeLength,romsGridInfo,romsGridInfo.Mm+2);
        result.west=checkAndNormalizeBasicValue(value.west,timeLength,romsGridInfo,romsGridInfo.Mm+2);
        result.north=checkAndNormalizeBasicValue(value.north,timeLength,romsGridInfo,romsGridInfo.Lm+2);
        result.south=checkAndNormalizeBasicValue(value.south,timeLength,romsGridInfo,romsGridInfo.Lm+2);
    elseif isequal(s,size(romsGridInfo.h))...  %(x,y,z)
            || isequal(s,size(romsGridInfo.Hz)) ... %(x,y,z,t)
            || ndims(value)==4 && isequal(s(1:3),size(romsGridInfo.Hz)) && s(4)==timeLength %(x,y,z,t)
        result=checkAndNormalizeBasicValue(value,timeLength,romsGridInfo);
    else
        temp=checkAndNormalizeBasicValue(value,timeLength,romsGridInfo,romsGridInfo.Mm+2);
        result.east=temp;
        result.west=temp;
        temp=checkAndNormalizeBasicValue(value,timeLength,romsGridInfo,romsGridInfo.Lm+2);
        result.north=temp;
        result.south=temp;
    end
end


function result=checkAndNormalizeBasicValue(value,timeLength,romsGridInfo,width)
    %检查并正规化数据到为[宽度，深度层，时间]
    if nargin==3
        width=0;
    end
    %给不带时间的value增加时间维度
    if length(value)==1 %(1,1)
        value=repmat(value(:),1,timeLength);
    elseif iscolumn(value) %(n,1)
        value=repmat(value(:),1,timeLength);
    elseif ismatrix(value) && isequal(size(value,1),width) && isequal(size(value,2),romsGridInfo.N) %(width,n)
        value=repmat(value,1,1,timeLength);
    elseif ismatrix(value) && isequal(size(value,1),romsGridInfo.Lm+2) && isequal(size(value,2),romsGridInfo.Mm+2) %(x,y)
        value=repmat(value,1,1,romsGridInfo.N,timeLength);
    elseif ndims(value)==3 && isequal(size(value),size(romsGridInfo.Hz)) %(x,y,z)
        value=repmat(value,1,1,1,timeLength);
    end

    result=zeros([width,romsGridInfo.N,timeLength]);

    % 将值正规化为[宽度，深度层，时间]
    if isrow(value) %(1,t)
        if length(value)~=timeLength
            error("时间维度错误")
        end
        for t=1:timeLength
            result(:,:,t)=value(t);
        end
    elseif ismatrix(value) %(n,t)
        if size(value,1)~=romsGridInfo.N
            error("深度维度错误")
        end
        if size(value,2)~=timeLength
            error("时间维度错误")
        end

        for t=1:timeLength
            for n=1:romsGridInfo.N
                result(:,n,t)=value(n,t);
            end
        end
    elseif ndims(value)==3 %(width,n,t)
        if size(value,1)~=width
            error("深度维度错误")
        end
        if size(value,2)~=romsGridInfo.N
            error("深度维度错误")
        end
        if size(value,3)~=timeLength
            error("时间维度错误")
        end

        result=value;
    elseif ndims(value)==4 %(x,y,z,t)
        s=size(value);
        if ~isequal(s(1:3),size(romsGridInfo.Hz))
            error("空间维度与ROMS网格不匹配")
        end
        if size(value,4)~=timeLength
            error("时间维度错误")
        end
        result=struct;
        result.east=squeeze(value(end,:,:,:));
        result.west=squeeze(value(1,:,:,:));
        result.north=squeeze(value(:,end,:,:));
        result.south=squeeze(value(:,1,:,:));

    end
end

function create_single_bdy_var(nc,info,varName,units,nc_dims,timeName,side)
    varSideName=varName+"_"+side;
    xrho_dim=netcdf.inqDimID(nc,nc_dims.dim_x);
    erho_dim=netcdf.inqDimID(nc,nc_dims.dim_y);
    sr_dim=netcdf.inqDimID(nc,nc_dims.dim_z);
    time_dim=netcdf.inqDimID(nc,timeName);
    if(~isempty(info.Variables) && any(ismember({info.Variables.Name},varSideName)))
        disp("变量"+varSideName+"已存在")
    else
        switch side
            case "east"
                dims=[erho_dim sr_dim time_dim];
            case "west"
                dims=[erho_dim sr_dim time_dim];
            case "south"
                dims=[xrho_dim sr_dim time_dim];
            case "north"
                dims=[xrho_dim sr_dim time_dim];
            otherwise
                error("未知side")
        end
        var = netcdf.defVar(nc,varSideName,'double',dims);
        netcdf.putAtt(nc,var,'long_name',varName+" "+side+"ern boundary condition");
        netcdf.putAtt(nc,var,'units',units);
        netcdf.putAtt(nc,var,'time',timeName);
        netcdf.putAtt(nc,var,'field',varSideName+", scalar, series");
        disp("变量"+varSideName+"已创建")
    end
end