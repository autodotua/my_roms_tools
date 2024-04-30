function configs (river_count,tracer_count)
    arguments
        river_count(1,1) double{mustBeInteger}=1
        tracer_count(1,1) double{mustBeInteger}=1
    end
    clear roms

    %% 路径

    %项目目录
    roms.project_dir='C:\Users\autod\Desktop\dhbio';
    %模式运行目录
    roms.build_dir='C:\Users\autod\Desktop';

    %% 时间
    %开始时间
    roms.time.start=[2021,1,1,0,0,0];
    %结束时间
    roms.time.stop=[2022,1,1,0,0,0];
    %基准时间，简化儒略历的开始时间
    roms.time.base=[1858,11,17,0,0,0];
    %开始时刻的简化儒略日
    roms.time.start_julian=juliandate(datetime(roms.time.start),'modifiedjuliandate');
    %结束时刻的简化儒略日
    roms.time.stop_julian=juliandate(datetime(roms.time.stop),'modifiedjuliandate');
    %总天数
    roms.time.days=roms.time.stop_julian-roms.time.start_julian+1;
    %% 网格
    %经度范围
    %roms.grid.longitude=[120.42,122.52];
    %纬度范围
    %roms.grid.latitude=[29.86,31.13];
    %网格数量，与in文件Lm和Mm的相同，比rho、xi_v、eta_u少2，比xi_u、eta_v、psi少1
    roms.grid.size=[300 300];
    %垂向分层
    roms.grid.N           = 15;
    %地形跟随坐标θs参数
    roms.grid.theta_s     =  8;
    %地形跟随坐标θb参数
    roms.grid.theta_b     =  4;
    %地形跟随坐标最小值
    roms.grid.Tcline      = 20;
    %最小深度值
    roms.grid.Hmin      =10;
    %地形跟随坐标Vtransform参数
    roms.grid.Vtransform  =  2;
    %地形跟随坐标Vstretching参数
    roms.grid.Vstretching =  4;



    %% 输入文件
    %网格文件
    roms.input.grid='roms_grid.nc';
    %气象场强迫文件
    roms.input.atom = 'roms_atom.nc';
    %气象场强迫文件
    roms.input.atom_radiation = 'roms_rad.nc';
    %气候态文件
    roms.input.climatology = 'roms_clm.nc';
    %气候态文件（生物）
    roms.input.climatology_biology = 'roms_clm_bio.nc';
    %初始场文件
    roms.input.initialization = 'roms_ini.nc';
    %初始场文件（备份）
    roms.input.initialization_raw = 'roms_ini_raw.nc';
    %边界场文件
    roms.input.boundary = 'roms_bdy.nc';
    %边界场文件（生物）
    roms.input.boundary_biology = 'roms_bdy_bio.nc';
    %潮汐强迫文件
    roms.input.tides = 'roms_tides.nc';
    %河流定义文件
    roms.input.rivers='roms_rivers.nc';
    %气候态逼近系数文件
    roms.input.nudgcoef='roms_nud.nc';

    %% 输出文件
    %ROMS输出历史文件
    roms.output.hisotry='ocean_his.nc';
    roms.output.floats='ocean_flt.nc';


    %% 数据资源路径
    %==========气象==========
    %包含ncep的fnl大气资料的目录
    roms.res.force_ncep_dir="data\fnl";
    %气象强迫时间分辨率，单位为小时
    roms.res.force_ncep_step=6;
    roms.res.force_ncep_radiation_files="C:\Users\autod\Desktop\hzw\gdas1.fnl0p25.2020010100-25.2020123118.f03.grib2.nc\gdas1.fnl0p25.yyyymmddhh.f03.grib2.nc";
    roms.res.force_era5_radiation_file='data/era5.nc';

    %==========潮汐==========
    %潮汐水平运动文件
    roms.res.tpx_uv='data/tpx_uv.mat';
    %潮汐高度文件
    roms.res.tpx_h='data/tpx_h.mat';
    %高精度潮汐文件目录
    roms.res.tpxo9='data/tpxo9';
    %使用高精度潮汐时，估计模式运行的时间
    roms.res.tpxo9_days=365*10;

    %==========水动力==========
    roms.res.hydrodynamics='data\hycom';
    %roms.res.hydrodynamics='data\CMEMS';
    roms.res.hydrodynamics_type='HYCOM';
    %roms.res.hydrodynamics_type='CMEMS';
    roms.res.hydrodynamics_step_time_hour=3;

    roms.res.hycom_latitude='lat';
    roms.res.hycom_longitude='lon';
    roms.res.hycom_depth='depth';
    roms.res.hycom_time='time'; 
    roms.res.hycom_t0dt=datetime(2000,1,1);
    roms.res.hycom_t0=datenum(roms.res.hycom_t0dt);
    roms.res.hycom_tunit=24; 
    roms.res.hycom_u='water_u'; 
    roms.res.hycom_v='water_v'; 
    roms.res.hycom_temp='water_temp';
    roms.res.hycom_salt='salinity'; 
    roms.res.hycom_surface_elevation='surf_el'; 


    roms.res.cmems_latitude='latitude';
    roms.res.cmems_longitude='longitude';
    roms.res.cmems_depth='depth';
    roms.res.cmems_time='time'; 
    roms.res.cmems_u='uo'; 
    roms.res.cmems_v='vo'; 
    roms.res.cmems_temp='thetao';
    roms.res.cmems_salt='so'; 
    roms.res.cmems_surface_elevation='zos'; 

    %% 生物
    roms.biology.model="fennel"; %fennel cosine
    
    %% 被动示踪剂
    %示踪剂数量（变量的数量）
    roms.tracer.count=tracer_count;
    if roms.tracer.count>0
        %是否启用示踪剂平均年龄（需要定义MEAN_AGE）
        roms.tracer.age=0;
        %示踪剂的密度
        roms.tracer.densities=cell(roms.tracer.count,1);
        %示踪剂的平均年龄
        roms.tracer.ages=cell(roms.tracer.count,1);
        roms.tracer.times=[0,roms.time.days];
        roms.tracer.east=cell(roms.tracer.count,1);
        roms.tracer.west=cell(roms.tracer.count,1);
        roms.tracer.south=cell(roms.tracer.count,1);
        roms.tracer.north=cell(roms.tracer.count,1);
        roms.tracer.east_age=cell(roms.tracer.count,1);
        roms.tracer.west_age=cell(roms.tracer.count,1);
        roms.tracer.south_age=cell(roms.tracer.count,1);
        roms.tracer.north_age=cell(roms.tracer.count,1);

        for i=1:numel(roms.tracer.densities)
            roms.tracer.densities{i}=zeros(roms.grid.size(1)+2,roms.grid.size(2)+2,roms.grid.N,1);
            roms.tracer.ages{i}=zeros(roms.grid.size(1)+2,roms.grid.size(2)+2,roms.grid.N,1);
            roms.tracer.east{i}=zeros(roms.grid.size(2)+2,roms.grid.N,numel(roms.tracer.times));
            roms.tracer.west{i}=zeros(roms.grid.size(2)+2,roms.grid.N,numel(roms.tracer.times));
            roms.tracer.south{i}=zeros(roms.grid.size(1)+2,roms.grid.N,numel(roms.tracer.times));
            roms.tracer.north{i}=zeros(roms.grid.size(1)+2,roms.grid.N,numel(roms.tracer.times));
            roms.tracer.east_age{i}=zeros(roms.grid.size(2)+2,roms.grid.N,numel(roms.tracer.times));
            roms.tracer.west_age{i}=zeros(roms.grid.size(2)+2,roms.grid.N,numel(roms.tracer.times));
            roms.tracer.south_age{i}=zeros(roms.grid.size(1)+2,roms.grid.N,numel(roms.tracer.times));
            roms.tracer.north_age{i}=zeros(roms.grid.size(1)+2,roms.grid.N,numel(roms.tracer.times));
        end
    end

    %% 河流
    %河流数量
    roms.rivers.count=river_count;
    if roms.rivers.count>0
        %河流的流向，0为u方向，1为v方向，2为w方向
        roms.rivers.direction=ones(roms.rivers.count,1)*2;
        %定义时间，开始时间为0时刻。
        roms.rivers.time=[0:roms.time.days];
        %河流的位置，每一行为一条河流的水平坐标值
        roms.rivers.location=zeros(roms.rivers.count,2);
        %不同时间的河流流量，每一行一条河流，列数为时间数。
        roms.rivers.transport=ones(roms.rivers.count,numel(roms.rivers.time));
        %不同垂直层之间的流量分配，每一行为一条河流，每条河流流量总和为1。
        roms.rivers.v_shape=ones(roms.rivers.count,roms.grid.N)/roms.grid.N;
        %温度数据
        roms.rivers.temp=ones(roms.rivers.count,roms.grid.N,numel(roms.rivers.time));
        %盐度数据
        roms.rivers.salt=ones(roms.rivers.count,roms.grid.N,numel(roms.rivers.time));
        %被动示踪剂数据，数量应和roms.tracer.count相同。
        roms.rivers.dye=cell(roms.tracer.count,1);
        %被动示踪剂初始年龄，数量应和roms.tracer.count相同。
        roms.rivers.ages=cell(roms.tracer.count,1);

        for i=1:numel(roms.rivers.dye)
            roms.rivers.dye{i}=ones(roms.rivers.count,roms.grid.N,numel(roms.rivers.time));
            roms.rivers.ages{i}=ones(roms.rivers.count,roms.grid.N,numel(roms.rivers.time));
        end
    end

    %% 输入输出
    %压缩级别，1-9，越高压缩比越高，0表示不压缩
    roms.io.deflate=0;
    %压缩时是否开启乱序数据写入
    roms.io.shuffle=false;
    %% 导出变量
    %configs_check(roms)
    assignin('caller','roms',roms);
