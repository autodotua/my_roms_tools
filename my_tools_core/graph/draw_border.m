function draw_border

    % 获取当前图形的坐标范围
    ax = gca;
    xlims = ax.XLim;
    ylims = ax.YLim;

    % 在四周绘制方框
    hold on;
    border_width = 1; % 像素
    border_color = 'k';
    patch([xlims(1), xlims(2), xlims(2), xlims(1)], ...
        [ylims(1), ylims(1), ylims(2), ylims(2)], ...
        border_color, 'EdgeColor', border_color, ...
        'LineWidth', border_width, 'FaceColor', 'none', ...
        'LineStyle', '-', 'Clipping', 'off');
