function nc_dem_clip_core(input,output,xvar,yvar,zvar,xrange,yrange)
    arguments
        input(1,1) string
        output(1,1) string
        xvar(1,1) string
        yvar(1,1) string
        zvar(1,1) string
        xrange(1,2) double {mustBeInteger}
        yrange(1,2) double {mustBeInteger}
    end
    xs=ncread(input,xvar);
    ys=ncread(input,yvar);
    x1=find(xs>xrange(1),1)-1; x2=find(xs<xrange(2),1,'last')+1; xsize=x2-x1+1;
    y1=find(ys>yrange(1),1)-1; y2=find(ys<yrange(2),1,'last')+1; ysize=y2-y1+1;

    nc = netcdf.create(output,'nc_clobber');

    xdid = netcdf.defDim(nc,xvar,xsize);
    ydid = netcdf.defDim(nc,yvar,ysize);

    xvid = netcdf.defVar(nc,xvar,'double',xdid);
    yvid = netcdf.defVar(nc,yvar,'double',ydid);
    zvid = netcdf.defVar(nc,zvar,'double',[xdid,ydid]);

    netcdf.close(nc)
    x=ncread(input,xvar,x1,xsize);
    y=ncread(input,yvar,y1,ysize);
    z=ncread(input,zvar, [x1,y1],[xsize,ysize]); %提取高程
    ncwrite(output,xvar,x);
    ncwrite(output,yvar,y);
    ncwrite(output,zvar,z);
end

