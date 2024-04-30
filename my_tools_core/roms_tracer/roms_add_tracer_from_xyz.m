function roms_add_tracer_from_xyz(input,output,clm,bdy,ini,options)
    %输入nc（XYZ坐标）文件，输入文件的xyz变量名，输入文件的数据变量名，维度（2/3），
    %要写入到初始场文件的变量名，全名，单位，时间属性，坐标属性

    arguments
        input.inputFile(1,:) string %输入的XYZ坐标的nc文件
        input.xvar(1,1) string %nc文件的经度变量名
        input.yvar(1,1) string %nc文件的纬度变量名
        input.zvar(1,1) string %nc文件的深度变量名
        input.vvar(1,1) string %nc文件的值变量名
        input.times(1,:) double
        input.mag(1,1) double =1
        input.depthValueFunc(2,:) double=[];
        input.dim(1,1) double {mustBeInRange(input.dim,2,3),mustBeInteger} %维度

        output.type(1,1) string {mustBeMember(output.type,["u","v","rho",""])} %坐标类型
        output.units(1,1) string

        clm.clmFile(1,:) string %写入的ROMS气候态文件
        clm.clmVarName(1,1) string
        clm.clmVarLongName(1,1) string
        clm.clmDimX(1,1) string='xrho'
        clm.clmDimY(1,1) string='erho'
        clm.clmDimZ(1,1) string='s_rho'

        bdy.bdyFile(1,:) string %写入的ROMS边界文件
        bdy.bdyVarName(1,1) string
        bdy.bdyDimX(1,1) string='xrho'
        bdy.bdyDimY(1,1) string='erho'
        bdy.bdyDimZ(1,1) string='s_rho'

        ini.iniFile(1,:) string %写入的ini初始场文件
        ini.iniVarName(1,1) string
        ini.iniVarLongName(1,1) string
        ini.iniDimX(1,1) string='xrho'
        ini.iniDimY(1,1) string='erho'
        ini.iniDimZ(1,1) string='sc_r'

        options.roms_grid_info struct =[] %ROMS网格信息。如果不提供，则自动检测
        options.interpolate_method(1,1) string {mustBeMember(options.interpolate_method,["linear","nearest","natural","spline"])} ="linear"; %z转σ坐标的插值方法

    end

    % 建立缓存，防止同一个文件中同一个变量被重复插值以浪费时间
    global dataCache
    if isempty(dataCache)
        dataCache=containers.Map();
    end

    processClm=~isempty(clm.clmFile) && clm.clmFile~="";
    processBdy=~isempty(bdy.bdyFile) && bdy.bdyFile~="";
    processIni=~isempty(ini.iniFile) && ini.iniFile~="";

    configs
    if isempty(options.roms_grid_info)
        options.roms_grid_info=get_options.roms_grid_info(roms.input.grid);
    end

    if processIni&&~processBdy&&~processClm %仅处理初始场，则只需要首个时间
        input.inputFile=input.inputFile(1);
        input.times=input.times(1);
    end

    if length(input.inputFile)==1 %单个文件，一个时间
        if isKey(dataCache,input.inputFile+input.vvar)
            disp("从缓存中提取"+input.inputFile+"的"+input.vvar+"变量")
            data=dataCache(input.inputFile+input.vvar);
        else
            disp("正在插值"+input.inputFile+"的"+input.vvar+"变量到ROMS网格")
            data=interpolate_xyz_to_sigma(input.inputFile,input.xvar,input.yvar,input.zvar,input.vvar,output.type,input.dim,options.roms_grid_info,"xyz",options.interpolate_method,input.depthValueFunc);
            dataCache(input.inputFile+input.vvar)=data;
        end
    else %多个文件，多个时间
        data=[];
        for nc=input.inputFile
            if isKey(dataCache,nc+input.vvar)
                disp("从缓存中提取"+nc+"的"+input.vvar+"变量")
                singleData=dataCache(nc+input.vvar);
            else
                disp("正在插值"+nc+"的"+input.vvar+"变量到ROMS网格")
                singleData=interpolate_xyz_to_sigma(nc,input.xvar,input.yvar,input.zvar,input.vvar,output.type,input.dim,options.roms_grid_info,"xyz",options.interpolate_method,input.depthValueFunc);
                dataCache(nc+input.vvar)=singleData;
            end

            if isempty(data)
                data=singleData;
            else
                data=cat(4,data,singleData);
            end
        end
        if size(data,4)~=length(input.times)
            error("输入文件的时间维度为"+string(size(data,4))+"，而给定的input.times长度为"+string(length(input.times)))
        end
    end
    if input.mag~=1
        data=data.*input.mag;
    end
    if processClm
        disp("正在写入变量到ROMS气候态文件")
        roms_add_tracer_to_clm_nc(clm.clmFile,clm.clmVarName,data,input.times,clm.clmVarLongName,output.units, ...
            dim_x=clm.clmDimX, dim_y=clm.clmDimY, dim_z=clm.clmDimZ)
    end

    if processBdy
        disp("正在写入变量到ROMS边界文件")
        roms_add_tracer_to_bdy_nc(bdy.bdyFile,bdy.bdyVarName,data,input.times,output.units, ...
            dim_x=bdy.bdyDimX, dim_y=bdy.bdyDimY, dim_z=bdy.bdyDimZ)
    end

    if processIni
        disp("正在写入变量到ROMS初始场文件")
        roms_add_tracer_to_clm_nc(ini.iniFile,ini.iniVarName,data(:,:,:,1),input.times(1),ini.iniVarLongName,output.units, ...
            dim_x=ini.iniDimX, dim_y=ini.iniDimY, dim_z=ini.iniDimZ)
    end