end




%% 检查
function configs_check(roms)
    is_true(isfolder(roms.project_dir),"roms.project_dir指定的目录不存在")

    is_size_of(roms.time.start,6)
    is_size_of(roms.time.stop,6)
    is_true(roms.time.days>0,"停止时间应晚于开始时间")

%     is_size_of(roms.grid.longitude,2)
%     is_true( roms.grid.longitude(2)>roms.grid.longitude(1),"经度范围错误")
%     is_size_of(roms.grid.latitude,2)
%     is_true(roms.grid.latitude(2)>roms.grid.latitude(1),"纬度范围错误")
    is_size_of(roms.grid.size,2)
    is_positive( roms.grid.size)
    is_size_of(roms.grid.N,1)
    is_positive_integer(roms.grid.N)
    is_size_of(roms.grid.theta_s,1)
    is_zero_or_positive(roms.grid.theta_s)
    is_size_of(roms.grid.theta_b,1)
    is_zero_or_positive(roms.grid.theta_b)
    is_size_of(roms.grid.Tcline,1)
    is_positive(roms.grid.Tcline)
    is_in(roms.grid.Vtransform,[1,2])
    is_in(roms.grid.Vstretching,[1:4])

    if roms.tracer.count>0
        is_size_of(roms.tracer.densities,[roms.tracer.count,1])
        is_all_size_of(roms.tracer.densities,[roms.grid.size(1)+2,roms.grid.size(2)+2,roms.grid.N])
    end

    if roms.rivers.count>0
        is_size_of(roms.rivers.count,1)
        is_positive_integer(roms.rivers.count)
        is_size_of(roms.rivers.direction,[roms.rivers.count,1])
        is_in(roms.rivers.direction,[0:2])
        is_natural_integer(roms.rivers.time)
        is_size_of(roms.rivers.location,[roms.rivers.count,2])
        is_natural_integer(roms.rivers.location)
        is_size_of(roms.rivers.transport,[roms.rivers.count,numel(roms.rivers.time)])
        is_natural_integer(roms.rivers.transport)
        is_size_of(roms.rivers.v_shape,[roms.rivers.count,roms.grid.N])
        is_zero_or_positive(roms.rivers.v_shape)
        is_equal(round(sum(roms.rivers.v_shape,2),5),ones(roms.rivers.count,1),"roms.rivers.v_shape每一行的和应为1",true)
        is_size_of(roms.rivers.temp,[roms.rivers.count,roms.grid.N,numel(roms.rivers.time)])
        is_true(roms.rivers.temp>=-20,"存在低于-20℃的温度",true)
        is_true(roms.rivers.temp<=40,"存在高于40℃的温度",true)
        is_size_of(roms.rivers.salt,[roms.rivers.count,roms.grid.N,numel(roms.rivers.time)])
        is_zero_or_positive(roms.rivers.salt)
        is_size_of(roms.rivers.dye,[roms.tracer.count,1])
        if roms.tracer.count>0
            is_all_size_of(roms.rivers.dye,[roms.rivers.count,roms.grid.N,numel(roms.rivers.time)])
        end
    end
