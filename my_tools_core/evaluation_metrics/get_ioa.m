function ioa=get_ioa(x,y)
    ioa = 1 - (sum((x - y).^2) / sum((abs(y - mean(x)) + abs(x - mean(x))).^2));
end