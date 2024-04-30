function create_single_clm(time,output,offset_days)
    % 创建单个时间的水文数据快照
    arguments
        time(1,1) datetime %时间
        output(1,1) string ="clm_"+string(time,'yyyyMMddHH')+".nc" %输出文件名
        offset_days(1,1) double=0 %需要读取的数据源的时间与写入到clm的nc文件的时间之差。比如time=2021-1-1，offset_days=365，那么将会读取2022-1-1的数据源，但写入的时候仍然写入为2021-1-1
    end
    time=time+days(offset_days);
    configs
    time=datetime(time);
    roms_grid_info=get_roms_grid_info(roms.input.grid); %获取ROMS网格信息
    if roms.res.hydrodynamics_type=="HYCOM"
        file=fullfile(roms.res.hydrodynamics, string(time,'yyyyMMddHH')+".nc"); %HYCOM文件
        cfile=file;
        tfile=file;
        sfile=file;
        zfile=file;
        input_x=roms.res.hycom_longitude;
        input_y=roms.res.hycom_latitude;
        input_z=roms.res.hycom_depth;
        input_u=roms.res.hycom_u;
        input_v=roms.res.hycom_v;
        input_temp=roms.res.hycom_temp;
        input_salt=roms.res.hycom_salt;
        input_zeta=roms.res.hycom_surface_elevation;
    elseif roms.res.hydrodynamics_type=="CMEMS"
        cfile=fullfile(roms.res.hydrodynamics, "c"+string(time,'yyyyMMdd')+".nc");
        tfile=fullfile(roms.res.hydrodynamics, "t"+string(time,'yyyyMMdd')+".nc");
        sfile=fullfile(roms.res.hydrodynamics, "s"+string(time,'yyyyMMdd')+".nc");
        zfile=fullfile(roms.res.hydrodynamics, "z"+string(time,'yyyyMMdd')+".nc");
        input_x=roms.res.cmems_longitude;
        input_y=roms.res.cmems_latitude;
        input_z=roms.res.cmems_depth;
        input_u=roms.res.cmems_u;
        input_v=roms.res.cmems_v;
        input_temp=roms.res.cmems_temp;
        input_salt=roms.res.cmems_salt;
        input_zeta=roms.res.cmems_surface_elevation;
    end

    rawu=interpolate_xyz_to_sigma(cfile,input_x,input_y,input_z,input_u,'u',3,roms_grid_info);
    rawv=interpolate_xyz_to_sigma(cfile,input_x,input_y,input_z,input_v,'v',3,roms_grid_info);
    [u,v,theta]=rotate_uv(roms_grid_info, rawu, rawv); %旋转UV。对于横平竖直网格，这一步做了和没做没什么区别。
    [ubar,vbar]=get_bar(roms_grid_info, rawu,rawv,theta); %获取UV压力
    temp=interpolate_xyz_to_sigma(tfile,input_x,input_y,input_z,input_temp,'rho',3,roms_grid_info);
    salt=interpolate_xyz_to_sigma(sfile,input_x,input_y,input_z,input_salt,'rho',3,roms_grid_info);
    zeta=interpolate_xyz_to_sigma(zfile,input_x,input_y,input_z,input_zeta,'u',2,roms_grid_info);  temp(temp<0)=0; %不考虑海冰
    salt(salt<0)=0;
    time=time-days(offset_days);
    create_clm_nc(output,time,roms_grid_info,u,v,ubar,vbar,temp,salt,zeta); %创建文件
    disp("完成创建："+output)
end
