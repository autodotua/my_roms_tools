function draw_single_lonlat_tick(drawXTicks,drawYTicks)
    project_data
    if drawYTicks
        yticks(graphData.latitudeValues); yticklabels(graphData.latitudeLabels  );
    else
        yticks([]);
    end
    if drawXTicks
        xticks(graphData.longitudeValues); xticklabels(graphData.longitudeLabels);
    else
        xticks([]);
    end