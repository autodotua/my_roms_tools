function draw_background(lon,lat)
    project_data
    pcolorjw(lon,lat,ones(size(lon)));
    hold on;
    set(findobj(gca, 'type', 'surface'), 'FaceColor',graphData.landColor)