end

function is_true(state,error_msg,warn_only)
    arguments
        state
        error_msg(1,1) string
        warn_only(1,1) double = false
    end
    if numel(state)>1
        for i=reshape(state,1,numel(state))
            is_true(i,error_msg)
        end
        return
    end
    if ~state
        if warn_only
            warning(error_msg)
        else
            error(error_msg)
        end
    end
end

function is_equal(a,b,error_msg,warn_only)
    arguments
        a
        b
        error_msg(1,1) string
        warn_only(1,1) double = false
    end
    is_true(isequal(a,b),error_msg,warn_only)
end

function is_size_of(array,s)
    if numel(s)==1
        is_true(isequal(size(array),[1,s]) || isequal(size(array),[s,1]),['数组的长度应为',num2str(s)])
    else
        is_equal( size(array),s,['数组的长度应为',num2str(s)])
    end
end

function is_all_size_of(cells,s)
    for c=cells
        is_size_of(cells{1},s)
    end
end

function is_positive_integer(n)
    if numel(n)>1
        for i=reshape(n,1,numel(n))
            is_positive_integer(i)
        end
        return
    end
    is_true(rem(n,1) == 0 && n > 0,'应为正整数')
end

function is_natural_integer(n)
    if numel(n)>1
        for i=reshape(n,1,numel(n))
            is_natural_integer(i)
        end
        return
    end
    is_true(rem(n,1) == 0 && n >= 0,'应为自然数')
end

function is_positive(n)
    if numel(n)>1
        for i=reshape(n,1,numel(n))
            is_positive(i)
        end
        return
    end
    is_true(n > 0,'应为正数')
end


function is_zero_or_positive(n)
    if numel(n)>1
        for i=reshape(n,1,numel(n))
            is_zero_or_positive(i)
        end
        return
    end
    is_true(n >= 0,'应为0或正数')
end


function is_in(n,array)

    if numel(n)>1
        for i=reshape(n,1,numel(n))
            is_in(i,array)
        end
        return
    end
    is_true(ismember(n,array),['应取以下值：',num2str(array)])
end
