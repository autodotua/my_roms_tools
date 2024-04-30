function create_clm_nc(file,time,roms_grid_info,u,v,ubar,vbar,temp,salt,zeta)
    [LP,MP]=size(roms_grid_info.lon_rho);
    nc=netcdf.create(file,bitor(0,4096));   %JBZ update for NC4 files, equivalent to 'clobber' + 'NETCDF4'
    if isempty(nc), retunc, end
    configs
    try
        netcdf.putAtt(nc,netcdf.getConstant('NC_GLOBAL'),'history', ['Created on ' datestr(now)]);
        L=LP-1;
        M=MP-1;

        %定义维度
        xrho_dim = netcdf.defDim(nc,'xrho',LP);
        xu_dim = netcdf.defDim(nc,'xu',L);
        xv_dim = netcdf.defDim(nc,'xv',LP);
        erho_dim = netcdf.defDim(nc,'erho',MP);
        eu_dim = netcdf.defDim(nc,'eu',MP);
        ev_dim = netcdf.defDim(nc,'ev',M);
        srho_dim = netcdf.defDim(nc,'s_rho',roms_grid_info.N);
        ocean_time_dim = netcdf.defDim(nc,'ocean_time',length(time));
        temp_time_dim = netcdf.defDim(nc,'temp_time',length(time));
        salt_time_dim = netcdf.defDim(nc,'salt_time',length(time));
        v2d_time_dim = netcdf.defDim(nc,'v2d_time',length(time));
        v3d_time_dim = netcdf.defDim(nc,'v3d_time',length(time));
        zeta_time_dim = netcdf.defDim(nc,'zeta_time',length(time));

        %定义变量
        ocean_time_var = netcdf.defVar(nc,'ocean_time','double',ocean_time_dim);
        netcdf.putAtt(nc,ocean_time_var,'long_name','ocean_time');
        netcdf.putAtt(nc,ocean_time_var,'units','days');
        netcdf.putAtt(nc,ocean_time_var,'field','ocean_time, scalar, series');

        temp_time_var = netcdf.defVar(nc,'temp_time','double',temp_time_dim);
        netcdf.putAtt(nc,temp_time_var,'long_name','temp_time');
        netcdf.putAtt(nc,temp_time_var,'units','days');
        netcdf.putAtt(nc,temp_time_var,'field','temp_time, scalar, series');


        salt_time_var = netcdf.defVar(nc,'salt_time','double',salt_time_dim);
        netcdf.putAtt(nc,salt_time_var,'long_name','salt_time');
        netcdf.putAtt(nc,salt_time_var,'units','days');
        netcdf.putAtt(nc,salt_time_var,'field','salt_time, scalar, series');

        v2d_time_var = netcdf.defVar(nc,'v2d_time','double',v2d_time_dim);
        netcdf.putAtt(nc,v2d_time_var,'long_name','v2d_time');
        netcdf.putAtt(nc,v2d_time_var,'units','days');
        netcdf.putAtt(nc,v2d_time_var,'field','v2d_time, scalar, series');

        v3d_time_var = netcdf.defVar(nc,'v3d_time','double',v3d_time_dim);
        netcdf.putAtt(nc,v3d_time_var,'long_name','v3d_time');
        netcdf.putAtt(nc,v3d_time_var,'units','days');
        netcdf.putAtt(nc,v3d_time_var,'field','v3d_time, scalar, series');

        zeta_time_var = netcdf.defVar(nc,'zeta_time','double',zeta_time_dim);
        netcdf.putAtt(nc,zeta_time_var,'long_name','zeta_time');
        netcdf.putAtt(nc,zeta_time_var,'units','days');
        netcdf.putAtt(nc,zeta_time_var,'field','zeta_time, scalar, series');

        lon_var = netcdf.defVar(nc,'lon_rho','float',[xrho_dim erho_dim]);
        netcdf.putAtt(nc,lon_var,'long_name','lon_rho');
        netcdf.putAtt(nc,lon_var,'units','degrees');
        netcdf.putAtt(nc,lon_var,'FillValue_',100000.);
        netcdf.putAtt(nc,lon_var,'missing_value',100000.);
        netcdf.putAtt(nc,lon_var,'field','xp, scalar, series');

        lat_var = netcdf.defVar(nc,'lat_rho','float',[xrho_dim erho_dim]);
        netcdf.putAtt(nc,lat_var,'long_name','lon_rho');
        netcdf.putAtt(nc,lat_var,'units','degrees');
        netcdf.putAtt(nc,lat_var,'FillValue_',100000.);
        netcdf.putAtt(nc,lat_var,'missing_value',100000.);
        netcdf.putAtt(nc,lat_var,'field','yp, scalar, series');

        zeta_var = netcdf.defVar(nc,'zeta','double',[xrho_dim erho_dim zeta_time_dim]);
        netcdf.putAtt(nc,zeta_var,'long_name','zeta');
        netcdf.putAtt(nc,zeta_var,'units','meter');
        netcdf.putAtt(nc,zeta_var,'field','zeta, scalar, series');
        setDeflate(nc,zeta_var);

        salt_var = netcdf.defVar(nc,'salt','float',[xrho_dim erho_dim srho_dim salt_time_dim]);
        netcdf.putAtt(nc,salt_var,'long_name','salt');
        netcdf.putAtt(nc,salt_var,'units','psu');
        netcdf.putAtt(nc,salt_var,'field','salt, scalar, series');
        setDeflate(nc,salt_var);

        temp_var = netcdf.defVar(nc,'temp','float',[xrho_dim erho_dim srho_dim temp_time_dim]);
        netcdf.putAtt(nc,temp_var,'long_name','temp');
        netcdf.putAtt(nc,temp_var,'units','C');
        netcdf.putAtt(nc,temp_var,'field','temp, scalar, series');
        setDeflate(nc,temp_var);

        u_var = netcdf.defVar(nc,'u','float',[xu_dim eu_dim srho_dim v3d_time_dim]);
        netcdf.putAtt(nc,u_var,'long_name','velx');
        netcdf.putAtt(nc,u_var,'units','meter second-1');
        netcdf.putAtt(nc,u_var,'field','velx, scalar, series');
        setDeflate(nc,u_var);

        v_var = netcdf.defVar(nc,'v','float',[xv_dim ev_dim srho_dim v3d_time_dim]);
        netcdf.putAtt(nc,v_var,'long_name','vely');
        netcdf.putAtt(nc,v_var,'units','meter second-1');
        netcdf.putAtt(nc,v_var,'field','vely, scalar, series');
        setDeflate(nc,v_var);

        ubar_var = netcdf.defVar(nc,'ubar','float',[xu_dim eu_dim v2d_time_dim]);
        netcdf.putAtt(nc,ubar_var,'long_name','mean velx');
        netcdf.putAtt(nc,ubar_var,'units','meter second-1');
        netcdf.putAtt(nc,ubar_var,'field','mean velx, scalar, series');
        setDeflate(nc,ubar_var);

        vbar_var = netcdf.defVar(nc,'vbar','float',[xv_dim ev_dim v2d_time_dim]);
        netcdf.putAtt(nc,vbar_var,'long_name','mean vely');
        netcdf.putAtt(nc,vbar_var,'units','meter second-1');
        netcdf.putAtt(nc,vbar_var,'field','mean vely, scalar, series');
        setDeflate(nc,vbar_var);

        %写入数据
        if length(time)==1
            jtime=juliandate(time,'modifiedjuliandate');
            netcdf.putVar(nc,lon_var,roms_grid_info.lon_rho);
            netcdf.putVar(nc,lat_var,roms_grid_info.lat_rho);
            netcdf.putVar(nc,u_var,shiftdim(u,1));
            netcdf.putVar(nc,v_var,shiftdim(v,1));
            netcdf.putVar(nc,temp_time_var,jtime);
            netcdf.putVar(nc,salt_time_var,jtime);
            netcdf.putVar(nc,zeta_time_var,jtime);
            netcdf.putVar(nc,v3d_time_var,jtime);
            netcdf.putVar(nc,v2d_time_var,jtime);
            netcdf.putVar(nc,ocean_time_var,jtime);
            netcdf.putVar(nc,ubar_var,ubar);
            netcdf.putVar(nc,vbar_var,vbar);
            netcdf.putVar(nc,temp_var,shiftdim(temp,1));
            netcdf.putVar(nc,salt_var,shiftdim(salt,1));
            netcdf.putVar(nc,zeta_var,zeta);
        end
        netcdf.close(nc);
    catch ex
        netcdf.close(nc);
        rethrow(ex)
    end
end


function setDeflate(nc,var)
    configs
    if roms.io.deflate==0
        return
    else
        netcdf.defVarDeflate(nc,var,true, roms.io.shuffle, roms.io.deflate);
    end
end