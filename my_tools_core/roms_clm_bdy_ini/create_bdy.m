function create_bdy(clm_file,output_bdy_file,roms_grid_info)
    % 通过合并的气候文件，创建边界场文件
    arguments
        clm_file(1,1) string
        output_bdy_file(1,1) string
        roms_grid_info
    end

    nc_clm=netcdf.open(clm_file,'NC_NOWRITE');
    nc_bdy=netcdf.create(output_bdy_file,bitor(0,4096));

    try
        timeid = netcdf.inqVarID(nc_clm,'temp_time');
        time=netcdf.getVar(nc_clm,timeid);
        [LP,MP]=size(roms_grid_info.lon_rho);
        L=LP-1;
        Lm=L-1;
        M=MP-1;
        Mm=M-1;
        L  = Lm+1;
        M  = Mm+1;
        s    = roms_grid_info.N;

        if isempty(nc_bdy), return, end

        %% 定义属性

        netcdf.putAtt(nc_bdy,netcdf.getConstant('NC_GLOBAL'),'history', ['Created on ' datestr(now)]);
        %% 定义维度

        xrho_dim = netcdf.defDim(nc_bdy,'xrho',LP);
        xu_dim = netcdf.defDim(nc_bdy,'xu',L);
        xv_dim = netcdf.defDim(nc_bdy,'xv',LP);

        erho_dim = netcdf.defDim(nc_bdy,'erho',MP);
        eu_dim = netcdf.defDim(nc_bdy,'eu',MP);
        ev_dim = netcdf.defDim(nc_bdy,'ev',M);
        srho_dim = netcdf.defDim(nc_bdy,'s_rho',s);
        temp_time_dim = netcdf.defDim(nc_bdy,'temp_time',length(time));
        salt_time_dim = netcdf.defDim(nc_bdy,'salt_time',length(time));
        v2d_time_dim = netcdf.defDim(nc_bdy,'v2d_time',length(time));
        v3d_time_dim = netcdf.defDim(nc_bdy,'v3d_time',length(time));
        zeta_time_dim = netcdf.defDim(nc_bdy,'zeta_time',length(time));

        %% 定义变量
        temp_time_var = netcdf.defVar(nc_bdy,'temp_time','double',temp_time_dim);
        netcdf.putAtt(nc_bdy,temp_time_var,'long_name','temp_time');
        netcdf.putAtt(nc_bdy,temp_time_var,'units','days');
        netcdf.putAtt(nc_bdy,temp_time_var,'field','temp_time, scalar, series');


        salt_time_var = netcdf.defVar(nc_bdy,'salt_time','double',salt_time_dim);
        netcdf.putAtt(nc_bdy,salt_time_var,'long_name','salt_time');
        netcdf.putAtt(nc_bdy,salt_time_var,'units','days');
        netcdf.putAtt(nc_bdy,salt_time_var,'field','salt_time, scalar, series');

        v2d_time_var = netcdf.defVar(nc_bdy,'v2d_time','double',v2d_time_dim);
        netcdf.putAtt(nc_bdy,v2d_time_var,'long_name','v2d_time');
        netcdf.putAtt(nc_bdy,v2d_time_var,'units','days');
        netcdf.putAtt(nc_bdy,v2d_time_var,'field','v2d_time, scalar, series');

        v3d_time_var = netcdf.defVar(nc_bdy,'v3d_time','double',v3d_time_dim);
        netcdf.putAtt(nc_bdy,v3d_time_var,'long_name','v3d_time');
        netcdf.putAtt(nc_bdy,v3d_time_var,'units','days');
        netcdf.putAtt(nc_bdy,v3d_time_var,'field','v3d_time, scalar, series');

        zeta_time_var = netcdf.defVar(nc_bdy,'zeta_time','double',zeta_time_dim);
        netcdf.putAtt(nc_bdy,zeta_time_var,'long_name','zeta_time');
        netcdf.putAtt(nc_bdy,zeta_time_var,'units','days');
        netcdf.putAtt(nc_bdy,zeta_time_var,'field','zeta_time, scalar, series');


        zeta_south_var = netcdf.defVar(nc_bdy,'zeta_south','double',[xrho_dim zeta_time_dim]);
        netcdf.putAtt(nc_bdy,zeta_south_var,'long_name','free-surface southern boundary condition');
        netcdf.putAtt(nc_bdy,zeta_south_var,'units','meter');
        netcdf.putAtt(nc_bdy,zeta_south_var,'field','zeta_south, scalar, series');

        zeta_east_var = netcdf.defVar(nc_bdy,'zeta_east','double',[erho_dim zeta_time_dim]);
        netcdf.putAtt(nc_bdy,zeta_east_var,'long_name','free-surface eastern boundary condition');
        netcdf.putAtt(nc_bdy,zeta_east_var,'units','meter');
        netcdf.putAtt(nc_bdy,zeta_east_var,'field','zeta_east, scalar, series');

        zeta_west_var = netcdf.defVar(nc_bdy,'zeta_west','double',[erho_dim zeta_time_dim]);
        netcdf.putAtt(nc_bdy,zeta_west_var,'long_name','free-surface western boundary condition');
        netcdf.putAtt(nc_bdy,zeta_west_var,'units','meter');
        netcdf.putAtt(nc_bdy,zeta_west_var,'field','zeta_west, scalar, series');

        zeta_north_var = netcdf.defVar(nc_bdy,'zeta_north','double',[xrho_dim zeta_time_dim]);
        netcdf.putAtt(nc_bdy,zeta_north_var,'long_name','free-surface northern boundary condition');
        netcdf.putAtt(nc_bdy,zeta_north_var,'units','meter');
        netcdf.putAtt(nc_bdy,zeta_north_var,'field','zeta_north, scalar, series');

        ubar_south_var = netcdf.defVar(nc_bdy,'ubar_south','float',[xu_dim v2d_time_dim]);
        netcdf.putAtt(nc_bdy,ubar_south_var,'long_name','2D u-momentum southern boundary condition');
        netcdf.putAtt(nc_bdy,ubar_south_var,'units','meter second-1');
        netcdf.putAtt(nc_bdy,ubar_south_var,'field','ubar_south, scalar, series');

        ubar_east_var = netcdf.defVar(nc_bdy,'ubar_east','float',[eu_dim v2d_time_dim]);
        netcdf.putAtt(nc_bdy,ubar_east_var,'long_name','2D u-momentum eastern boundary condition');
        netcdf.putAtt(nc_bdy,ubar_east_var,'units','meter second-1');
        netcdf.putAtt(nc_bdy,ubar_east_var,'field','ubar_east, scalar, series');

        ubar_west_var = netcdf.defVar(nc_bdy,'ubar_west','float',[eu_dim v2d_time_dim]);
        netcdf.putAtt(nc_bdy,ubar_west_var,'long_name','2D u-momentum western boundary condition');
        netcdf.putAtt(nc_bdy,ubar_west_var,'units','meter second-1');
        netcdf.putAtt(nc_bdy,ubar_west_var,'field','ubar_west, scalar, series');

        ubar_north_var = netcdf.defVar(nc_bdy,'ubar_north','float',[xu_dim v2d_time_dim]);
        netcdf.putAtt(nc_bdy,ubar_north_var,'long_name','2D u-momentum northern boundary condition');
        netcdf.putAtt(nc_bdy,ubar_north_var,'units','meter second-1');
        netcdf.putAtt(nc_bdy,ubar_north_var,'field','ubar_north, scalar, series');

        vbar_south_var = netcdf.defVar(nc_bdy,'vbar_south','float',[xv_dim v2d_time_dim]);
        netcdf.putAtt(nc_bdy,vbar_south_var,'long_name','2D v-momentum southern boundary condition');
        netcdf.putAtt(nc_bdy,vbar_south_var,'units','meter second-1');
        netcdf.putAtt(nc_bdy,vbar_south_var,'field','vbar_south, scalar, series');

        vbar_east_var = netcdf.defVar(nc_bdy,'vbar_east','float',[ev_dim v2d_time_dim]);
        netcdf.putAtt(nc_bdy,vbar_east_var,'long_name','2D v-momentum eastern boundary condition');
        netcdf.putAtt(nc_bdy,vbar_east_var,'units','meter second-1');
        netcdf.putAtt(nc_bdy,vbar_east_var,'field','vbar_east, scalar, series');

        vbar_west_var = netcdf.defVar(nc_bdy,'vbar_west','float',[ev_dim v2d_time_dim]);
        netcdf.putAtt(nc_bdy,vbar_west_var,'long_name','2D v-momentum western boundary condition');
        netcdf.putAtt(nc_bdy,vbar_west_var,'units','meter second-1');
        netcdf.putAtt(nc_bdy,vbar_west_var,'field','vbar_west, scalar, series');

        vbar_north_var = netcdf.defVar(nc_bdy,'vbar_north','float',[xv_dim v2d_time_dim]);
        netcdf.putAtt(nc_bdy,vbar_north_var,'long_name','2D v-momentum northern boundary condition');
        netcdf.putAtt(nc_bdy,vbar_north_var,'units','meter second-1');
        netcdf.putAtt(nc_bdy,vbar_north_var,'field','vbar_north, scalar, series');

        u_south_var = netcdf.defVar(nc_bdy,'u_south','float',[xu_dim srho_dim v3d_time_dim]);
        netcdf.putAtt(nc_bdy,u_south_var,'long_name','3D u-momentum southern boundary condition');
        netcdf.putAtt(nc_bdy,u_south_var,'units','meter second-1');
        netcdf.putAtt(nc_bdy,u_south_var,'field','u_south, scalar, series');

        u_east_var = netcdf.defVar(nc_bdy,'u_east','float',[eu_dim srho_dim v3d_time_dim]);
        netcdf.putAtt(nc_bdy,u_east_var,'long_name','3D u-momentum eastern boundary condition');
        netcdf.putAtt(nc_bdy,u_east_var,'units','meter second-1');
        netcdf.putAtt(nc_bdy,u_east_var,'field','u_east, scalar, series');

        u_west_var = netcdf.defVar(nc_bdy,'u_west','float',[eu_dim srho_dim v3d_time_dim]);
        netcdf.putAtt(nc_bdy,u_west_var,'long_name','3D u-momentum western boundary condition');
        netcdf.putAtt(nc_bdy,u_west_var,'units','meter second-1');
        netcdf.putAtt(nc_bdy,u_west_var,'field','u_west, scalar, series');

        u_north_var = netcdf.defVar(nc_bdy,'u_north','float',[xu_dim srho_dim v3d_time_dim]);
        netcdf.putAtt(nc_bdy,u_north_var,'long_name','3D u-momentum northern boundary condition');
        netcdf.putAtt(nc_bdy,u_north_var,'units','meter second-1');
        netcdf.putAtt(nc_bdy,u_north_var,'field','u_north, scalar, series');

        v_south_var = netcdf.defVar(nc_bdy,'v_south','float',[xv_dim srho_dim v3d_time_dim]);
        netcdf.putAtt(nc_bdy,v_south_var,'long_name','3D v-momentum southern boundary condition');
        netcdf.putAtt(nc_bdy,v_south_var,'units','meter second-1');
        netcdf.putAtt(nc_bdy,v_south_var,'field','v_south, scalar, series');

        v_east_var = netcdf.defVar(nc_bdy,'v_east','float',[ev_dim srho_dim v3d_time_dim]);
        netcdf.putAtt(nc_bdy,v_east_var,'long_name','3D v-momentum eastern boundary condition');
        netcdf.putAtt(nc_bdy,v_east_var,'units','meter second-1');
        netcdf.putAtt(nc_bdy,v_east_var,'field','v_east, scalar, series');

        v_west_var = netcdf.defVar(nc_bdy,'v_west','float',[ev_dim srho_dim v3d_time_dim]);
        netcdf.putAtt(nc_bdy,v_west_var,'long_name','3D v-momentum western boundary condition');
        netcdf.putAtt(nc_bdy,v_west_var,'units','meter second-1');
        netcdf.putAtt(nc_bdy,v_west_var,'field','v_west, scalar, series');

        v_north_var = netcdf.defVar(nc_bdy,'v_north','float',[xv_dim srho_dim v3d_time_dim]);
        netcdf.putAtt(nc_bdy,v_north_var,'long_name','3D v-momentum northern boundary condition');
        netcdf.putAtt(nc_bdy,v_north_var,'units','meter second-1');
        netcdf.putAtt(nc_bdy,v_north_var,'field','v_north, scalar, series');

        temp_south_var = netcdf.defVar(nc_bdy,'temp_south','float',[xrho_dim srho_dim temp_time_dim]);
        netcdf.putAtt(nc_bdy,temp_south_var,'long_name','3D temperature southern boundary condition');
        netcdf.putAtt(nc_bdy,temp_south_var,'units','C');
        netcdf.putAtt(nc_bdy,temp_south_var,'field','temp_south, scalar, series');

        temp_east_var = netcdf.defVar(nc_bdy,'temp_east','float',[erho_dim srho_dim temp_time_dim]);
        netcdf.putAtt(nc_bdy,temp_east_var,'long_name','3D temperature eastern boundary condition');
        netcdf.putAtt(nc_bdy,temp_east_var,'units','C');
        netcdf.putAtt(nc_bdy,temp_east_var,'field','temp_east, scalar, series');

        temp_west_var = netcdf.defVar(nc_bdy,'temp_west','float',[erho_dim srho_dim temp_time_dim]);
        netcdf.putAtt(nc_bdy,temp_west_var,'long_name','3D temperature western boundary condition');
        netcdf.putAtt(nc_bdy,temp_west_var,'units','C');
        netcdf.putAtt(nc_bdy,temp_west_var,'field','temp_west, scalar, series');

        temp_north_var = netcdf.defVar(nc_bdy,'temp_north','float',[xrho_dim srho_dim temp_time_dim]);
        netcdf.putAtt(nc_bdy,temp_north_var,'long_name','3D temperature northern boundary condition');
        netcdf.putAtt(nc_bdy,temp_north_var,'units','C');
        netcdf.putAtt(nc_bdy,temp_north_var,'field','temp_north, scalar, series');

        salt_south_var = netcdf.defVar(nc_bdy,'salt_south','float',[xrho_dim srho_dim salt_time_dim]);
        netcdf.putAtt(nc_bdy,salt_south_var,'long_name','3D salinity southern boundary condition');
        netcdf.putAtt(nc_bdy,salt_south_var,'units','psu');
        netcdf.putAtt(nc_bdy,salt_south_var,'field','salt_south, scalar, series');

        salt_east_var = netcdf.defVar(nc_bdy,'salt_east','float',[erho_dim srho_dim salt_time_dim]);
        netcdf.putAtt(nc_bdy,salt_east_var,'long_name','3D salinity eastern boundary condition');
        netcdf.putAtt(nc_bdy,salt_east_var,'units','psu');
        netcdf.putAtt(nc_bdy,salt_east_var,'field','salt_east, scalar, series');

        salt_west_var = netcdf.defVar(nc_bdy,'salt_west','float',[erho_dim srho_dim salt_time_dim]);
        netcdf.putAtt(nc_bdy,salt_west_var,'long_name','3D salinity western boundary condition');
        netcdf.putAtt(nc_bdy,salt_west_var,'units','psu');
        netcdf.putAtt(nc_bdy,salt_west_var,'field','salt_west, scalar, series');

        salt_north_var = netcdf.defVar(nc_bdy,'salt_north','float',[xrho_dim srho_dim salt_time_dim]);
        netcdf.putAtt(nc_bdy,salt_north_var,'long_name','3D salinity northern boundary condition');
        netcdf.putAtt(nc_bdy,salt_north_var,'units','psu');
        netcdf.putAtt(nc_bdy,salt_north_var,'field','salt_north, scalar, series');

        %% 写入值
        netcdf.putVar(nc_bdy,zeta_time_var,time);
        netcdf.putVar(nc_bdy,temp_time_var,time);
        netcdf.putVar(nc_bdy,salt_time_var,time);
        netcdf.putVar(nc_bdy,v2d_time_var,time);
        netcdf.putVar(nc_bdy,v3d_time_var,time);

        for var=["zeta","u","v","ubar","vbar","temp","salt"]
            east=eval(var+"_east_var");
            west=eval(var+"_west_var");
            north=eval(var+"_north_var");
            south=eval(var+"_south_var");
            write_value(nc_clm,nc_bdy,var,east,south,west,north);
        end

        %% 关闭
        netcdf.close(nc_bdy);
        netcdf.close(nc_clm);

        disp("完成创建："+output_bdy_file)
    catch ex
        try
            netcdf.close(nc_bdy);
            netcdf.close(nc_clm);
        catch ex2
        end
        rethrow(ex);
    end
end


function write_value(nc_clm,nc_bdy,var,east_var,south_var,west_var,north_var)
    clm=netcdf.getVar(nc_clm,netcdf.inqVarID(nc_clm,var));
    if ndims(clm)==3
        value_south=clm(:,1,:);
        value_east=clm(end,:,:);
        value_north=clm(:,end,:);
        value_west=clm(1,:,:);
    elseif ndims(clm)==4
        value_south=clm(:,1,:,:);
        value_east=clm(end,:,:,:);
        value_north=clm(:,end,:,:);
        value_west=clm(1,:,:,:);
    end

    netcdf.putVar(nc_bdy,east_var,value_east);
    netcdf.putVar(nc_bdy,south_var,value_south);
    netcdf.putVar(nc_bdy,west_var,value_west);
    netcdf.putVar(nc_bdy,north_var,value_north);

    clear value_*
end
