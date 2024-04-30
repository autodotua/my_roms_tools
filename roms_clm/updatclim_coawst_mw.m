function [fn]=updatclim_coawst_mw(T1, gn, clm, clmname, wdr, url)
% Modified by Brandy Armstrong January 2012 to use only NCTOOLBOX 
% and Matlab builtin functions to read and write netcdf files
% jcw Feb 2019 - only use matalb BI
%
%T1 = date for climatology file
%gn = data from grid
%clm = data of hycom indices
%wdr = the working directory
%clmname = grid name prefix for climatology filenames
%url = where get data from

%
%determine indices for time period of interpolation
%
configs
disp('正在获取记录的时间数量');
 % tr0=datenum(1858,11,17);
time=ncread(url,roms.res.hycom_time);
tg=time/roms.res.hycom_tunit+roms.res.hycom_t0;
tg2=julian(str2num(datestr(tg,'yyyy')),str2num(datestr(tg,'mm')),str2num(datestr(tg,'dd')),str2num(datestr(tg,'HH')))-2400001;
%
% get user times
%
[junk,tid1,ib]=intersect(tg,floor(T1)); %modify to be nearest jcw 23Aug2014
if isempty(tid1)
  tid1=length(tg);
end

fn=[clmname];
disp(['正在创建nc文件 ',fn]);
create_roms_netcdf_clm_mwUL(fn,gn,1);% converted to BI functions

%fill grid dims using builtin (BI) functions
RN=netcdf.open(fn,'NC_WRITE');
lonid=netcdf.inqVarID(RN,'lon_rho');
netcdf.putVar(RN,lonid,gn.lon_rho);
latid=netcdf.inqVarID(RN,'lat_rho');
netcdf.putVar(RN,latid,gn.lat_rho);
netcdf.close(RN)

%%
tz_levs=length(clm.z);
X=repmat(clm.lon,1,length(clm.lat));
Y=repmat(clm.lat,length(clm.lon),1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['插值U数据：',datestr(tg(tid1))]);
ttu=1;
clm.u=zeros([length(clm.z) size(gn.lon_rho)]);
while ttu==1
    try
        tmpt=ncread(url,roms.res.hycom_u,[clm.ig0 clm.jg0 1 tid1],[clm.ig1-clm.ig0+1 clm.jg1-clm.jg0+1 tz_levs 1 ] );
        for k=1:tz_levs
            disp(['正在插值HYCOM的U数据，层：' num2str(k)]);
            tmp=double(squeeze(tmpt(:,:,k)));
            if (k==1)
              F = scatteredInterpolant(X(:),Y(:),tmp(:));
            else
              F.Values = tmp(:);
            end
            cff = F(gn.lon_rho,gn.lat_rho);
            clm.u(k,:,:)=maplev(cff);
        end
        ttu=0;
    catch
        disp(['无法下载HYCOM的U数据：' datestr(now)]);
        fid=fopen('coawstlog.txt','a');
        fprintf(fid,'Unable to download HYCOM u data at');
        fprintf(fid,datestr(now));
        fprintf(fid,'\n');
    end
end
%== Vertical interpolation (t,s,u,v) from standard z-level to s-level
u=roms_from_stdlev_mw(gn.lon_rho,gn.lat_rho,clm.z,clm.u,gn,'u',0);
clm=rmfield(clm,'u');
save u.mat u
clear u;

disp(['插值V数据：',datestr(tg(tid1))]);
ttv=1;
clm.v=zeros([length(clm.z) size(gn.lon_rho)]);
while ttv==1
    try
        tmpt=ncread(url,roms.res.hycom_v,[clm.ig0 clm.jg0 1 tid1],[clm.ig1-clm.ig0+1 clm.jg1-clm.jg0+1 tz_levs 1 ] );
        for k=1:tz_levs
            disp(['正在插值HYCOM的V数据，层：' num2str(k)]);
            tmp=double(squeeze(tmpt(:,:,k)));
            if (k==1)
              F = scatteredInterpolant(X(:),Y(:),tmp(:));
            else
              F.Values = tmp(:);
            end
            cff = F(gn.lon_rho,gn.lat_rho);
            clm.v(k,:,:)=maplev(cff);
        end
        ttv=0;
    catch
        disp(['无法下载HYCOM的V数据：' datestr(now)]);
        fid=fopen('coawstlog.txt','a');
        fprintf(fid,'Unable to download HYCOM v data at');
        fprintf(fid,datestr(now));
        fprintf(fid,'\n');
    end
