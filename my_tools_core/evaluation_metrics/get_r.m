function [r,p]=get_r(x,y)
    [r,p]=corrcoef(x,y);
    r=r(2);
    p=p(2);
end