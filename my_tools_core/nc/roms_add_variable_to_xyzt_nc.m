function roms_add_variable_to_xyzt_nc(ncfile,var,value,nc_properties,nc_dims)

    arguments
        ncfile(1,1) string
        var(1,1) string
        value double
        nc_properties.long_name(1,1) string
        nc_properties.units(1,1) string
        nc_properties.time(1,1) string
        nc_properties.coordinates(1,1) string
        %nc_dims.dim(1,1) double {mustBeInRange(nc_dims.dim,3,4)}=3
        nc_dims.dim_x(1,1) string="xrho"
        nc_dims.dim_y(1,1) string="erho"
        nc_dims.dim_z(1,1) string="sc_r"
        nc_dims.dim_t(1,1) string="time"
    end

    configs

    info=ncinfo(ncfile);
    if(any(ismember( {info.Variables.Name},var)))
        disp("变量"+var+"已存在")
    else
        nc=netcdf.open(ncfile,'WRITE');
        try
            xrho_id=netcdf.inqDimID(nc,nc_dims.dim_x);
            erho_id=netcdf.inqDimID(nc,nc_dims.dim_y);
            if nc_dims.dim_z~=""
                sc_r_id=netcdf.inqDimID(nc,nc_dims.dim_z);
            end
            if nc_dims.dim_t~=""
                time_id=netcdf.inqDimID(nc,nc_dims.dim_t);
            end
            if nc_dims.dim_z=="" && nc_dims.dim_t==""
                var_dims=[xrho_id,erho_id];
            elseif nc_dims.dim_z==""
                var_dims=[xrho_id,erho_id,time_id];
            elseif nc_dims.dim_t==""
                var_dims=[xrho_id,erho_id,sc_r_id];
            else
                var_dims=[xrho_id,erho_id,sc_r_id,time_id];
            end
            var_id=netcdf.defVar(nc,var,'double',var_dims);

            if  isfield(nc_properties,'long_name')
                netcdf.putAtt(nc,var_id,'long_name',nc_properties.long_name);
            end
            if  isfield(nc_properties,'units')
                netcdf.putAtt(nc,var_id,'units',nc_properties.units);
            end
            if nc_dims.dim_t~="" && isfield(nc_properties,'time')
                netcdf.putAtt(nc,var_id,'time',nc_properties.time);
            end
            if  isfield(nc_properties,'coordinates')
                netcdf.putAtt(nc,var_id,'coordinates',nc_properties.coordinates);
            end
            netcdf.putAtt(nc,var_id,'field',[char(var),', scalar, series']);
            disp("变量"+var+"已创建")
            netcdf.close(nc)
        catch ME
            netcdf.close(nc)
            rethrow(ME)
        end
    end


    data= ncread(ncfile,var);
    if isequal(size(data),size(value))
        data=value;
    elseif numel(value)==1
        data(:)=value;
    else
        error("value长度错误，应为1或指定变量长度");
    end

    disp("正在写入变量"+var)
    ncwrite(ncfile,var,data)
