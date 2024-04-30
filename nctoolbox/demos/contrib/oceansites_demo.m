% OCEANSITES_DEMO Plot all time series variables that have a certain
% 'standard_name' in a specified bounding box and time period

% WHOI GI-CAT catalog server, which harvests data from multiple
% THREDDS Servers:
open_url='http://geoport.whoi.edu/gi-cat/services/opensearch';

% can search for any text, not just variable 'standard_names':
%var='relative_humidity'; %free text search string
var='sea_water_temperature';
%var='sea_water_salinity';  

% time_var='time'; %time coordinate variable
bbox =[-180 180 -70 80];  % [lon_min lon_max lat_min lat_max]

% specify a certain search range.  Like this...
start=[1990 1 1 0 0 0]; % specified start
stop =[2000 1 1 0 0 0]; % specified stop

% or like this....
start=now_utc-28;  % last 28 days
stop=now_utc;          % now

%%%%%%%%%%%%%%%%%%%% end of user defined input %%%%%%%%%%%%%%%%
% opensearch query
q.endpoint=open_url;
q.bbox=bbox; 
q.time_start=datestr(start);% convert to ISO
q.time_end=datestr(stop);% convert to ISO
q.string_text=var

disp(['Querying ' q.endpoint ' via OpenSearch']);
[links,params]=opensearch(q);  
dap=links2dap(links); % find only the OPeNDAP links
char(dap)
disp('Accessing data via OPeNDAP');
for i=1:length(dap);
    figure(i);
    nc=ncgeodataset(dap{i});
    vars=nc.variables;
    for j=1:length(vars); %loop through variables to find standard_names
        vart=nc.geovariable(vars{j});
        std_name=vart.attribute('standard_name');
        if strcmp(std_name,var),
            jd= vart.timewindowij(start, stop);
            t=vart.data(jd.index);  %extact these indices from dataset
            plot(jd.time,t);datetick;grid;...
            ylabel(sprintf('%s [%s]',var,vart.attribute('units')),...
                'interpreter','none');...
            title(nc.attribute('title'));...
            drawnow
        end
    end
end