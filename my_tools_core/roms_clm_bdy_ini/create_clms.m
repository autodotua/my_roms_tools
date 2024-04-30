function filenames=create_clms(start,stop,step,repeat_years,skip_existed,offset_days,clms_dir)
    arguments
        start(1,1) datetime %开始时间
        stop(1,1) datetime %结束时间
        step(1,1) duration %间隔时间
        % 将已有的数据进行重复，例如只有2021年的数据，那么repeat_years=4，
        % 那么最后写入2021-2024年共4年的数据，每一年都与2021年一样。
        % 如果给定的时间超过一年，那么只取第一年的数据。
        repeat_years(1,1) double =1 %
        skip_existed(1,1) logical =1 %是否跳过已经存在的clm文件
        offset_days(1,1) double=1 % %需要读取的数据源的时间与写入到clm的nc文件的时间之差。比如time=2021-1-1，offset_days=365，那么将会读取2022-1-1的数据源，但写入的时候仍然写入为2021-1-1
        clms_dir(1,1) string="clms"

    end
    configs
    subFolder=clms_dir;
    times=start:step:stop;
    if ~isequal(times(end),stop)
        times=[times,stop];
    end
    if ~exist(subFolder, 'dir')
        mkdir(subFolder)
    end
    lossFiles=0;
    for time=times
        if skip_existed
            name=subFolder+"/clm_"+string(time,'yyyyMMddHH')+".nc";
            if isfile(name)
                disp("文件"+name+"已存在");
                continue;
            end
        end
        lossFile=false;
        if roms.res.hydrodynamics_type=="HYCOM"
            inputFile=fullfile(roms.res.hydrodynamics, string(time+days(offset_days),"yyyyMMddHH")+".nc");
            if ~isfile(inputFile)
                lossFile=true;
                warning("文件不存在："+inputFile)
            end
        elseif roms.res.hydrodynamics_type=="CMEMS"
            for prefix=["c" "t" "s" "z"]
                inputFile=fullfile(roms.res.hydrodynamics, prefix+string(time+days(offset_days),"yyyyMMdd")+".nc");
                if ~isfile(inputFile)
                    lossFile=true;
                    warning("文件不存在："+inputFile)
                    break
                end
            end
        end
        if lossFile
            lossFiles=lossFiles+1;
            continue
        end
        disp("正在处理："+string(time,'yyyyMMddHH'))
        tic
        create_single_clm(time,subFolder+"/clm_"+string(time,'yyyyMMddHH')+".nc",offset_days);
        toc
    end
    if lossFiles>0
        error("缺失"+string(lossFiles)+"个文件文件，处理停止")
    end
    filenames=merge_clms(subFolder,times,repeat_years);