end
%== Vertical interpolation (t,s,u,v) from standard z-level to s-level
v=roms_from_stdlev_mw(gn.lon_rho,gn.lat_rho,clm.z,clm.v,gn,'v',0);
clm=rmfield(clm,'v');
save v.mat v
clear v;

%== Rotate the velocity
theta=exp(-sqrt(-1)*mean(mean(gn.angle)));
load u.mat; load v.mat
disp('正在旋转U和V网格');
uv=(u2rho_3d_mw(u)+sqrt(-1)*v2rho_3d_mw(v)).*theta;
u=rho2u_3d_mw(real(uv)); v=rho2v_3d_mw(imag(uv));
clear uv

%% == output
RN=netcdf.open(fn,'NC_WRITE');

tempid=netcdf.inqVarID(RN,'u');
netcdf.putVar(RN,tempid,shiftdim(u,1));

tempid=netcdf.inqVarID(RN,'v');
netcdf.putVar(RN,tempid,shiftdim(v,1));

clear u; clear v;
tempid=netcdf.inqVarID(RN,'ocean_time');
netcdf.putVar(RN,tempid,tg2(tid1));
tempid=netcdf.inqVarID(RN,'zeta_time');
netcdf.putVar(RN,tempid,tg2(tid1));
tempid=netcdf.inqVarID(RN,'v2d_time');
netcdf.putVar(RN,tempid,tg2(tid1));
tempid=netcdf.inqVarID(RN,'v3d_time');
netcdf.putVar(RN,tempid,tg2(tid1));
tempid=netcdf.inqVarID(RN,'salt_time');
netcdf.putVar(RN,tempid,tg2(tid1));
tempid=netcdf.inqVarID(RN,'temp_time');
netcdf.putVar(RN,tempid,tg2(tid1));
netcdf.close(RN);
%%
%== Depth averaging u, v to get Ubar
load u.mat; load v.mat
cc=roms_zint_mw(u,gn);  ubar=rho2u_2d_mw(u2rho_2d_mw(cc)./gn.h);
cc=roms_zint_mw(v,gn);  vbar=rho2v_2d_mw(v2rho_2d_mw(cc)./gn.h);
%== Rotate the velocity
uv=(u2rho_2d_mw(ubar)+sqrt(-1)*v2rho_2d_mw(vbar)).*theta;
ubar=rho2u_2d_mw(real(uv)); vbar=rho2v_2d_mw(imag(uv));
clear u
clear v

RN=netcdf.open(fn,'NC_WRITE');
tempid=netcdf.inqVarID(RN,'ubar');
netcdf.putVar(RN,tempid,ubar);
tempid=netcdf.inqVarID(RN,'vbar');
netcdf.putVar(RN,tempid,vbar);
netcdf.close(RN);

clear ubar
clear vbar
clear uv
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% interpolate the zeta data
disp(['正在插值自由表面数据',datestr(tg(tid1))]);
ttz=1;
while ttz==1
    try
        tmpt=ncread(url,roms.res.hycom_surface_elevation,[clm.ig0 clm.jg0 tid1],[clm.ig1-clm.ig0+1 clm.jg1-clm.jg0+1 1 ] );
        tmp=double(squeeze(tmpt(:,:)));
        disp(['正在插值HYCOM的自由表面数据，层：']);
        F = scatteredInterpolant(X(:),Y(:),tmp(:));
        cff = F(gn.lon_rho,gn.lat_rho);
        zeta=maplev(cff);
        ttz=0;
    catch
        disp(['无法下载HYCOM的自由表面数据：' datestr(now)]);
        fid=fopen('coawstlog.txt','a');
        fprintf(fid,'Unable to download HYCOM ssh data at');
        fprintf(fid,datestr(now));
        fprintf(fid,'\n');
    end
