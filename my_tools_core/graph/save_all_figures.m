function save_all_figures(names,dpi,needClose,formats)
    arguments
        names(:,1) string
        dpi(1,1) double
        needClose(1,1) logical =true
        formats(1,1) string="fp" %f：fig；p：png；D：PDF；e：ESP
    end
    global strLang
    h = findobj('Type','figure');
    [~,order]=sort([h.Number]);
    h=h(order);
    if ~length(names)==length(h)
        error("传入names的数量与打开的figure数量不一致");
    end
    for i = 1:length(h)
        if names(i)==""
            continue
        end
        name=names(i);
        if ~(isempty(strLang) || strcmp(strLang,""))
            name=strLang+"-"+name;
        end
        %fig
        if contains(formats,'f')
            disp("正在保存fig")
            savefig(h(i),name+".fig");
        end
        %png
        if contains(formats,'p')
            disp("正在保存png")
            exportgraphics(h(i),name+".png",'Resolution',dpi);
        end
        %pdf
        if contains(formats,'d')
            disp("正在保存pdf")
            exportgraphics(h(i), name+".pdf", 'ContentType', 'vector');
        end
        %EPS
        if contains(formats,'e')
            disp("正在保存eps")
            exportgraphics(h(i), name+".eps", 'ContentType', 'vector');
        end
    end
    if needClose
        close all
    end
end