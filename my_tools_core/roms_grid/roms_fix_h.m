function roms_fix_h
    %将所有的深度小于Hmin的点的深度修改到Hmin
    configs
    mask=ncread(roms.input.grid,'mask_rho');
    h=ncread(roms.input.grid,'h');
    h(h<roms.grid.Hmin)=roms.grid.Hmin;
    h(mask==0)=roms.grid.Hmin;
    ncwrite(roms.input.grid,'h',h);