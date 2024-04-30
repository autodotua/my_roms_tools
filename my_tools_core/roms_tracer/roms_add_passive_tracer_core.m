function roms_add_passive_tracer_core(roms,ini,bdy)
    arguments
        roms(1,1) struct
        ini(1,1) logical =1
        bdy(1,1) logical =1
    end
    d=cd(roms.project_dir);
    if ini
        roms_add_tracer_ini(roms)
    end
    if bdy
        roms_add_tracer_bdy(roms)
    end
    cd(d);
end


function roms_add_tracer_ini(roms)
    info=ncinfo(roms.input.initialization);
    nc=netcdf.open(roms.input.initialization,'WRITE');
    xrho_id=netcdf.inqDimID(nc,'xrho');
    erho_id=netcdf.inqDimID(nc,'erho');
    sc_r_id=netcdf.inqDimID(nc,'sc_r');
    time_id=netcdf.inqDimID(nc,'time');
    for i=1:roms.tracer.count
        var_name=['dye_',num2str(i,'%02d')];
        if(any(ismember( {info.Variables.Name},var_name)))
            disp(['变量',var_name,'已存在'])
        else
            dye_id=netcdf.defVar(nc,var_name,'double',[xrho_id,erho_id,sc_r_id,time_id]);
            netcdf.putAtt(nc,dye_id,'long_name',var_name);
            netcdf.putAtt(nc,dye_id,'units','kilogram meter-3');
            netcdf.putAtt(nc,dye_id,'time','ocean_time');
            netcdf.putAtt(nc,dye_id,'field',[var_name,', scalar, series']);
            disp(['变量',var_name,'已创建'])
        end

        if roms.tracer.age
            var_name=['dye_',num2str(i,'%02d'),'_age'];
            if(any(ismember( {info.Variables.Name},var_name)))
                disp(['变量',var_name,'已存在'])
            else
                dye_id=netcdf.defVar(nc,var_name,'double',[xrho_id,erho_id,sc_r_id,time_id]);
                netcdf.putAtt(nc,dye_id,'long_name',var_name);
                netcdf.putAtt(nc,dye_id,'units','second');
                netcdf.putAtt(nc,dye_id,'time','ocean_time');
                netcdf.putAtt(nc,dye_id,'field',[var_name,', scalar, series']);
                disp(['变量',var_name,'已创建'])
            end
        end
    end

    netcdf.close(nc)

    for i=1:roms.tracer.count
        disp(['正在写入变量',var_name])
        var_name=['dye_',num2str(i,'%02d')];
        ncwrite(roms.input.initialization,var_name,roms.tracer.densities{i})

        if roms.tracer.age
            var_name=['dye_',num2str(i,'%02d'),'_age'];
            ncwrite(roms.input.initialization,var_name,roms.tracer.ages{i})
        end
    end
end


