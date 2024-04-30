function roms_create_clm_bdy_ini(skip_existed,repeat_years,delete_clms,offset_days,clms_dir)
    arguments
        skip_existed(1,1) logical=1 %是否跳过单个已存在的clm文件
        % 将已有的数据进行重复，例如只有2021年的数据，那么repeat_years=4，
        % 那么最后写入2021-2024年共4年的数据，每一年都与2021年一样。
        % 如果给定的时间超过一年，那么只取第一年的数据。
        repeat_years(1,1) double =1
        delete_clms(1,1) logical=0 %是否在合并后删除单时刻的clm文件
        offset_days(1,1) double=0 % %需要读取的数据源的时间与写入到clm的nc文件的时间之差。比如time=2021-1-1，offset_days=365，那么将会读取2022-1-1的数据源，但写入的时候仍然写入为2021-1-1
        clms_dir(1,1) string="clms"
    end
    configs
    proj_dir=cd(roms.project_dir);
    roms_fix_h
    start=datetime(roms.time.start);%+hours(roms.res.hycom_local_step_hour);
    stop=datetime(roms.time.stop);
    step=hours(roms.res.hydrodynamics_step_time_hour);
    roms_grid_info=get_roms_grid_info(roms.input.grid);
    files=create_clms(start,stop,step,repeat_years,skip_existed,offset_days,clms_dir);
    create_bdy(roms.input.climatology,roms.input.boundary,roms_grid_info);
    updatinit_coawst_mw(files(1), roms_grid_info, roms.input.initialization, roms.project_dir, datenum(roms.time.start));
    copyfile(roms.input.initialization,roms.input.initialization_raw)
    if delete_clms
        for file=files
            delete(file)
        end
    end
    cd(proj_dir)