end
clear tmp
%
%== output zeta
%
RN=netcdf.open(fn,'NC_WRITE');
tempid=netcdf.inqVarID(RN,'zeta');
netcdf.putVar(RN,tempid,zeta);
netcdf.close(RN);
clear zeta;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['正在插值温度数据',datestr(tg(tid1))]);
ttt=1;
clm.temp=zeros([length(clm.z) size(gn.lon_rho)]);
while ttt==1
    try
        tmpt=ncread(url,roms.res.hycom_temp,[clm.ig0 clm.jg0 1 tid1],[clm.ig1-clm.ig0+1 clm.jg1-clm.jg0+1 tz_levs 1 ] );
        for k=1:tz_levs
            disp(['正在插值HYCOM的温度数据，层：' num2str(k)]);
            tmp=double(squeeze(tmpt(:,:,k)));
            if (k==1)
              F = scatteredInterpolant(X(:),Y(:),tmp(:));
            else
              F.Values = tmp(:);
            end
            cff = F(gn.lon_rho,gn.lat_rho);
%           cff(cff<0)=nan;
            clm.temp(k,:,:)=maplev(cff);
        end
        ttt=0;
    catch
        disp(['无法下载HYCOM的温度数据：' datestr(now)]);
        fid=fopen('coawstlog.txt','a');
        fprintf(fid,'Unable to download HYCOM temp data at');
        fprintf(fid,datestr(now));
        fprintf(fid,'\n');
    end
end
%
%== Vertical interpolation (t,s,u,v) from standard z-level to s-level
%
temp=roms_from_stdlev_mw(gn.lon_rho,gn.lat_rho,clm.z,clm.temp,gn,'rho',0);
clm=rmfield(clm,'temp');
%
%== output temp
%
RN=netcdf.open(fn,'NC_WRITE');
tempid=netcdf.inqVarID(RN,'temp');
netcdf.putVar(RN,tempid,shiftdim(temp,1));
netcdf.close(RN);
clear temp;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['正在插值盐度数据',datestr(tg(tid1))]);
tts=1;
clm.salt=zeros([length(clm.z) size(gn.lon_rho)]);
while tts==1;
    try
        tmpt=ncread(url,roms.res.hycom_salt,[clm.ig0 clm.jg0 1 tid1],[clm.ig1-clm.ig0+1 clm.jg1-clm.jg0+1 tz_levs 1 ] );
        for k=1:tz_levs
            disp(['正在插值HYCOM的盐度数据，层：' num2str(k)]);
            tmp=double(squeeze(tmpt(:,:,k)));
            if (k==1)
              F = scatteredInterpolant(X(:),Y(:),tmp(:));
            else
              F.Values = tmp(:);
            end
            cff = F(gn.lon_rho,gn.lat_rho);
            cff(cff<0)=nan;
            clm.salt(k,:,:)=maplev(cff);
        end
        tts=0;
    catch
        disp(['无法下载HYCOM的盐度数据：' datestr(now)]);
        fid=fopen('coawstlog.txt','a');
        fprintf(fid,'Unable to download HYCOM temp data at');
        fprintf(fid,datestr(now));
        fprintf(fid,'\n');
    end
end
%
%== Vertical interpolation (t,s,u,v) from standard z-level to s-level
%
salt=roms_from_stdlev_mw(gn.lon_rho,gn.lat_rho,clm.z,clm.salt,gn,'rho',0);
clm=rmfield(clm,'salt');
%
%== output salt
%
RN=netcdf.open(fn,'NC_WRITE');
tempid=netcdf.inqVarID(RN,'salt');
netcdf.putVar(RN,tempid,shiftdim(salt,1));
netcdf.close(RN);
clear salt;

disp(['完成创建气候学文件： ' datestr(now)]);
%%
