function roms_add_tracer_to_clm_nc(ncfile,varName,value,times,varLongName,units,nc_dims)
    arguments
        ncfile(1,1) string
        varName(1,1) string
        value
        times(1,:) double
        varLongName(1,1) string
        units(1,1) string
        nc_dims.dim_x(1,1) string="xrho"
        nc_dims.dim_y(1,1) string="erho"
        nc_dims.dim_z(1,1) string="s_rho"
    end

    configs

    if ndims(value)==4 && length(times)>1 || ndims(value)==3 && length(times)==1
        dimNames=[nc_dims.dim_x,nc_dims.dim_y,nc_dims.dim_z];
    elseif ndims(value)==3&& length(times)>1 || ismatrix(value) && length(times)==1
        dimNames=[nc_dims.dim_x,nc_dims.dim_y];
    else
        error("不支持的数据维度")
    end


    info=ncinfo(ncfile);
    nc=netcdf.open(ncfile,'WRITE');

    dims=[];

    timeName=varName+"_time";
    try

        if(~any(ismember({info.Variables.Name},timeName)))
            bio_time_dim = netcdf.defDim(nc,timeName,length(times));
            bio_time_var = netcdf.defVar(nc,timeName,'double',bio_time_dim);
            netcdf.putAtt(nc,bio_time_var,'long_name',timeName);
            netcdf.putAtt(nc,bio_time_var,'units','days');
            netcdf.putAtt(nc,bio_time_var,'field',timeName+", scalar, series");
        end
        dimNames(end+1)=timeName;
        for d=dimNames
            dims(end+1)=netcdf.inqDimID(nc,d);
        end
        var = netcdf.defVar(nc,varName,'double',dims);
        netcdf.putAtt(nc,var,'long_name',varLongName);
        netcdf.putAtt(nc,var,'units',units);
        netcdf.putAtt(nc,var,'time',timeName);
        netcdf.putAtt(nc,var,'field',varName+", scalar, series");

        netcdf.close(nc)
    catch ex
        netcdf.close(nc)
        rethrow(ex)
    end

    ncwrite(ncfile,timeName,times)
    ncwrite(ncfile,varName,value)
end
