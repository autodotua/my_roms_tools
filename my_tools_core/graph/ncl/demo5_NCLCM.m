% demo5
t=linspace(0,5*pi,200);

% 116 190 402 162 
C=nclCM(15,50);
ax=gca;hold on 
for i=1:50
    plot(t,sin(t)+i.*.1,'Color',C(i,:),'LineWidth',2);
end

% 坐标区域修饰
ax.YLim=[0,5];
ax.XLim=[0,5*pi];
ax.YTick=0:.5:5;
ax.XTick=0:1:15;
% ax.XGrid='on';
ax.YGrid='on';
ax.GridLineStyle='-.';
ax.LineWidth=1.2;
ax.XMinorTick='on';
ax.YMinorTick='on';
ax.Box='on';
ax.FontName='Cambria';
ax.FontWeight='bold';
ax.FontSize=12;

