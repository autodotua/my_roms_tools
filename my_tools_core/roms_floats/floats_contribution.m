function floats_contribution(nc,floatTypes,geoRange,timeRange)
    configs
    [lon_rho,lat_rho,mask_rho]=roms_load_grid_rho;
    % geoRangeGrid=inpolygon(lon_rho,lat_rho,geoRange(:,1),geoRange(:,2));
    % geoRangeGrid=geoRangeGrid&mask_rho;
    lons=ncread(nc,'lon');
    lats=ncread(nc,'lat');
    i=1;
    [datetimes,datenums]=roms_get_times(ncread(nc,'ocean_time'),0);
    % timeFilter=datetimes>timeRange(1) & datetimes<timeRange(2);
    % lons=lons(:,timeFilter);
    % lats=lats(:,timeFilter);
    counts=[];
    while ismember(i,floatTypes)
        counts(end+1)=0;
        indexes=floatTypes==i;
        inrange=inpolygon(lons(indexes,:),lats(indexes,:),geoRange(:,1),geoRange(:,2));
        for p=inrange'
            if ismember(1,p)
                counts(end)=counts(end)+1;
            end
        end
            i=i+1;
    end

    counts



