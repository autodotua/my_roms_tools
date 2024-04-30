function set_gcf_size(width,height,x,y)
    arguments
        width(1,1) double
        height(1,1) double = width
        x(1,1) double=60;
        y(1,1) double=60;
    end
    set(gcf, 'position', [x y x+width y+height]);
end