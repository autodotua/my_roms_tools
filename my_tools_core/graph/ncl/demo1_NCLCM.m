% demo1
X=linspace(0,1,200)';
CL=(-cos(X*2*pi)+1).^.2;
r=(X-.5)'.^2+(X-.5).^2;
surf(X,X',abs(ifftn(exp(7i*rand(200))./r.^.9)).*(CL*CL')*30,'EdgeColor','none')

% 67 458 190
colormap(nclCM('cmocean_curl',200))
light
material dull
view(59.1823,56.1559)

% 修饰一下
ax=gca;
ax.Projection='perspective';
ax.LineWidth=.8;
ax.XMinorTick='on';
ax.YMinorTick='on';
ax.ZMinorTick='on';
ax.GridLineStyle=':';
ax.FontName='Cambria';
