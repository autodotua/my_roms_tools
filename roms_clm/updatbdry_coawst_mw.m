function updatbdry_coawst_mw(fn,gn,bdy,wdr)

% written by Mingkui Li, May 2008
% further adaptions by jcw, April 18, 2009
% adaptions by Qingr, September 08, 2021
% fn is the clm file
% gn is the working grid
% bdy is the bdy file name
% wdr is the working directory

%Use clm file to get the data
nc_clm=netcdf.open(fn,'NC_NOWRITE');
%get number of time steps in clm file
timeid = netcdf.inqVarID(nc_clm,'ocean_time');
ocean_time=netcdf.getVar(nc_clm,timeid);

%file name to be created
bndry_file=[bdy];

%call to create this bndry file.
create_roms_netcdf_bndry_mwUL(bndry_file,gn,length(ocean_time))
nc_bndry=netcdf.open(bndry_file,'NC_WRITE');

%now write the data from the arrays to the netcdf file
disp(' ## Filling Variables in netcdf file with data...')

%% Time
zettimeid = netcdf.inqVarID(nc_bndry,'zeta_time');
netcdf.putVar(nc_bndry,zettimeid,ocean_time);

v2dtimeid = netcdf.inqVarID(nc_bndry,'v2d_time');
netcdf.putVar(nc_bndry,v2dtimeid,ocean_time);

v3dtimeid = netcdf.inqVarID(nc_bndry,'v3d_time');
netcdf.putVar(nc_bndry,v3dtimeid,ocean_time);

saltimeid = netcdf.inqVarID(nc_bndry,'salt_time');
netcdf.putVar(nc_bndry,saltimeid,ocean_time);

tmptimeid = netcdf.inqVarID(nc_bndry,'temp_time');
netcdf.putVar(nc_bndry,tmptimeid,ocean_time);

%% zeta
zetclmid = netcdf.inqVarID(nc_clm,'zeta');%get id
zeta=netcdf.getVar(nc_clm,zetclmid);%get variable
zeta_south=zeta(:,1);
zetbdyids = netcdf.inqVarID(nc_bndry,'zeta_south');%get id
netcdf.putVar(nc_bndry,zetbdyids,zeta_south);%set variable
clear zeta_south

zeta_east=zeta(end,:);
zetbdyide = netcdf.inqVarID(nc_bndry,'zeta_east');%get id
netcdf.putVar(nc_bndry,zetbdyide,zeta_east);%set variable
clear zeta_east

zeta_north=zeta(:,end);
zetbdyids = netcdf.inqVarID(nc_bndry,'zeta_north');%get id
netcdf.putVar(nc_bndry,zetbdyids,zeta_north);%set variable
clear zeta_north

zeta_west=zeta(1,:);
zetbdyide = netcdf.inqVarID(nc_bndry,'zeta_west');%get id
netcdf.putVar(nc_bndry,zetbdyide,zeta_west);%set variable
clear zeta_west

%% ubar
ubarclmid = netcdf.inqVarID(nc_clm,'ubar');
ubarclm=netcdf.getVar(nc_clm,ubarclmid);

ubar_south=ubarclm(:,1);
ubarbdyids = netcdf.inqVarID(nc_bndry,'ubar_south');
netcdf.putVar(nc_bndry,ubarbdyids,ubar_south);
clear ubar_south

ubar_east=ubarclm(end,:);
ubarbdyide = netcdf.inqVarID(nc_bndry,'ubar_east');
netcdf.putVar(nc_bndry,ubarbdyide,ubar_east);
clear ubar_east

ubar_north=ubarclm(:,end);
ubarbdyids = netcdf.inqVarID(nc_bndry,'ubar_north');
netcdf.putVar(nc_bndry,ubarbdyids,ubar_north);
clear ubar_north

ubar_west=ubarclm(1,:);
ubarbdyide = netcdf.inqVarID(nc_bndry,'ubar_west');
netcdf.putVar(nc_bndry,ubarbdyide,ubar_west);
clear ubar_west

%% vbar
vbarclmid = netcdf.inqVarID(nc_clm,'vbar');
vbarclm=netcdf.getVar(nc_clm,vbarclmid);

vbar_south=vbarclm(:,1);
vbarbdyids = netcdf.inqVarID(nc_bndry,'vbar_south');
netcdf.putVar(nc_bndry,vbarbdyids,vbar_south);
clear vbar_south

vbar_east=vbarclm(end,:);
vbarbdyide = netcdf.inqVarID(nc_bndry,'vbar_east');
netcdf.putVar(nc_bndry,vbarbdyide,vbar_east);
clear vbar_east

