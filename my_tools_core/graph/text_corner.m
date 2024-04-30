function text_corner(str, corner, options)
    arguments
        str(1,1) string
        corner(1,1) string {mustBeMember(corner, {'rb', 'lt', 'rt', 'lb'})} = 'lt'
        options.marginX(1,1) double = 0.03
        options.marginY(1,1) double = 0.03
        options.padding(1,1) double = 1
        options.fontColor='black'
        options.backgroundTransparent(1,1) logical = 0
        options.ax=[];
    end

    project_data

    if strcmp(corner, 'rb')
        x = 1 - options.marginX;
        y = options.marginY;
        va='bottom';
        ha='right';
    elseif strcmp(corner, 'lt')
        x = options.marginX;
        y = 1 - options.marginY;
        va='top';
        ha='left';
    elseif strcmp(corner, 'rt')
        x = 1 - options.marginX;
        y = 1 - options.marginY;
        va='top';
        ha='right';
    elseif strcmp(corner, 'lb')
        x = options.marginX;
        y = options.marginY;
        va='bottom';
        ha='left';
    end
    if isempty(options.ax)
        options.ax=gca;
    end
    t = text(options.ax,x, y, str, FontSize=graphData.fontSize, ...
        FontName=graphData.font, Color=options.fontColor, Units='normalized', ...
        VerticalAlignment=va,HorizontalAlignment=ha, ...
        BackgroundColor='w', Margin= options.padding);

    if options.backgroundTransparent
        set(t, 'BackgroundColor', 'none');
    end
end
