function colors=color_ncl(type,num,percent,applyToFigure)
    arguments
        type %颜色代码，可以是数值类型的序号或字符串类型的名称。
        % 如果序号为负，或名称以"-"开头，表示反转颜色。
        num (1,1) double=-1 %对颜色进行分割提取
        percent(1,:) double=[0,1] %表示取全部颜色的一部分
        applyToFigure(1,1) logical=0; %是否应用到整个Figure而非当前Axis
    end
    if isempty(percent)
        percent=[0,1];
    end
    nclCM_Data=load('nclCM_Data.mat');
    CList_Data=nclCM_Data.Colors;

    reverse=false;
    if isnumeric(type)
        if type<0
            reverse=true;
            type=-type;
        end
        Cmap=CList_Data{type};
    else
        if startsWith(type,'-')
            reverse=true;
            type=extractAfter(type,1);
        end
        Cpos=strcmpi(type,nclCM_Data.Names);
        Cmap=CList_Data{find(Cpos,1)};
    end
    if reverse
        Cmap=flipud(Cmap);
    end
    if num>0 || ~isequal(percent,[0,1])
        beginPercent=round(1+(size(Cmap,1)-1)*percent(1));
        endPercent=round(1+(size(Cmap,1)-1)*percent(2));
        Cmap=Cmap(beginPercent:endPercent,:);
        Ci=1:size(Cmap,1);
        if num==-1
            num=size(Cmap,1);
        end
        Cq=linspace(1,size(Cmap,1),num);
        colorList=[interp1(Ci,Cmap(:,1),Cq,'linear')',...
            interp1(Ci,Cmap(:,2),Cq,'linear')',...
            interp1(Ci,Cmap(:,3),Cq,'linear')'];
    else
        colorList=Cmap;
    end
    if nargout==0
        if applyToFigure
            colormap(gcf,colorList);
        else
            colormap(gca,colorList);
        end
    else
        colors=colorList;
    end