function roms_add_tracer_bdy(roms)
    info=ncinfo(roms.input.boundary);
    nc=netcdf.open(roms.input.boundary,'WRITE');
    try
        xrho_dim=netcdf.inqDimID(nc,'xrho');
        erho_dim=netcdf.inqDimID(nc,'erho');
        sr_dim=netcdf.inqDimID(nc,'s_rho');

        if(~any(ismember( {info.Variables.Name},'dye_time')))

            dye_time_dim = netcdf.defDim(nc,'dye_time',length(roms.tracer.times));
            dye_time_var = netcdf.defVar(nc,'dye_time','double',dye_time_dim);
            netcdf.putAtt(nc,dye_time_var,'long_name','dye_time');
            netcdf.putAtt(nc,dye_time_var,'units','days');
            netcdf.putAtt(nc,dye_time_var,'field','dye_time, scalar, series');
        else
            dye_time_dim=netcdf.inqDimID(nc,'dye_time');
        end
        for i=1:roms.tracer.count
            if roms.tracer.age
                %浓度
                var_name=['dye_east_',num2str(i*2-1,'%02d')];
                if(any(ismember( {info.Variables.Name},var_name)))
                    disp(['变量',var_name,'已存在'])
                else
                    var = netcdf.defVar(nc,var_name,'double',[erho_dim sr_dim dye_time_dim]);
                    netcdf.putAtt(nc,var,'long_name','dye concentration eastern boundary condition');
                    netcdf.putAtt(nc,var,'units','kilogram meter-3');
                    netcdf.putAtt(nc,var,'time','dye_time');
                    netcdf.putAtt(nc,var,'field',[var_name,', scalar, series']);
                    disp(['变量',var_name,'已创建'])
                end

                var_name=['dye_west_',num2str(i*2-1,'%02d')];
                if(any(ismember( {info.Variables.Name},var_name)))
                    disp(['变量',var_name,'已存在'])
                else
                    var = netcdf.defVar(nc,var_name,'double',[erho_dim sr_dim dye_time_dim]);
                    netcdf.putAtt(nc,var,'long_name','dye concentration western boundary condition');
                    netcdf.putAtt(nc,var,'units','kilogram meter-3');
                    netcdf.putAtt(nc,var,'time','dye_time');
                    netcdf.putAtt(nc,var,'field',[var_name,', scalar, series']);
                    disp(['变量',var_name,'已创建'])
                end

                var_name=['dye_south_',num2str(i*2-1,'%02d')];
                if(any(ismember( {info.Variables.Name},var_name)))
                    disp(['变量',var_name,'已存在'])
                else
                    var = netcdf.defVar(nc,var_name,'double',[xrho_dim sr_dim dye_time_dim]);
                    netcdf.putAtt(nc,var,'long_name','dye concentration southern boundary condition');
                    netcdf.putAtt(nc,var,'units','kilogram meter-3');
                    netcdf.putAtt(nc,var,'time','dye_time');
                    netcdf.putAtt(nc,var,'field',[var_name,', scalar, series']);
                    disp(['变量',var_name,'已创建'])
                end

                var_name=['dye_north_',num2str(i*2-1,'%02d')];
                if(any(ismember( {info.Variables.Name},var_name)))
                    disp(['变量',var_name,'已存在'])
                else
                    var = netcdf.defVar(nc,var_name,'double',[xrho_dim sr_dim dye_time_dim]);
                    netcdf.putAtt(nc,var,'long_name','dye concentration northern boundary condition');
                    netcdf.putAtt(nc,var,'units','kilogram meter-3');
                    netcdf.putAtt(nc,var,'time','dye_time');
                    netcdf.putAtt(nc,var,'field',[var_name,', scalar, series']);
                    disp(['变量',var_name,'已创建'])
                end

                %age
                var_name=['dye_east_',num2str(i*2,'%02d')];
                if(any(ismember( {info.Variables.Name},var_name)))
                    disp(['变量',var_name,'已存在'])
                else
                    var = netcdf.defVar(nc,var_name,'double',[erho_dim sr_dim dye_time_dim]);
                    netcdf.putAtt(nc,var,'long_name','dye concentration eastern boundary condition age');
                    netcdf.putAtt(nc,var,'units','second');
                    netcdf.putAtt(nc,var,'time','dye_time');
                    netcdf.putAtt(nc,var,'field',[var_name,', scalar, series']);
                    disp(['变量',var_name,'已创建'])
                end

                var_name=['dye_west_',num2str(i*2,'%02d')];
                if(any(ismember( {info.Variables.Name},var_name)))
                    disp(['变量',var_name,'已存在'])
                else
                    var = netcdf.defVar(nc,var_name,'double',[erho_dim sr_dim dye_time_dim]);
                    netcdf.putAtt(nc,var,'long_name','dye concentration western boundary condition age');
                    netcdf.putAtt(nc,var,'units','second');
                    netcdf.putAtt(nc,var,'time','dye_time');
                    netcdf.putAtt(nc,var,'field',[var_name,', scalar, series']);
                    disp(['变量',var_name,'已创建'])
                end

                var_name=['dye_south_',num2str(i*2,'%02d')];
                if(any(ismember( {info.Variables.Name},var_name)))
                    disp(['变量',var_name,'已存在'])
                else
                    var = netcdf.defVar(nc,var_name,'double',[xrho_dim sr_dim dye_time_dim]);
                    netcdf.putAtt(nc,var,'long_name','dye concentration southern boundary condition age');
                    netcdf.putAtt(nc,var,'units','second');
                    netcdf.putAtt(nc,var,'time','dye_time');
                    netcdf.putAtt(nc,var,'field',[var_name,', scalar, series']);
                    disp(['变量',var_name,'已创建'])
                end

                var_name=['dye_north_',num2str(i*2,'%02d')];
                if(any(ismember( {info.Variables.Name},var_name)))
                    disp(['变量',var_name,'已存在'])
                else
                    var = netcdf.defVar(nc,var_name,'double',[xrho_dim sr_dim dye_time_dim]);
                    netcdf.putAtt(nc,var,'long_name','dye concentration northern boundary condition age');
                    netcdf.putAtt(nc,var,'units','second');
                    netcdf.putAtt(nc,var,'time','dye_time');
                    netcdf.putAtt(nc,var,'field',[var_name,', scalar, series']);
                    disp(['变量',var_name,'已创建'])
                end
            else %无age
                var_name=['dye_east_',num2str(i,'%02d')];
                if(any(ismember( {info.Variables.Name},var_name)))
                    disp(['变量',var_name,'已存在'])
                else
                    var = netcdf.defVar(nc,var_name,'double',[erho_dim sr_dim dye_time_dim]);
                    netcdf.putAtt(nc,var,'long_name','dye concentration eastern boundary condition');
                    netcdf.putAtt(nc,var,'units','kilogram meter-3');
                    netcdf.putAtt(nc,var,'time','dye_time');
                    netcdf.putAtt(nc,var,'field',[var_name,', scalar, series']);
                    disp(['变量',var_name,'已创建'])
                end

                var_name=['dye_west_',num2str(i,'%02d')];
                if(any(ismember( {info.Variables.Name},var_name)))
                    disp(['变量',var_name,'已存在'])
                else
                    var = netcdf.defVar(nc,var_name,'double',[erho_dim sr_dim dye_time_dim]);
                    netcdf.putAtt(nc,var,'long_name','dye concentration western boundary condition');
                    netcdf.putAtt(nc,var,'units','kilogram meter-3');
                    netcdf.putAtt(nc,var,'time','dye_time');
                    netcdf.putAtt(nc,var,'field',[var_name,', scalar, series']);
                    disp(['变量',var_name,'已创建'])
                end

                var_name=['dye_south_',num2str(i,'%02d')];
                if(any(ismember( {info.Variables.Name},var_name)))
                    disp(['变量',var_name,'已存在'])
                else
                    var = netcdf.defVar(nc,var_name,'double',[xrho_dim sr_dim dye_time_dim]);
                    netcdf.putAtt(nc,var,'long_name','dye concentration southern boundary condition');
                    netcdf.putAtt(nc,var,'units','kilogram meter-3');
                    netcdf.putAtt(nc,var,'time','dye_time');
                    netcdf.putAtt(nc,var,'field',[var_name,', scalar, series']);
                    disp(['变量',var_name,'已创建'])
                end

                var_name=['dye_north_',num2str(i,'%02d')];
                if(any(ismember( {info.Variables.Name},var_name)))
                    disp(['变量',var_name,'已存在'])
                else
                    var = netcdf.defVar(nc,var_name,'double',[xrho_dim sr_dim dye_time_dim]);
                    netcdf.putAtt(nc,var,'long_name','dye concentration northern boundary condition');
                    netcdf.putAtt(nc,var,'units','kilogram meter-3');
                    netcdf.putAtt(nc,var,'time','dye_time');
                    netcdf.putAtt(nc,var,'field',[var_name,', scalar, series']);
                    disp(['变量',var_name,'已创建'])
                end
            end
        end
        netcdf.close(nc)
    catch
        netcdf.close(nc)
    end

    ncwrite(roms.input.boundary,'dye_time',roms.tracer.times+roms.time.start_julian)
    for i=1:roms.tracer.count
        for d=["east","west","south","north"]
            if roms.tracer.age
                var_name=['dye_',char(d),'_',num2str(i*2-1,'%02d')];
                disp(['正在写入变量',var_name])
                var=eval("roms.tracer."+d+"{i}");
                ncwrite(roms.input.boundary,var_name,var)

                var_name=['dye_',char(d),'_',num2str(i*2,'%02d')];
                disp(['正在写入变量',var_name])
                var=eval("roms.tracer."+d+"_age{i}");
                ncwrite(roms.input.boundary,var_name,var)
            else
                var_name=['dye_',char(d),'_',num2str(i,'%02d')];
                disp(['正在写入变量',var_name])
                var=eval("roms.tracer."+d+"{i}");
                ncwrite(roms.input.boundary,var_name,var)
            end
        end
    end
end
