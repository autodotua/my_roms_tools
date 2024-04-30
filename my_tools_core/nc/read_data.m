function data=read_data(file,var,start,count,sizeOnly)
    % 读取nc_compact处理后的数据
    arguments
        file(1,1) string
        var(1,1) string
        start(1,:) double {mustBeInteger} =[]
        count(1,:) double {mustBeInteger} =[]
        sizeOnly(1,1) logical=false
    end
    if var=="DIN"
        data=read_data_core(file,"NO3",start,count)+read_data_core(file,"NH4",start,count);
    elseif var=="DetritusN"
        data=read_data_core(file,"SdetritusN",start,count)+read_data_core(file,"LdetritusN",start,count);
    elseif var=="detritusC"
        data=read_data_core(file,"SdetritusC",start,count)+read_data_core(file,"LdetritusC",start,count);
    elseif var=="DIN_sur"
        data=read_data_core(file,"NO3_sur",start,count)+read_data_core(file,"NH4_sur",start,count);
    elseif var=="NPratio"
        data=(read_data_core(file,"NO3",start,count)+read_data_core(file,"NH4",start,count))./read_data_core(file,"PO4",start,count);
    elseif var=="NPratio_sur"
        data=(read_data_core(file,"NO3_sur",start,count)+read_data_core(file,"NH4_sur",start,count))./read_data_core(file,"PO4_sur",start,count); elseif var=="DetritusN_sur"
        data=read_data_core(file,"SdetritusN_sur",start,count)+read_data_core(file,"LdetritusN_sur",start,count);
    elseif var=="detritusC_sur"
        data=read_data_core(file,"SdetritusC_sur",start,count)+read_data_core(file,"LdetritusC_sur",start,count);
    else
        data=read_data_core(file,var,start,count,sizeOnly);
    end
end

function data=read_data_core(file,var,start,count,sizeOnly)
    arguments
        file(1,1) string
        var(1,1) string
        start(1,:) double {mustBeInteger} =[]
        count(1,:) double {mustBeInteger} =[]
        sizeOnly(1,1) logical=false
    end
    if exist(file,'dir')
        if exist(fullfile(file,var+".nc"),'file') %ncFolder
            file=fullfile(file,var+".nc");
            if sizeOnly
                data=ncinfo(file,var).Size;
            else
                data=readnc(file,var,start,count);
            end
        elseif exist(fullfile(file,var+".mat"),'file') %matFolder
            if sizeOnly
                error("sizeOnly仅支持nc格式");
            end
            if ~isempty(start) || ~isempty(count)
                error("start和count仅支持nc格式");
            end
            data=load(fullfile(file,var+".mat"));
        else
            error("存在目录"+file+"，但不存在名为"+var+"的MAT或nc文件");
        end
    elseif exist(file,'file')
        if endsWith(file,".mat")
            if sizeOnly
                error("sizeOnly仅支持nc格式");
            end
            if ~isempty(start) || ~isempty(count)
                error("start和count仅支持nc格式");
            end
            data=load(file);
            if isfield(data,'data')
                data=data.data;
            end
        else
            if sizeOnly
                data=ncinfo(file,var).Size;
            else
                data=readnc(file,var,start,count);
            end
        end
    else
        error("不存在目录或文件"+file)
    end
end


function data=readnc(file,var,start,count)
    if isempty(start)
        data=ncread(file,var);
    else
        varInfo=ncinfo(file,var);
        for i=1:length(start)
            if start(i)<=0
                start(i)=varInfo.Size(i)+start(i); %0表示end，-1表示end-1，以此类推
            end
        end
        if isempty(count)
            data=ncread(file,var,start);
        else
            for i=1:length(count)
                if count(i)<=0
                    count(i)=varInfo.Size(i)+count(i); %0表示取全部，-1表示最后一个不取，以此类推
                end
            end
            data=ncread(file,var,start,count);
        end
    end
end