function roms_create_rivers_core(roms,from1)
    arguments
        roms
        from1(1,1) logical = false
    end
    roms.input.rivers=fullfile(roms.project_dir,roms.input.rivers);
    %nc = netcdf.create(roms.input.rivers,'nc_clobber');
    nc=netcdf.create(roms.input.rivers,bitor(0,4096)); 
    % global variables
    netcdf.putAtt(nc,netcdf.getConstant('NC_GLOBAL'),'type', 'ms.ncMS FORCING file');
    netcdf.putAtt(nc,netcdf.getConstant('NC_GLOBAL'),'grd_file',roms.input.grid );
    netcdf.putAtt(nc,netcdf.getConstant('NC_GLOBAL'),'title','rivers');

    % dimensions
    s_rho_id = netcdf.defDim(nc,'s_rho',roms.grid.N);
    river_id = netcdf.defDim(nc,'river',roms.rivers.count);
    %river_time_id = netcdf.defDim(nc,'river_time',netcdf.getConstant('NC_UNLIMITED'));
    river_time_id = netcdf.defDim(nc,'river_time',length(roms.rivers.time));

    disp('正在创建NetCDF结构')

    id = netcdf.defVar(nc,'river_time','double',river_time_id);
    netcdf.putAtt(nc,id,'long_name','river runoff time');
    netcdf.putAtt(nc,id,'units','days');
    %原来可以用下面的，但是新版ROMS用下面的会报错时间不对
    %netcdf.putAtt(nc,id,'units','days since 1858-11-17 00:00:00 UTC');

    id = netcdf.defVar(nc,'river','double',river_id);
    netcdf.putAtt(nc,id,'long_name','river runoff identification number');


    id = netcdf.defVar(nc,'river_Xposition','double',river_id);
    netcdf.putAtt(nc,id,'long_name','river XI-position at RHO-points');
    netcdf.putAtt(nc,id,'valid_min',0);
    netcdf.putAtt(nc,id,'valid_max',roms.grid.size(1));


    id = netcdf.defVar(nc,'river_Eposition','double',river_id);
    netcdf.putAtt(nc,id,'long_name','river ETA-position at RHO-points');
    netcdf.putAtt(nc,id,'valid_min',0);
    netcdf.putAtt(nc,id,'valid_max',roms.grid.size(2));

    id = netcdf.defVar(nc,'river_direction','double',river_id);
    netcdf.putAtt(nc,id,'long_name','river runoff direction');


    id = netcdf.defVar(nc,'river_Vshape','double',[river_id,s_rho_id]);
    netcdf.putAtt(nc,id,'long_name','river runoff mass transport vertical profile');


    id = netcdf.defVar(nc,'river_transport','double',[river_id,river_time_id]);
    netcdf.putAtt(nc,id,'long_name','river runoff vertically integrated mass transport');
    netcdf.putAtt(nc,id,'units','meter3 second-1');
    netcdf.putAtt(nc,id,'time','river_time');

    id = netcdf.defVar(nc,'river_temp','double',[river_id,s_rho_id,river_time_id]);
    netcdf.putAtt(nc,id,'long_name','river runoff potential temperature');
    netcdf.putAtt(nc,id,'units','Celsius');
    netcdf.putAtt(nc,id,'time','river_time');

    id = netcdf.defVar(nc,'river_salt','double',[river_id,s_rho_id,river_time_id]);
    netcdf.putAtt(nc,id,'long_name','river runoff salinity');
    netcdf.putAtt(nc,id,'time','river_time');


    for i=1:numel(roms.rivers.dye)
        if roms.tracer.age
            var_name=['river_dye_',num2str(i*2-1,'%02d')];
            id = netcdf.defVar(nc,var_name,'double',[river_id,s_rho_id,river_time_id]);
            netcdf.putAtt(nc,id,'long_name',var_name);
            netcdf.putAtt(nc,id,'units','kilogram meter-3');
            netcdf.putAtt(nc,id,'time','river_time');

            var_name=['river_dye_',num2str(i*2,'%02d')];
            id = netcdf.defVar(nc,var_name,'double',[river_id,s_rho_id,river_time_id]);
            netcdf.putAtt(nc,id,'long_name',var_name);
            netcdf.putAtt(nc,id,'units','second');
            netcdf.putAtt(nc,id,'time','ocean_time');
            netcdf.putAtt(nc,id,'field',[var_name,', scalar, series']);
        else
            var_name=['river_dye_',num2str(i,'%02d')];
            id = netcdf.defVar(nc,var_name,'double',[river_id,s_rho_id,river_time_id]);
            netcdf.putAtt(nc,id,'long_name',var_name);
            netcdf.putAtt(nc,id,'units','kilogram meter-3');
            netcdf.putAtt(nc,id,'time','river_time');
        end
    end
    netcdf.close(nc)

    disp('正在写入数据')
    ncwrite(roms.input.rivers,'river',[1:roms.rivers.count]);
    ncwrite(roms.input.rivers,'river_direction',roms.rivers.direction);
    ncwrite(roms.input.rivers,'river_Vshape',roms.rivers.v_shape)
    if from1
        ncwrite(roms.input.rivers,'river_Xposition',roms.rivers.location(:,1)-1)
        ncwrite(roms.input.rivers,'river_Eposition',roms.rivers.location(:,2)-1)
    else
        ncwrite(roms.input.rivers,'river_Xposition',roms.rivers.location(:,1))
        ncwrite(roms.input.rivers,'river_Eposition',roms.rivers.location(:,2))
    end
    ncwrite(roms.input.rivers,'river_time',roms.rivers.time+roms.time.start_julian);
    ncwrite(roms.input.rivers,'river_transport',roms.rivers.transport);
    ncwrite(roms.input.rivers,'river_salt',roms.rivers.salt);
    ncwrite(roms.input.rivers,'river_temp',roms.rivers.temp);

    for i=1:numel(roms.rivers.dye)
        if roms.tracer.age
            var_name=['river_dye_',num2str(i*2-1,'%02d')];
            disp("正在写入"+string(var_name));
            ncwrite(roms.input.rivers,var_name,roms.rivers.dye{i});
            var_name=['river_dye_',num2str(i*2,'%02d')];
            disp("正在写入"+string(var_name));
            ncwrite(roms.input.rivers,var_name,roms.rivers.ages{i});
        else
            var_name=['river_dye_',num2str(i,'%02d')];
            disp("正在写入"+string(var_name));
            ncwrite(roms.input.rivers,var_name,roms.rivers.dye{i});
        end
    end
end
