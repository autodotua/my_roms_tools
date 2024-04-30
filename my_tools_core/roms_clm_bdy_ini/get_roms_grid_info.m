function roms_grid_info=get_roms_grid_info(gridfile)
    % 获取ROMS网格信息
    arguments
        gridfile(1,1) string
    end
    Vtransform=ncread(gridfile,'Vtransform');
    Vstretching=ncread(gridfile,'Vstretching');
    Tcline=ncread(gridfile,'Tcline');
    N=length(ncread(gridfile,'s_rho'));
    theta_s=ncread(gridfile,'theta_s');
    theta_b=ncread(gridfile,'theta_b');

    if (Vtransform==1)
        h=ncread(gridfile,'h');
        hmin=min(h(:));
        hc=min(max(hmin,0),Tcline);
    elseif (Vtransform==2)
        hc=Tcline;
    end
    gridinfo.hc=hc;
    gridinfo.theta_s=theta_s;
    gridinfo.theta_b=theta_b;
    gridinfo.Vtransform=Vtransform;
    gridinfo.Vstretching=Vstretching;
    gridinfo.Tcline=Tcline;
    gridinfo.N=N;
    roms_grid_info=get_roms_grid(gridfile,gridinfo);
    %翻转z
    roms_grid_info.z_r=shiftdim(roms_grid_info.z_r,2);
    roms_grid_info.z_u=shiftdim(roms_grid_info.z_u,2);
    roms_grid_info.z_v=shiftdim(roms_grid_info.z_v,2);
    roms_grid_info.z_w=shiftdim(roms_grid_info.z_w,2);
end
