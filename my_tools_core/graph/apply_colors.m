function apply_colors(colors, n)
if n<0
    colors=flip(colors);
    n=-n;
end
positions = linspace(0, 1, size(colors, 1));
new_positions = linspace(0, 1, n);
new_colors = interp1(positions, colors/255, new_positions);
colormap(new_colors);