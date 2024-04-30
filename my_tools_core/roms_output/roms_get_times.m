function [datetimes,datenums]=roms_get_times(timesOrFile,timeZone)
    arguments
        timesOrFile
        timeZone(1,1) double=0
    end
    configs
    if isstring(timesOrFile) || ischar(timesOrFile)
        if endsWith(timesOrFile,".mat")
            timesOrFile=load(timesOrFile);
            if isfield(timesOrFile,"data") && isstruct(timesOrFile.data)
                timesOrFile=timesOrFile.data;
            end

            if isfield(timesOrFile,"times")
                timesOrFile=timesOrFile.times;
            elseif isfield(timesOrFile,"ocean_time")
                timesOrFile=timesOrFile.ocean_time;
            else
                error("找不到时间变量");
            end
        else
            timesOrFile=read_data(timesOrFile,'ocean_time');
        end
    end
    if timesOrFile>1e5
        timesOrFile=timesOrFile/86400;
    end
    datetimes=datetime(roms.time.base)+double(timesOrFile)+timeZone/24;
    datenums=datenum(datetimes);
