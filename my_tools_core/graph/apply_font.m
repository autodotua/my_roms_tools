function apply_font(objs)
    arguments (Repeating)
        objs
    end
    project_data
    font=graphData.font;
    fontSize=graphData.fontSize;
    if ~exist('objs','var') || isempty(objs)
        ax = gca;
        ax.FontName=font;
        ax.FontSize = fontSize;

        try
            ax.XAxis.FontSize = fontSize;
            ax.YAxis.FontSize = fontSize;

            ax.XLabel.FontSize = fontSize;
            ax.YLabel.FontSize = fontSize;


            ax.XAxis.FontName = font;
            ax.YAxis.FontName = font;

            ax.XLabel.FontName = font;
            ax.YLabel.FontName = font;
        catch
        end
    else
        for objCell=objs
            if iscell(objCell)
                obj=objCell{1};
            else
                obj=objCell;
            end
            if isequal(class(obj),'matlab.graphics.axis.Axes')
                set(class(obj),'FontName', font);
            elseif isequal(class(obj)  ,  'matlab.graphics.layout.TiledChartLayout')
                obj.XLabel.FontName= font;
                obj.YLabel.FontName= font;
                obj.XLabel.FontSize= graphData.lagerFontSize;
                obj.YLabel.FontSize= graphData.lagerFontSize;
                obj.Title.FontName= font;
                obj.Title.FontSize= graphData.lagerFontSize;
            elseif isequal(class(obj),'matlab.graphics.primitive.Text')
                obj.FontName=font;
            elseif isequal(class(obj), 'matlab.graphics.illustration.ColorBar')
                obj.Label.FontName=font;
            end
        end
    end