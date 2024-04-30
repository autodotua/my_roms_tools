function r = interpolate_z_to_sigma(roms_grid_info,input_z,input_data,type,interpolate_method)
    arguments
        roms_grid_info
        input_z(:,:,:)
        input_data(:,:,:)
        type char {mustBeMember(type,{'rho','u','v'})}
        interpolate_method string {mustBeMember(interpolate_method,["linear","nearest","natural","spline"])} ="spline";
    end
    roms_lon = roms_grid_info.(['lon_', type]);
    r = [];
    %% 根据输入数据的维度，生成一个与ROMS网格信息相同的数组
    if ndims(input_data) == 4 %XYZT
        time_step_count = size(input_data,1);
        input_z_level_count = size(input_data,2);
        roms_with_z_levels = zeros([time_step_count input_z_level_count size(roms_lon)]);
        roms_level_count = size(roms_grid_info.z_r,1);
        r = zeros([time_step_count roms_level_count size(roms_lon)]);

    elseif ndims(input_data) == 3 %XYZ
        time_step_count = 1;%number of time steps
        input_z_level_count = size(input_data,1);%number of z levels
        roms_with_z_levels = zeros([input_z_level_count size(roms_lon)]);
        roms_level_count = size(roms_grid_info.z_r,1);
        r = zeros([roms_level_count size(roms_lon)]);

    elseif ismatrix(input_data) %XY
        time_step_count = 1;
        input_z_level_count = 1;
        roms_with_z_levels = zeros(size(roms_lon));

    else
        error('data的维度应为2、3或4')
    end

    %% 确保Z坐标与ROMS的规范一致
    % 强制zlev为从浅到深负值，以符合ROMS标准
    input_z = -abs(input_z(:));
    % 检查数据是否按照从深到浅的顺序排列
    if input_z_level_count>1 && any(diff(input_z)<0)
        % 深度是由浅到深排列的，翻转一下
        % disp('反转zlevs，使其从深到浅排列');
        input_z = flipud(input_z);
        input_data = flip(input_data,ndims(input_data)-2);
    end

    %% 将水平数据转换到合适的网格
    roms_with_z_levels = convert_rho_to_uv(type, roms_lon,roms_with_z_levels, input_data);


    %% 根据输入的类型（'u'或'v'），计算ROMS网格的z_r数组的平均值
    zr = roms_grid_info.z_r;
    switch type
        case 'u'
            s = size(zr,2);
            zr = 0.5*(zr(:,1:s-1,:)+zr(:,2:s,:)); % 计算z_r数组的第二维的平均值
        case 'v'
            s = size(zr,3);
            zr = 0.5*(zr(:,:,1:s-1)+zr(:,:,2:s)); % 计算z_r数组的第三维的平均值
    end

    %% 将XYZ沿着Y切成n片，然后对每一片进行散点插值
    switch ndims(r)
        case 4
            for l=1:time_step_count
                Nx = size(r,3);
                parfor i=1:Nx % x index
                    z = squeeze(zr(:,i,:));
                    s = size(z,2);
                    x = repmat(1:s,[roms_level_count 1]);
                    [xa,za] = meshgrid(1:s,[-10000; -abs(input_z); 10]);
                    input_data = squeeze(roms_with_z_levels(l,:,i,:));
                    input_data = [input_data(1,:); input_data; input_data(input_z_level_count,:)];
                    if interpolate_method=="natural"
                        F = scatteredInterpolant(xa(:),za(:),input_data(:),interpolate_method);
                        r(l,:,i,:) =F(x,z);
                        %使用scatteredInterpolant比interp2慢了不少，但是可以用natural法
                    else
                        r(l,:,i,:) = interp2(xa,za,input_data,x,z,interpolate_method);
                    end
                end
            end

        case 3
            Nx = size(r,2);
            parfor i=1:Nx
                % 循环每个 x 索引
                z = squeeze(zr(:,i,:)); % 取出 zr 的第 i 列，形成一个XZ平面的深度矩阵
                s = size(z,2); % 取出 z 的列数
                x = repmat(1:s,[roms_level_count 1]); % 生成一个大小为 roms_level_count * s 的矩阵，每一行都是 1:s
                % 可能有一些 ROMS z 值超出了 stdlev z 的范围，所以在插值之前要在上下方填充一些值
                % 如果数据中有一些非常深的深度有 NaN 值，可能还会有一个问题
                [xa,za] = meshgrid(1:s,[-10000; -abs(input_z); 10]); % 生成一个大小为 x * (s+2) 的矩阵，第一行是 -10000，最后一行是 10
                input_data = squeeze(roms_with_z_levels(:,i,:)); % 取出 roms_with_z_levels 的第 i 列，形成一个XZ平面的值矩阵
                input_data = [input_data(1,:); input_data; input_data(input_z_level_count,:)]; % 在 input_data 的第一行和最后一行分别添加第一行和最后一行的数据
                input_data((isnan(input_data)))=0;
                % spline 方法是一种三次样条插值，它可以产生平滑的曲面，但也可能在数据不光滑的情况下出现超调。
                if interpolate_method=="natural"
                    % 使用自然邻点插值
                    F = scatteredInterpolant(xa(:),za(:),input_data(:),interpolate_method);
                    r(:,i,:) =F(x,z);
                    % 使用 scatteredInterpolant 比 interp2 慢了不少，但是可以用 natural 法
                else
                    % 使用三次样条插值
                    r(:,i,:) = interp2(xa,za,input_data,x,z,interpolate_method);
                end
            end
    end
end
