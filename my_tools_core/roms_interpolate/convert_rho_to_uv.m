    function roms_with_z_levels = convert_rho_to_uv(targetType,roms_grid, roms_with_z_levels, data)
    switch targetType
        case 'rho'
            roms_with_z_levels = data;
        case 'u'
            [s,~] = size(roms_grid);
            switch ndims(roms_with_z_levels)
                case 4
                    roms_with_z_levels = 0.5*(data(:,:,1:s,:)+data(:,:,2:s+1,:));
                case 3
                    roms_with_z_levels = 0.5*(squeeze(data(:,1:s,:))+squeeze(data(:,2:s+1,:)));
                case 2
                    roms_with_z_levels = 0.5*(data(1:s,:)+data(2:s+1,:));
            end

        case 'v'
            %disp('正在平均到 v 点网格')
            [~,s] = size(roms_grid);
            switch ndims(roms_with_z_levels)
                case 4
                    roms_with_z_levels = 0.5*(data(:,:,:,1:s)+data(:,:,:,2:s+1));
                case 3
                    roms_with_z_levels = 0.5*(data(:,:,1:s)+data(:,:,2:s+1));
                case 2
                    roms_with_z_levels = 0.5*(data(:,1:s)+data(:,2:s+1));
            end

    end
end
