% demo3
% 需要mapping toolbox
[N,R] = egm96geoid;
axesm eckert4
Z=zeros(R.RasterSize);
geoshow(N,R,'DisplayType','surface','CData',N,'ZData',Z)
framem;gridm

% 215 190 150
% colormap(nclCM(215,20))
colormap(nclCM(150,20))
cb=colorbar('southoutside');
cb.Label.String = 'EGM96 Geoid Height in Meters';
geoshow('landareas.shp','FaceColor',[.5,.5,.5])