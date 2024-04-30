function filenames=merge_clms(subFolder,times,repeat_years)
    arguments
        subFolder(1,1) string %存放单时刻clm文件的子文件夹
        times(1,:) datetime
        repeat_years(1,1) double =1 
        % 将已有的数据进行重复，例如只有2021年的数据，那么repeat_years=4，
        % 那么最后写入2021-2024年共4年的数据，每一年都与2021年一样。
        % 如果给定的时间超过一年，那么只取第一年的数据。
    end
    configs
    if repeat_years>1 && length(unique(year(times)))>1
        times=times(year(times)==year(times(1)));
    end
    filenames=subFolder+"/clm_"+string(times,"yyyyMMddHH")+".nc";
    count=length(filenames);
    roms_grid_info=get_roms_grid_info(roms.input.grid);
    nctimes=times;
    for i=2:repeat_years
        nctimes=[nctimes,times+years(i-1)];
    end
    create_clm_nc(roms.input.climatology,nctimes,roms_grid_info);
    info=ncinfo(roms.input.climatology);
    out=roms.input.climatology;
    for i=1:count*repeat_years
        in=filenames(1+mod(i-1,count));
        for var=info.Variables
            disp("正在合并："+in+"，当前变量："+string(var.Name))
            try
                tic
                data=ncread(in,var.Name);
                switch length(var.Dimensions)
                    case 1
                        if endsWith(var.Name,"time")
                            ncwrite(out,var.Name,juliandate(nctimes(i),'modifiedjuliandate'),i);
                        else
                            ncwrite(out,var.Name,data,i);
                        end
                    case 2
                        try
                            ncwrite(out,var.Name,data,[1,i]);
                        catch
                        end
                    case 3
                        ncwrite(out,var.Name,data,[1,1,i]);
                    case 4
                        ncwrite(out,var.Name,data,[1,1,1,i]);
                end
                toc
            catch ex
                warning(ex.message)
            end
        end
    end
    disp 创建clm完成
end
