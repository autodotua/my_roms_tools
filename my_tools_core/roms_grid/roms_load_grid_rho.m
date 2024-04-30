function [lon_rho,lat_rho,mask_rho,h]= roms_load_grid_rho(ncfile)
    if ~exist("ncfile",'var')
        configs
        ncfile=fullfile(roms.project_dir,roms.input.grid);
    end
    lon_rho=read_data(ncfile,'lon_rho');
    lat_rho=read_data(ncfile,'lat_rho');
    mask_rho=read_data(ncfile,'mask_rho');
    h=read_data(ncfile,'h');