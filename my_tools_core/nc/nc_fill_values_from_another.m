function nc_fill_values_from_another(fromnc,tonc,vars,func)

    from=ncinfo(fromnc);
    to=ncinfo(tonc);
    fromvars=string({from.Variables.Name});
    tovars=string({to.Variables.Name});
    for var=vars
        if ~ismember(var,fromvars)
            warning("变量"+var+"不在"+fromnc+"中");
            continue
        end
        if ~ismember(var,tovars)
            warning("变量"+var+"不在"+tonc+"中");
            continue
        end
        data=ncread(fromnc,var);
        if exist('func','var')
            data=func(data);
        end
        toSize=to.Variables(find(tovars==var)).Size;
        while toSize(end)==1
            toSize=toSize(1:end-1);
        end
        if ndims(data)==length(toSize)+1
            if ndims(data)==4
                data=data(:,:,:,end);
            elseif ndims(data)==3
                data=data(:,:,end);
            else
                error("unknown dims");
            end
        end
        ncwrite(tonc,var,data);

        disp("已写入变量"+var)
    end
end