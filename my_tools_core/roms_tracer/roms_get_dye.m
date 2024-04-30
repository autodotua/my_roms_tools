function [dye,dyeName]=roms_get_dye(nc,index,to2d)
    arguments
        nc(1,1) string %nc文件路径
        index(1,1) double {mustBeInteger,mustBePositive}=1 %示踪剂序号
        to2d(1,1) logical=false %是否转为2D
    end

    requireName1=string(['dye_',num2str(index,'%02d')]);
    requireName2=string(['dye_',num2str(index,'%02d'),'_sur']);

    if endsWith(nc,'.mat')
        if index>1
            error("输入文件为mat时，只有一个dye");
        end
        dye=load(nc,'dye');
        if ~isfield(dye,'dye')
            error("mat文件中需要有dye变量")
        end
        dye=dye.dye;
    else
        names=strtrim(string(char(ncinfo(nc).Variables.Name)));

        if ismember(requireName1,names)
            dye=ncread(nc,requireName1);
            dyeName=requireName1;
        elseif ismember(requireName2,names)
            dye=ncread(nc,requireName2);
            dyeName=requireName2;
        else
            error("找不到变量"+requireName1+"或"+requireName2)
        end
    end
    if to2d&&ndims(dye)==4
        dye=squeeze(mean(dye,3));
    end
