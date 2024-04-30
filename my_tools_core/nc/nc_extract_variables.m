function nc_extract_variables(filename,variables,output)
    arguments
        filename(1,1) string
        variables(:,1) string =[]
        output(1,1) string=""
    end
    ncid = netcdf.open(filename,'NC_NOWRITE');
    [~, nvars, ~, ~] = netcdf.inq(ncid);

    for m=0:nvars-1
        [varname, ~, ~, ~] = netcdf.inqVar(ncid,m);
        if ismember(varname,variables) || numel(variables)==0
            val = ncread(filename,varname);
            assignhere(varname,val);
            disp(['已提取',varname])
        end

    end

    netcdf.close(ncid)
    if numel(char(output))>0
        clear filename variables varname nvars ncid val m
        save(output,'-v7.3')
        file=dir(output);
        size=file.bytes/(1024*1024);
        disp(['已保存到',char(output),'，大小为',num2str(size),'MB'])
    end

function assignhere(varname,varvalue)
    assignin('caller',varname,varvalue);
    return