vbar_north=vbarclm(:,end);
vbarbdyids = netcdf.inqVarID(nc_bndry,'vbar_north');
netcdf.putVar(nc_bndry,vbarbdyids,vbar_north);
clear vbar_north

vbar_west=vbarclm(1,:);
vbarbdyide = netcdf.inqVarID(nc_bndry,'vbar_west');
netcdf.putVar(nc_bndry,vbarbdyide,vbar_west);
clear vbar_west

%% u
uclmid = netcdf.inqVarID(nc_clm,'u');
uclm=netcdf.getVar(nc_clm,uclmid);

u_south=uclm(:,1,:);
ubdyids = netcdf.inqVarID(nc_bndry,'u_south');
netcdf.putVar(nc_bndry,ubdyids,u_south);
clear u_south

u_east=uclm(end,:,:);
ubdyide = netcdf.inqVarID(nc_bndry,'u_east');
netcdf.putVar(nc_bndry,ubdyide,u_east);
clear u_east

u_north=uclm(:,end,:);
ubdyids = netcdf.inqVarID(nc_bndry,'u_north');
netcdf.putVar(nc_bndry,ubdyids,u_north);
clear u_north

u_west=uclm(1,:,:);
ubdyide = netcdf.inqVarID(nc_bndry,'u_west');
netcdf.putVar(nc_bndry,ubdyide,u_west);
clear u_west

%% v
vclmid = netcdf.inqVarID(nc_clm,'v');
vclm=netcdf.getVar(nc_clm,vclmid);

v_south=vclm(:,1,:);
vbdyids = netcdf.inqVarID(nc_bndry,'v_south');
netcdf.putVar(nc_bndry,vbdyids,v_south);
clear v_south

v_east=vclm(end,:,:);
vbdyide = netcdf.inqVarID(nc_bndry,'v_east');
netcdf.putVar(nc_bndry,vbdyide,v_east);
clear v_east

v_north=vclm(:,end,:);
vbdyids = netcdf.inqVarID(nc_bndry,'v_north');
netcdf.putVar(nc_bndry,vbdyids,v_north);
clear v_north

v_west=vclm(1,:,:);
vbdyide = netcdf.inqVarID(nc_bndry,'v_west');
netcdf.putVar(nc_bndry,vbdyide,v_west);
clear v_west

%% temp
tempclmid = netcdf.inqVarID(nc_clm,'temp');
tempclm=netcdf.getVar(nc_clm,tempclmid);

temp_south=tempclm(:,1,:);
tempbdyids = netcdf.inqVarID(nc_bndry,'temp_south');
netcdf.putVar(nc_bndry,tempbdyids,temp_south);
clear temp_south

temp_east=tempclm(end,:,:);
tempbdyide = netcdf.inqVarID(nc_bndry,'temp_east');
netcdf.putVar(nc_bndry,tempbdyide,temp_east);
clear temp_east

temp_north=tempclm(:,end,:);
tempbdyids = netcdf.inqVarID(nc_bndry,'temp_north');
netcdf.putVar(nc_bndry,tempbdyids,temp_north);
clear temp_north

temp_west=tempclm(1,:,:);
tempbdyide = netcdf.inqVarID(nc_bndry,'temp_west');
netcdf.putVar(nc_bndry,tempbdyide,temp_west);
clear temp_west

%% salt
saltclmid = netcdf.inqVarID(nc_clm,'salt');
saltclm=netcdf.getVar(nc_clm,saltclmid);

salt_south=saltclm(:,1,:);
saltbdyids = netcdf.inqVarID(nc_bndry,'salt_south');
netcdf.putVar(nc_bndry,saltbdyids,salt_south);
clear salt_south

salt_east=saltclm(end,:,:);
saltbdyide = netcdf.inqVarID(nc_bndry,'salt_east');
netcdf.putVar(nc_bndry,saltbdyide,salt_east);
clear salt_east

salt_north=saltclm(:,end,:);
saltbdyids = netcdf.inqVarID(nc_bndry,'salt_north');
netcdf.putVar(nc_bndry,saltbdyids,salt_north);
clear salt_north

salt_west=saltclm(1,:,:);
saltbdyide = netcdf.inqVarID(nc_bndry,'salt_west');
netcdf.putVar(nc_bndry,saltbdyide,salt_west);
clear salt_west
%%
netcdf.close(nc_bndry);
netcdf.close(nc_clm);
