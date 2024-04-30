function create_nudgcoef(m2,m3,temp,salt,tracer)
    configs
    file=roms.input.nudgcoef;
    roms_grid_info=get_roms_grid(roms.input.grid);
    [LP,MP]=size(roms_grid_info.lon_rho);
    nc=netcdf.create(file,bitor(0,4096));
    if isempty(nc), retunc, end
    try
        netcdf.putAtt(nc,netcdf.getConstant('NC_GLOBAL'),'history', ['Created on ' datestr(now)]);

        %定义维度
        xrho_dim = netcdf.defDim(nc,'xi_rho',LP);
        erho_dim = netcdf.defDim(nc,'eta_rho',MP);
        srho_dim = netcdf.defDim(nc,'s_rho',roms_grid_info.N);

        %定义变量
        lon_var = netcdf.defVar(nc,'lon_rho','double',[xrho_dim erho_dim]);
        netcdf.putAtt(nc,lon_var,'long_name','lon_rho');
        netcdf.putAtt(nc,lon_var,'units','degrees');
        netcdf.putAtt(nc,lon_var,'FillValue_',100000.);
        netcdf.putAtt(nc,lon_var,'missing_value',100000.);
        netcdf.putAtt(nc,lon_var,'field','xp, scalar, series');

        lat_var = netcdf.defVar(nc,'lat_rho','double',[xrho_dim erho_dim]);
        netcdf.putAtt(nc,lat_var,'long_name','lon_rho');
        netcdf.putAtt(nc,lat_var,'units','degrees');
        netcdf.putAtt(nc,lat_var,'FillValue_',100000.);
        netcdf.putAtt(nc,lat_var,'missing_value',100000.);
        netcdf.putAtt(nc,lat_var,'field','yp, scalar, series');

        s_var = netcdf.defVar(nc,'s_rho','double',srho_dim);
        netcdf.putAtt(nc,s_var,'long_name','S-coordinate stretching curves at RHO-points');
        netcdf.putAtt(nc,s_var,'FillValue_',100000.);
        netcdf.putAtt(nc,s_var,'valid_min',-1.);
        netcdf.putAtt(nc,s_var,'valid_max',0.);

        %写入数据
        netcdf.putVar(nc,lon_var,roms_grid_info.lon_rho);
        netcdf.putVar(nc,lat_var,roms_grid_info.lat_rho);
        netcdf.putVar(nc,s_var,roms_grid_info.s_rho);
        netcdf.close(nc);
    catch ex
        netcdf.close(nc);
        rethrow(ex)
    end

    if ~isempty(m2)
        roms_add_variable_to_xyzt_nc(file,'M2_NudgeCoef',m2, ...
            coordinates="xi_rho eta_rho", units="day-1", ...
            long_name="2D momentum inverse nudging coefficients", ...
            dim_x="xi_rho", dim_y="eta_rho", dim_z="", dim_t="");
    end

    if ~isempty(m3)
        roms_add_variable_to_xyzt_nc(file,'M3_NudgeCoef',m3, ...
            coordinates="xi_rho eta_rho s_rho", units="day-1", ...
            long_name="3D momentum inverse nudging coefficients", ...
            dim_x="xi_rho", dim_y="eta_rho", dim_z="s_rho", dim_t="");
    end

    if ~isempty(temp)
        roms_add_variable_to_xyzt_nc(file,'temp_NudgeCoef',temp, ...
            coordinates="xi_rho eta_rho s_rho", units="day-1", ...
            long_name="temp inverse nudging coefficients", ...
            dim_x="xi_rho", dim_y="eta_rho", dim_z="s_rho", dim_t="");
    end

    if ~isempty(salt)
        roms_add_variable_to_xyzt_nc(file,'salt_NudgeCoef',salt, ...
            coordinates="xi_rho eta_rho s_rho", units="day-1", ...
            long_name="salt inverse nudging coefficients", ...
            dim_x="xi_rho", dim_y="eta_rho", dim_z="s_rho", dim_t="");
    end

    if isstruct(tracer)
        for name=string(fieldnames(tracer))'
            roms_add_variable_to_xyzt_nc(file,name+"_NudgeCoef",tracer.(name), ...
                coordinates="xi_rho eta_rho s_rho", units="day-1", ...
                long_name=name+" inverse nudging coefficients", ...
                dim_x="xi_rho", dim_y="eta_rho", dim_z="s_rho", dim_t="");
        end
    elseif isnumeric(tracer)
        roms_add_variable_to_xyzt_nc(file,'tracer_NudgeCoef',tracer, ...
            coordinates="xi_rho eta_rho s_rho", units="day-1", ...
            long_name="generic tracer inverse nudging coefficients", ...
            dim_x="xi_rho", dim_y="eta_rho", dim_z="s_rho", dim_t="");
    end
end
