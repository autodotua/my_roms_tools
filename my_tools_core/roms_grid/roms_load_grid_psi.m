function [lon_psi,lat_psi,mask_psi]= roms_load_grid_psi(gridFile)
    if ~exist("gridFile",'var')
        configs
        gridFile=fullfile(roms.project_dir,roms.input.grid);
    end
    lon_psi=read_data(gridFile,'lon_psi');
    lat_psi=read_data(gridFile,'lat_psi');
    mask_psi=read_data(gridFile,'mask_psi');