function nc_compact(input,output,outputFormat,toSingle, z, nc, filter)
    %从nc文件中读取每个变量，如果为多层变量则仅读取表层，然后保存到一个mat文件中
    arguments
        input(1,1) string %输入的nc文件
        output(1,1) string %输出的mat文件或包含mat/nc文件的目录
        outputFormat(1,1) string {mustBeMember(outputFormat,["mat","matFolder","ncFolder"])}
        %指示输出格式:
        % mat代表单个mat文件，其中含有包含所有变量的结构体data;
        % matFolder代表输出到一个目录，目录中每个变量存放到一个单独的mat文件中，变量名恒为data；
        % ncFolder代表输出到一个目录，目录中每个变量存放到一个单独的nc文件中。
        toSingle(1,1) logical %是否将double转为single
        z.removeZ(1,1) logical =0 %是否仅保留单个或若干个维度
        z.zDimNames(:,1) string ="" %可能为z维的维度名
        z.surfaceLevelIndex(:,1) double {mustBeInteger,mustBePositive} =1 %需要提取的z维的索引
        nc.deflate(1,1) logical=1 %若输出为nc文件，是否压缩
        nc.deflateLevel(1,1) {mustBeInteger,mustBeInRange(nc.deflateLevel,1,9)} =5 %若输出为nc文件且压缩，设置压缩级别（1-9）
        filter.filterMode(1,1) string {mustBeMember(filter.filterMode,["none","white","black"])} ="none" %是否开启黑白名单
        filter.filterList(:,1) string =[] %黑名单或白名单的变量名

    end

    if endsWith(outputFormat,"Folder")
        if ~exist(output,'dir')
            mkdir(output)
        end
    end

    % 读取NetCDF文件
    ncInfo = ncinfo(input);
    varNames = {ncInfo.Variables.Name};

    % 检查每个变量的维度
    data = struct();
    if outputFormat=="ncFolder"
        parfor i = 1:numel(varNames)
            varName = varNames{i};
            if filter.filterMode=="white" && ~ismember(varName,filter.filterList) ...
                || filter.filterMode=="black" && ismember(varName,filter.filterList)
                disp("跳过"+varName)
                continue
            end
            disp(varName)
            
            [varInfo,varData]=get_var_data(input,ncInfo,varName,toSingle,z);

            ncID=0;
            try
                ncID=netcdf.create(fullfile(output,varName+".nc"),bitor(0,4096));
                netcdf.putAtt(ncID,netcdf.getConstant('NC_GLOBAL'),'rawFile', 'input');
                dimIDs=[];
                for k=1:length(varInfo.Dimensions)
                    dim=varInfo.Dimensions(k);
                    dimID = netcdf.defDim(ncID,dim.Name,dim.Length);
                    dimIDs(end+1)=dimID;
                end

                dataType=varInfo.Datatype;
                if strcmp(dataType,'double') && toSingle || strcmp(dataType,'single')
                    dataType='float';
                elseif strcmp(dataType,'int32')
                    dataType='int';
                elseif strcmp(dataType,'uint32')
                    dataType='uint';
                elseif strcmp(dataType,'int16')
                    dataType='short';
                elseif strcmp(dataType,'uint16')
                    dataType='ushort';
                elseif strcmp(dataType,'int8')
                    dataType='byte';
                elseif strcmp(dataType,'uint8')
                    dataType='ubyte';
                end
                varID = netcdf.defVar(ncID,varInfo.Name,dataType,dimIDs);
                if nc.deflate && length(dimIDs)>=2
                    netcdf.defVarDeflate(ncID,varID,true,true,nc.deflateLevel)
                end
                for k=1:length(varInfo.Attributes)
                    attr=varInfo.Attributes(k);
                    if strcmp(attr.Name,"_FillValue")
                        %不能使用 netcdf.putAtt 设置 NetCDF4 文件的 '_FillValue' 属性。使用 netcdf.defVarFill 函数设置变量的填充值。
                        netcdf.defVarFill(ncID,varID,false,attr.Value);
                    else
                        netcdf.putAtt(ncID,varID,attr.Name,attr.Value);
                    end
                end
                netcdf.putVar(ncID,varID,varData);
                netcdf.close(ncID);
            catch ex
                try
                    netcdf.close(ncID);
                catch
                end
                disp("处理"+varName+".nc文件失败: "+ ex.message)
            end

        end
    else

        for i = 1:numel(varNames)
            varName = varNames{i};
            disp(varName)
            [~,varData]=get_var_data(input,ncInfo,varName,toSingle,z);

            if outputFormat=="mat"
                data.(varName) = squeeze(varData);
            elseif outputFormat=="matFolder"
                data=squeeze(varData);
                save(fullfile(output,varName+".mat"), 'data','-v7.3');
            end
        end

    end
    if outputFormat=="mat"
        disp('正在保存')
        save(output, 'data','-v7.3');
    end
end

function [varInfo,varData]=get_var_data(input,ncInfo,varName,toSingle,z)
    varInfo = ncInfo.Variables(strcmp({ncInfo.Variables.Name}, varName));
    varData = ncread(input, varName);
    if z.removeZ
        % 检查变量是否有维度信息
        if ~isempty(varInfo.Dimensions)
            % 检查是否存在深度维度
            depthDim = find_depth_dimension(varInfo, z.zDimNames);
            if ~isempty(depthDim)
                % 提取表层数据
                varData = extract_surface_data(varData, depthDim, z.surfaceLevelIndex);
            end
        end
    end
    if toSingle
        if isa(varData, 'double')
            varData = single(varData);
        end
    end
end

function zDim = find_depth_dimension(varInfo, zDimNames)
    zDim = [];
    varDims = {varInfo.Dimensions.Name};
    for j = 1:numel(varDims)
        if contains(varDims{j}, zDimNames)
            zDim = j;
            break;
        end
    end
end

function var_data_surface = extract_surface_data(var_data, depth_dim, surface_level)
    indices = repmat({':'}, 1, ndims(var_data));
    indices{depth_dim} = surface_level;
    var_data_surface = var_data(indices{:});
end
