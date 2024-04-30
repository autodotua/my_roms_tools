function roms_create_tides_tpxo9(start_time,grid_file,tpxo9_dir,tpxo9_days,output_file)
    arguments
        start_time(1,6) double {mustBeInteger}
        grid_file(1,1) string
        tpxo9_dir(1,1) string
        tpxo9_days(1,1) double {mustBePositive,mustBeInteger}
        output_file(1,1) string
    end

    tpxo9_dir=char(tpxo9_dir);
    grid_file=char(grid_file);
    output_file=char(output_file);

    % A wrapper for function TPXO9v5_ROMS.m.

    %t0 can be any time of day not necessarily 00:00
    %lengthSim is the approximate anticipated length of model run (days) (f & u are computed at mid-point).
    %fnGrid is your ROMS grid file.
    %TPXO2ROMS will write to fnOut.

    %Available choices for ROMSnames:
    %'MM' 'MF' 'Q1' 'O1' 'P1' 'K1' 'S1' 'N2' 'M2' 'S2' 'K2' 'MN4' 'M4' 'MS4' '2N2'
    %For example, use ROMSnames={'M2' 'S2' 'MM'}; to use M2, S2, and MM only

    %TIDE_START is for the ROMS *.in file if using TIME_REF=-2.
    %Customise the section between the rows of asterisks for your own application.
    %Tested against espresso files in John Hunter's OTPS routines - only slight differences (due
    %to interpolation schemes and possibly different versions of the OSU data.


    % %****************Customise section*********************

    t0=datenum(start_time);
    TIDE_START=t0-datenum(start_time);
    lengthSim=tpxo9_days;  %estimated length of model run (not exact)
    fnGrid=grid_file;
    fnOut=output_file;
    TPXOpath=tpxo9_dir;
    ROMSnames={'MM' 'MF' 'Q1' 'O1' 'P1' 'K1' 'S1' 'N2' 'M2' 'S2' 'K2' '2N2' 'MN4' 'M4' 'MS4'};   %Harmonics to be deployed in ROMS, in any order.
    %ROMSnames={ 'M2'};  %Harmonics to be deployed in ROMS, in any order.
    NP=[9 8]; %Indices of harmonics to be plotted (between 1 and NH can be plotted, where NH=length of ROMSnames)
    %******************

    %fnPNG_Z=['C:\Users\autod\Desktop\01潮汐文件\output\TPXO9v5_ROMS_M2_Zamp_Zpha_' datestr(t0,'HHMM ddmmmyyyy') '.png'];
    %fnPNG_C1=['C:\Users\autod\Desktop\01潮汐文件\output\TPXO9v5_ROMS_M2_Cpha_Cang_' datestr(t0,'HHMM ddmmmyyyy') '.png'];
    %fnPNG_C2=['C:\Users\autod\Desktop\01潮汐文件\output\TPXO9v5_ROMS_M2_Cmin_Cmax_' datestr(t0,'HHMM ddmmmyyyy') '.png'];
    %dtstr=[datestr(t0,'HHMM dd mmm yyyy') ' UT']; %date string on plot
    dtlat=27; %date string latitude
    dtlon=113; %date string longitude (centre position)
    skip=10; %plot each skipth'th ellipse
    sfac=0.4; %adjust sf (scalefactor) to make ellipse sizes sensible (the ellipse sizes are arbitrary)
    sfmaj=0.5; %Semi-major axis of scale factor ellipse
    sflon=113; %lon and lat for center of legend ellipse on map
    sflat=38.3;
    sflat_text=sflat-0.4; %latitude of ellipse text
    sftextsize=10;
    Ecolor='w'; %ellipse color
    % %********************************************

    if ~ismember(TPXOpath(end),'\/')
        TPXOpath=[TPXOpath,'/'];
    end
    % Execute main function
    TPXO9v5_ROMS(t0,ROMSnames,fnGrid,fnOut,lengthSim,TPXOpath)

    %Read the grid
    lonR=ncread(fnGrid,'lon_rho');
    latR=ncread(fnGrid,'lat_rho');
    maskR=ncread(fnGrid,'mask_rho');
    [L,M]=size(latR);

    %Plot zeta amplitude and phase
%     disp('Plotting')
%     for N=1:length(NP)
%         %Read the file created by TPXO9v5_ROMS
%         zamp=ncread(fnOut,'tide_Eamp');
%         zpha=ncread(fnOut,'tide_Ephase');
%         Cang=ncread(fnOut,'tide_Cangle');
%         Cpha=ncread(fnOut,'tide_Cphase');
%         Cmin=ncread(fnOut,'tide_Cmin');  %negative v positive
%         Cmax=ncread(fnOut,'tide_Cmax');
%         z2a=squeeze(zamp(:,:,NP(N)));
%         z2p=squeeze(zpha(:,:,NP(N)));
%         Cang=squeeze(Cang(:,:,NP(N)));
%         Cpha=squeeze(Cpha(:,:,NP(N)));
%         Cmin=squeeze(Cmin(:,:,NP(N)));
%         Cmax=squeeze(Cmax(:,:,NP(N)));
%         maskRE=maskR(1:skip:L,1:skip:M);
%         lonRE=lonR(1:skip:L,1:skip:M); %Ellipse placement
%         latRE=latR(1:skip:L,1:skip:M);
%         CminE=Cmin(1:skip:L,1:skip:M); %Ellipse placement
%         CmaxE=Cmax(1:skip:L,1:skip:M);
%         CangE=Cang(1:skip:L,1:skip:M);
% 
%         figure
%         figure_fit_A4
%         %    colormap(squeeze_jet)
%         %Elevation amp  and phase
%         subplot(2,1,1)
%         z2a(maskR==0)=nan;
%         contourf(lonR,latR,z2a)
%         %    cj_map
%         caxis([min(min(z2a)) max(max(z2a))])
%         colorbar
%         ttxt=['TPXO9v5_ROMS ' char(ROMSnames(NP(N))) ' Elevation amplitude (m)'];
%         title(ttxt,'Interpreter','none')
%         text(dtlon,dtlat,'No time dependence','HorizontalAlignment','center','fontweight','b','fontsize',sftextsize)
%         subplot(2,1,2)
%         z2p(maskR==0)=nan;
%         contourf(lonR,latR,z2p)
%         %my_add___________________
%         caxis([min(min(z2p)) max(max(z2p))])
%         colorbar
%         ttxt=['TPXO9v5_ROMS ' char(ROMSnames(NP(N))) ' Elevation phase'];
%         title(ttxt,'Interpreter','none')
%         %止——————————
%         %    cj_map
%         if 0
%             ellipse(sfac*maskRE.*CmaxE,sfac*maskRE.*CminE,maskRE.*CangE,lonRE,latRE,Ecolor);
%             h=ellipse(sfac*sfmaj,sfac*sfmaj/2,0,sflon,sflat,Ecolor); %Scale ellipse
%             h.LineWidth=1.5;
%             sftxt=['Scale ellipse ' num2str(sfmaj) ' m/s'];
%             text(sflon,sflat_text,sftxt,'HorizontalAlignment','center','color',Ecolor,'fontweight','b','fontsize',sftextsize)
%             caxis([min(min(z2p)) max(max(z2p))])
%             colorbar
%             ttxt=['TPXO9v5_ROMS ' char(ROMSnames(NP(N))) ' Elevation phase'];
%             title(ttxt,'Interpreter','none')
%             text(dtlon,dtlat,dtstr,'HorizontalAlignment','center','fontweight','b','fontsize',sftextsize)
%             print(gcf,'-dpng',fnPNG_Z);
%             %Current angle and phase
%             figure
%             figure_fit_A4
%             %    colormap(squeeze_jet)
%             subplot(2,1,1)
%             Cang(maskR==0)=nan;
%             contourf(lonR,latR,Cang)
%             caxis([min(min(Cang)) max(max(Cang))])
%             %    cj_map
%             colorbar
%             ttxt=['TPXO9v5_ROMS ' char(ROMSnames(NP(N))) ' Current angle'];
%             title(ttxt,'Interpreter','none')
%             text(dtlon,dtlat,'No time dependence','HorizontalAlignment','center','fontweight','b','fontsize',sftextsize)
%             subplot(2,1,2)
%             Cpha(maskR==0)=nan;
%             contourf(lonR,latR,Cpha)
%             caxis([min(min(Cpha)) max(max(Cpha))])
%             cj_map
%             colorbar
%             ttxt=['TPXO9v5_ROMS ' char(ROMSnames(NP(N))) ' Current phase'];
%             title(ttxt,'Interpreter','none')
%             text(dtlon,dtlat,dtstr,'HorizontalAlignment','center','fontweight','b','fontsize',sftextsize)
%             print(gcf,'-dpng',fnPNG_C1);
%             %Current minimum and maximum
%             figure
%             figure_fit_A4
%             %    colormap(squeeze_jet)
%             subplot(2,1,1)
%             Cmin(maskR==0)=nan;
%             contourf(lonR,latR,Cmin)
%             caxis([min(min(Cmin)) max(max(Cmin))])
%             %    cj_map
%             colorbar
%             ttxt=['TPXO9v5_ROMS ' char(ROMSnames(NP(N))) ' Current min'];
%             title(ttxt,'Interpreter','none')
%             text(dtlon,dtlat,'No time dependence','HorizontalAlignment','center','fontweight','b','fontsize',sftextsize)
%             subplot(2,1,2)
%             Cmax(maskR==0)=nan;
%             contourf(lonR,latR,Cmax)
%             caxis([min(min(Cmax)) max(max(Cmax))])
%             cj_map
%             colorbar
%             ttxt=['TPXO9v5_ROMS ' char(ROMSnames(NP(N))) ' Current max'];
%             title(ttxt,'Interpreter','none')
%             text(dtlon,dtlat,'No time dependence','HorizontalAlignment','center','fontweight','b','fontsize',sftextsize)
%             print(gcf,'-dpng',fnPNG_C2);
%         end
%     end


    %%
    function figure_fit_A4
        %Create or modify a figure the size of an A4 paper in portrait mode.
        %Leave here because the script is distributed.

        %Create new figure (if none exists already) and make units cm
        set(gcf,'color',[1 1 1]);
        set(gcf,'units','centimeters')

        %Define A4 in cm
        pA4=[21 29.7];
        mp_pix=get(0,'MonitorPositions');
        pixpercm=get(0,'ScreenPixelsPerInch')/2.54;
        cmperpix=1/pixpercm;
        mp_cm=mp_pix*cmperpix; %[left bottom width height] cm
        [nm,~]=size(mp_pix); %nm=number of monitors
        if nm==1
            set(gcf,'position',[1 -pA4(2)+20 pA4]);
        else
            set(gcf,'position',[mp_cm(2,1)+1 -pA4(2)+mp_cm(1,4) pA4])
        end

    end
end



function TPXO9v5_ROMS(t0,ROMSnames,fnGrid,fnOut,ndays,TPXOpath)

    % Creates a ROMS forcing file
    % Called by TPXO9v5_ROMS_script.m

    % t0: start time
    % ROMSnames: ROMS 分量 to calculate
    % fnGrid: ROMS grid to calculate tidal 分量 on
    % fnOut: name of ROMS tide file
    % ndays: Approximate length of run in days (default 365)

    %Prepares a tidal forcing file for ROMS from TPXO tidal model (OSU) version 8.

    %If run on R2013 on it will use scatteredInterpolant/griddedInterpolant
    %otherwise will use TriScatteredInterp.

    % Uses data from: http://www.tpxo.net/global/tpxo9 v5 atlas
    % Registration required, free for accademic or non-commercial use

    % J. Luick and C. James
    % www.austides.com
    % 11 October 2021
    %**************************************************************************

    varcheck('ndays',365);    %Sets default ndays=365 if none specified.
    varcheck('ROMSnames',{'MM', 'MF', 'Q1', 'O1', 'P1', 'K1', 'S1', 'N2', 'M2', 'S2', 'K2', 'MN4', 'M4', 'MS4', '2N2'});
    varcheck('fnOut','Ocean_tide.nc');

    lengthSim=ndays;     %Approximate anticipated length of model run (days) (for f & u)
    ROMStitle=['ROMS forcing file from TPXO9v5 data for ' datestr(t0,0)];

    %ROMS grid info
    if isstruct(fnGrid)
        lonR=fnGrid.xr;
        latR=fnGrid.yr;
        maskR=fnGrid.mr;
        maskP=fnGrid.mp;
    else
        lonR=ncread(fnGrid,'lon_rho');
        latR=ncread(fnGrid,'lat_rho');
        maskR=ncread(fnGrid,'mask_rho');
        maskP=ncread(fnGrid,'mask_psi');
    end
    lonR=mod(lonR,360); %Not modified for grids that span longitude=0;
    [L,M]=size(maskP);

    TPXOfile.grid.atlas30=[TPXOpath 'grid_tpxo9_atlas_30_v5.nc'];
    TPXOfile.elev.TC_2n2=[TPXOpath 'h_2n2_tpxo9_atlas_30_v5.nc'];
    TPXOfile.elev.TC_k1=[TPXOpath 'h_k1_tpxo9_atlas_30_v5.nc'];
    TPXOfile.elev.TC_k2=[TPXOpath 'h_k2_tpxo9_atlas_30_v5.nc'];
    TPXOfile.elev.TC_m2=[TPXOpath 'h_m2_tpxo9_atlas_30_v5.nc'];
    TPXOfile.elev.TC_m4=[TPXOpath 'h_m4_tpxo9_atlas_30_v5.nc'];
    TPXOfile.elev.TC_mf=[TPXOpath 'h_mf_tpxo9_atlas_30_v5.nc'];
    TPXOfile.elev.TC_mm=[TPXOpath 'h_mm_tpxo9_atlas_30_v5.nc'];
    TPXOfile.elev.TC_mn4=[TPXOpath 'h_mn4_tpxo9_atlas_30_v5.nc'];
    TPXOfile.elev.TC_ms4=[TPXOpath 'h_ms4_tpxo9_atlas_30_v5.nc'];
    TPXOfile.elev.TC_n2=[TPXOpath 'h_n2_tpxo9_atlas_30_v5.nc'];
    TPXOfile.elev.TC_o1=[TPXOpath 'h_o1_tpxo9_atlas_30_v5.nc'];
    TPXOfile.elev.TC_p1=[TPXOpath 'h_p1_tpxo9_atlas_30_v5.nc'];
    TPXOfile.elev.TC_q1=[TPXOpath 'h_q1_tpxo9_atlas_30_v5.nc'];
    TPXOfile.elev.TC_s2=[TPXOpath 'h_s2_tpxo9_atlas_30_v5.nc'];
    TPXOfile.elev.TC_s1=[TPXOpath 'h_s1_tpxo9_atlas_30_v5.nc'];

    TPXOfile.vel.TC_2n2=[TPXOpath 'u_2n2_tpxo9_atlas_30_v5.nc'];
    TPXOfile.vel.TC_k1=[TPXOpath 'u_k1_tpxo9_atlas_30_v5.nc'];
    TPXOfile.vel.TC_k2=[TPXOpath 'u_k2_tpxo9_atlas_30_v5.nc'];
    TPXOfile.vel.TC_m2=[TPXOpath 'u_m2_tpxo9_atlas_30_v5.nc'];
    TPXOfile.vel.TC_m4=[TPXOpath 'u_m4_tpxo9_atlas_30_v5.nc'];
    TPXOfile.vel.TC_mf=[TPXOpath 'u_mf_tpxo9_atlas_30_v5.nc'];
    TPXOfile.vel.TC_mm=[TPXOpath 'u_mm_tpxo9_atlas_30_v5.nc'];
    TPXOfile.vel.TC_mn4=[TPXOpath 'u_mn4_tpxo9_atlas_30_v5.nc'];
    TPXOfile.vel.TC_ms4=[TPXOpath 'u_ms4_tpxo9_atlas_30_v5.nc'];
    TPXOfile.vel.TC_n2=[TPXOpath 'u_n2_tpxo9_atlas_30_v5.nc'];
    TPXOfile.vel.TC_o1=[TPXOpath 'u_o1_tpxo9_atlas_30_v5.nc'];
    TPXOfile.vel.TC_p1=[TPXOpath 'u_p1_tpxo9_atlas_30_v5.nc'];
    TPXOfile.vel.TC_q1=[TPXOpath 'u_q1_tpxo9_atlas_30_v5.nc'];
    TPXOfile.vel.TC_s2=[TPXOpath 'u_s2_tpxo9_atlas_30_v5.nc'];
    TPXOfile.vel.TC_s1=[TPXOpath 'u_s1_tpxo9_atlas_30_v5.nc'];

    %TPXO data
    disp('Reading TPXO')
    TPXO=readTPXOdata(TPXOfile,ROMSnames,lonR,latR);

    %Magic numbers for TPXO (Solar Doodson Numbers, Ref. Phase, Speed degrees/hour)
    TPXOharmonics.TC_M2= [2  -2   2   0   0   0    0   28.9841042];
    TPXOharmonics.TC_S2= [2   0   0   0   0   0    0   30.0000000];
    TPXOharmonics.TC_N2= [2  -3   2   1   0   0    0   28.4397297];
    TPXOharmonics.TC_K2= [2   0   2   0   0   0    0   30.0821381];
    TPXOharmonics.TC_K1= [1   0   1   0   0   0   90   15.0410690];
    TPXOharmonics.TC_S1= [1   0   1   0   0   0   180   15.0000000];
    TPXOharmonics.TC_O1= [1  -2   1   0   0   0  270   13.9430351];
    TPXOharmonics.TC_P1= [1   0  -1   0   0   0  270   14.9589310];
    TPXOharmonics.TC_Q1= [1  -3   1   1   0   0  270   13.3986607];
    TPXOharmonics.TC_MM= [0   1   0  -1   0   0    0    0.5443747];
    TPXOharmonics.TC_MF= [0   2   0   0   0   0    0    1.0980331];
    TPXOharmonics.TC_MN4=[4  -5   4   1   0   0    0   57.4238319];
    TPXOharmonics.TC_MS4=[4  -2   2   0   0   0    0   58.9841042];
    TPXOharmonics.TC_M4= [4  -4   4   0   0   0    0   57.9682083];
    TPXOharmonics.TC_2N2= [2  -4   2   2   0   0    0    27.8953548];

    %Magic numbers the way ROMS sees them
    Nharmonics=length(ROMSnames);
    ROMSperiods=zeros(1,Nharmonics);
    for n=1:Nharmonics
        ROMSharmonics.(['TC_' ROMSnames{n}])=TPXOharmonics.(['TC_' ROMSnames{n}]);
        ROMSperiods(n)=360./TPXOharmonics.(['TC_' ROMSnames{n}])(end);
        Vdeg.(['TC_' ROMSnames{n}])=Vphase(t0,ROMSharmonics.(['TC_' ROMSnames{n}]));
    end

    % V,u,f (reference phase and nodal corrections)
    [fFac,uFac]=TPXOnodalfactors_ROMS(t0+lengthSim/2,ROMSnames);

    % Extract tide info from TPXO and put on rho grid
    zamp=zeros(L+1,M+1,Nharmonics);
    zpha=zeros(L+1,M+1,Nharmonics);
    uamp=zeros(L+1,M+1,Nharmonics);
    upha=zeros(L+1,M+1,Nharmonics);
    vamp=zeros(L+1,M+1,Nharmonics);
    vpha=zeros(L+1,M+1,Nharmonics);
    major=zeros(L+1,M+1,Nharmonics);
    minor=zeros(L+1,M+1,Nharmonics);
    inclination=zeros(L+1,M+1,Nharmonics);
    phase=zeros(L+1,M+1,Nharmonics);
    %————————————————————————————————————————————
    %原来函数循环部分
    for k=1:Nharmonics
        %z
        harmonic=TPXO.harmonic_a30.harmonic(k);
        disp(['正在插值 ',char(harmonic),' 振幅'])
        zi=interpTPXO(TPXO.h,k,lonR,latR,maskR);
        %振幅和迟角的计算详细使用ncdisp查看TPXO数据nc文件：amp=abs(hRe+i*hIm)  phase=atan2(-hIm,hRe)/pi*180
        %同理也有潮流u，v的振幅和迟角计算公式
        zamp(:,:,k)=abs(zi).*fFac.(['TC_' ROMSnames{k}]);
        zpha(:,:,k)=mod(-angle(zi)*180/pi-uFac.(['TC_' ROMSnames{k}])-Vdeg.(['TC_' ROMSnames{k}]),360);
        %    zpha(:,:,k)=-mod(angle(zi)*180/pi-uFac.(['TC_' ROMSnames{k}])-Vdeg.(['TC_' ROMSnames{k}]),-360);

        %mod这里指计算
        %-angle(zi)*180/pi-uFac.(['TC_' ROMSnames{k}])-Vdeg.(['TC_'ROMSnames{k}])
        %然后除以360度，取模，下面的潮流UV亦同
        %u
        disp(['正在插值 ',char(harmonic),' u 分量'])
        ui=interpTPXO(TPXO.U,k,lonR,latR,maskR);
        uamp(:,:,k)=abs(ui).*fFac.(['TC_' ROMSnames{k}]);
        upha(:,:,k) =mod(-angle(ui)*180/pi-uFac.(['TC_' ROMSnames{k}])-Vdeg.(['TC_' ROMSnames{k}]),360);
        %    upha(:,:,k)=-mod(angle(ui)*180/pi-uFac.(['TC_' ROMSnames{k}])-Vdeg.(['TC_' ROMSnames{k}]),-360);
        %v
        disp(['正在插值 ',char(harmonic),' v 分量'])
        vi=interpTPXO(TPXO.V,k,lonR,latR,maskR);
        vamp(:,:,k)=abs(vi).*fFac.(['TC_' ROMSnames{k}]);
        vpha(:,:,k)=mod(-angle(vi)*180/pi-uFac.(['TC_' ROMSnames{k}])-Vdeg.(['TC_' ROMSnames{k}]),360);
        %    vpha(:,:,k)=-mod(angle(vi)*180/pi-uFac.(['TC_' ROMSnames{k}])-Vdeg.(['TC_' ROMSnames{k}]),-360);
        %ellipse
        [maj,ecc,inc,pha]=ap2ep(squeeze(uamp(:,:,k)),squeeze(upha(:,:,k)),...
            squeeze(vamp(:,:,k)),squeeze(vpha(:,:,k)));
        major(:,:,k)=maj;
        minor(:,:,k)=maj.*ecc;
        %ecc(isnan(ecc))=0; %zero current results in e=NaN. ROMS crashes. (ps circle has e=0)
        inclination(:,:,k)=inc;
        phase(:,:,k)=pha;
    end
    %——————————————————————————————————————————————
    %迟角部分的计算进行了修改
    % for k=1:Nharmonics
    %     %z
    %     harmonic=TPXO.harmonic_a30.harmonic(k);
    %     disp(['正在插值 ',char(harmonic),' amplitudes'])
    %     zi=interpTPXO(TPXO.h,k,lonR,latR,maskR);
    %     zamp(:,:,k)=abs(zi).*fFac.(['TC_' ROMSnames{k}]);
    %     zpha(:,:,k)=angle(zi).*180./pi+uFac.(['TC_' ROMSnames{k}])+Vdeg.(['TC_' ROMSnames{k}]);
    %     %u
    %     disp(['正在插值 ',char(harmonic),' u 分量'])
    %     ui=interpTPXO(TPXO.U,k,lonR,latR,maskR);
    %     uamp(:,:,k)=abs(ui).*fFac.(['TC_' ROMSnames{k}]);
    %     upha(:,:,k)=angle(ui).*180./pi-uFac.(['TC_' ROMSnames{k}])-Vdeg.(['TC_' ROMSnames{k}]);
    %     %v
    %     disp(['正在插值 ',char(harmonic),' v 分量'])
    %     vi=interpTPXO(TPXO.V,k,lonR,latR,maskR);
    %     vamp(:,:,k)=abs(vi).*fFac.(['TC_' ROMSnames{k}]);
    %     vpha(:,:,k)=angle(vi).*180./pi-uFac.(['TC_' ROMSnames{k}])-Vdeg.(['TC_' ROMSnames{k}]);
    %     %ellipse
    %     [maj,ecc,inc,pha]=ap2ep(squeeze(uamp(:,:,k)),squeeze(upha(:,:,k)),...
    %     squeeze(vamp(:,:,k)),squeeze(vpha(:,:,k)));
    %     major(:,:,k)=maj;
    %     minor(:,:,k)=maj.*ecc;
    %     %ecc(isnan(ecc))=0; %zero current results in e=NaN. ROMS crashes. (ps circle has e=0)
    %     inclination(:,:,k)=inc;
    %     phase(:,:,k)=pha;
    % end
    %————————————————————————————————————————————————————
    %%%%%%%将潮流椭圆参数的短轴数组中的nan值转为0，避免影响ROMS计算
    minor(isnan(minor))=0;
    %Set up output netcdf forcing file

    %global atts
    %String version of ROMSnames (for global attribute only)
    varname={'tide_period'; 'tide_Ephase'; 'tide_Eamp';...
        'tide_Cmin'; 'tide_Cmax'; 'tide_Cangle'; 'tide_Cphase';...
        'tide_Uamp'; 'tide_Uphase'; 'tide_Vamp'; 'tide_Vphase'};

    nVar=length(varname);

    if exist(fnOut,'file')
        delete(fnOut)
    end
    ROMSnames_att=cellfun(@(x) [x, ' '],ROMSnames,'uniformoutput',false);
    ROMSnames_att=[ROMSnames_att{:}];

    attvals={{'Tide angular period','hours'};           %tide_period
        {'Tide elevation phase angle','degrees'}; %tide_Ephase
        {'Tide elevation amplitude','meter'};    %tide_Eamp
        {'Tidal current ellipse semi-minor axis','meter second-1'}; %tide_Cmin
        {'Tidal current ellipse semi-major axis','meter second-1'}; %tide_Cmax
        {'Tidal current ellipse inclination angle','degrees between semi-major axis and East'}; %tide_Cangle
        {'Tidal current phase angle','degrees, time of maximum velocity with respect chosen time origin'};   %tide_Cphase
        {'Tidal current U-component amplitude','m/s'}  %tide_Uamp
        {'Tidal current U-component phase','degrees'}        %tide_Uphase
        {'Tidal current V-component amplitude','m/s'}   %tide_Vamp
        {'Tidal current V-component phase','degrees'}};      %tide_Vphase

    fileschema.Name='/';
    fileschema.Dimensions(1).Name='xi_rho';
    fileschema.Dimensions(1).Length=L+1;
    fileschema.Dimensions(2).Name='eta_rho';
    fileschema.Dimensions(2).Length=M+1;
    fileschema.Dimensions(3).Name='tide_period';
    fileschema.Dimensions(3).Length=Nharmonics;
    fileschema.Attributes(1).Name='title';
    fileschema.Attributes(1).Value=ROMStitle;
    fileschema.Attributes(2).Name='Creation_date';
    fileschema.Attributes(2).Value=datestr(date,'yyyymmdd');
    fileschema.Attributes(3).Name='grd_file';
    if isstruct(fnGrid)
        fileschema.Attributes(3).Value=fnGrid.file;
    else
        fileschema.Attributes(3).Value=fnGrid;
    end
    fileschema.Attributes(4).Name='type';
    fileschema.Attributes(4).Value='ROMS forcing file from TPXO9 v5';
    fileschema.Attributes(5).Name='ini_date_datenumber';
    fileschema.Attributes(5).Value=t0;
    fileschema.Attributes(6).Name='ini_date_mjd';
    fileschema.Attributes(6).Value=t0-datenum(2012,8,5);
    fileschema.Attributes(7).Name='分量';
    fileschema.Attributes(7).Value=ROMSnames_att;
    fileschema.Format='64bit';
    for i=1:nVar
        fileschema.Variables(i).Name=varname{i};
        if strcmp(varname{i},'tide_period')
            fileschema.Variables(i).Dimensions(1).Name='tide_period';
            fileschema.Variables(i).Dimensions(1).Length=Nharmonics;
        else
            fileschema.Variables(i).Dimensions(1).Name='xi_rho';
            fileschema.Variables(i).Dimensions(1).Length=L+1;
            fileschema.Variables(i).Dimensions(2).Name='eta_rho';
            fileschema.Variables(i).Dimensions(2).Length=M+1;
            fileschema.Variables(i).Dimensions(3).Name='tide_period';
            fileschema.Variables(i).Dimensions(3).Length=Nharmonics;
        end
        fileschema.Variables(i).Datatype='double';
        fileschema.Variables(i).Attributes(1).Name='long_name';
        fileschema.Variables(i).Attributes(1).Value=attvals{i}{1};
        fileschema.Variables(i).Attributes(2).Name='units';
        fileschema.Variables(i).Attributes(2).Value=attvals{i}{2};
    end
    disp('正在创建nc文件')
    ncwriteschema(fnOut,fileschema);


    ncwrite(fnOut,'tide_period',ROMSperiods)
    ncwrite(fnOut,'tide_Eamp',zamp)
    ncwrite(fnOut,'tide_Ephase',zpha)
    ncwrite(fnOut,'tide_Cmax',major)
    ncwrite(fnOut,'tide_Cmin',minor)
    ncwrite(fnOut,'tide_Cangle',inclination)
    ncwrite(fnOut,'tide_Cphase',phase)
    ncwrite(fnOut,'tide_Uamp',uamp)
    ncwrite(fnOut,'tide_Uphase',upha)
    ncwrite(fnOut,'tide_Vamp',vamp)
    ncwrite(fnOut,'tide_Vphase',vpha)

end

%%
function [fFac,uFac]=TPXOnodalfactors_ROMS(dnum,Names)

    %Charles modified TPXOnodalfactors in September 2021. I modified and
    %renamed his version (adding _ROMS) to distinguish from ATtides version.
    %f and u factors for the harmonics listed in cell array Names.
    %(e.g. Names={'MM' 'M2' S2'};
    %Only those which are in the TPXO model are evaluated.
    %They are evaluated at time dnum (a Matlab datenumber).
    %See Table xxvi in A.T. Doodson (1928) 'On the Analysis of Tidal Observations'
    %Philosophical Transactions of the Royal Society of London. Series A, Vol. 227
    %J. Luick, Thanksgiving Day, 2011, Adelaide

    %if f and u are not reassigned below, they are probably solar
    %terms, i.e. have f=1 and u=0.
    f=struct;
    u=struct;
    % fFac=ones(length(Names),1);
    % uFac=zeros(length(Names),1);

    t=(dnum+0.5-datenum(1900,1,1))/36525;
    VN=mod(360*(0.719954-5.372617*t+0.000006*t*t),360);
    VN(VN<0)=VN(VN<0)+360;
    VN=VN*pi/180;

    %coefficients
    cN=cos(VN);
    c2N=cos(2*VN);
    c3N=cos(3*VN);
    sN=sin(VN);
    s2N=sin(2*VN);
    s3N=sin(3*VN);

    %Assign values for f and u of nonsolar constituents
    %Doodson Table XXVI (with u*pi/180)
    f.TC_MM=1.0-0.1300*cN+0.0013*c2N;
    u.TC_MM=0;
    f.TC_MF=1.0429+0.4135*cN-0.004*c2N;
    u.TC_MF=-0.4143*sN+0.0468*s2N-0.0066*s3N;

    f.TC_O1=1.0089+.1871*cN-0.0147*c2N+0.0014*c3N;
    u.TC_O1=0.1885*sN-0.0234*s2N+0.0033*s3N;

    f.TC_K1=1.0060+0.1150*cN-0.0088*c2N+0.0006*c3N;
    u.TC_K1=-0.1546*sN+0.0119*s2N-0.0012*s3N;

    f.TC_M2=1.0004-0.0373*cN+0.0002*c2N;
    u.TC_M2=-0.0374*sN;

    f.TC_K2=1.0241+0.2863*cN+0.0083*c2N-0.0015*c3N;
    u.TC_K2=-0.3096*sN+0.0119*s2N-0.0007*s3N;

    % dependent values
    f.TC_Q1=f.TC_O1;
    u.TC_Q1=u.TC_O1;
    f.TC_N2=f.TC_M2;
    u.TC_N2=u.TC_M2;
    f.TC_2N2=f.TC_M2;
    u.TC_2N2=u.TC_M2;
    f.TC_MN4=f.TC_M2^2;
    u.TC_MN4=2*u.TC_M2;
    f.TC_M4=f.TC_M2^2;
    u.TC_M4=2*u.TC_M2;
    f.TC_MS4=f.TC_M2;
    u.TC_MS4=u.TC_M2;

    %Assign fFac and uFac
    for n=1:length(Names)
        if isfield(f,['TC_' Names{n}])
            fFac.(['TC_' Names{n}])=f.(['TC_' Names{n}]);
            uFac.(['TC_' Names{n}])=mod(u.(['TC_' Names{n}])*180/pi,360);
        else
            %if f and u are not assigned, they are probably solar
            %terms, i.e. have f=1 and u=0.
            fFac.(['TC_' Names{n}])=1;
            uFac.(['TC_' Names{n}])=0;
        end
    end

end

%%

function Vdeg=Vphase(dnum,DN_List)
    %************************************************************
    % Compute equilibrium phases in accordance with Cartwright "tidal analysis - a
    % retrospect", 1982, pp170 - 188 in "Time series methods in hydrosciences,
    % A.H.el-Shaarawi and S.R.Esterby (eds), Elsevier
    % dnum (Matlab datenumber) need not be an integer (V will be computed for
    % the actual time, not the integral part).
    %J. Luick, www.austides.com
    %340 / 5,000
    % 根据 Cartwright “潮汐分析 - 回顾”，1982，pp170 - 188 在“水科学中的时间序列方法,
    %AHel-Shaarawi 和 SREsterby (eds)，Elsevier dnum (Matlab datenumber) 计算平衡阶段不需要是 整数
    %（V 将根据实际时间计算，而不是整数部分）。
    %************************************************************
    t=(dnum+0.5-datenum(1900,1,1))/36525;
    tHour=mod(dnum,1)*24;     %Hour of day

    DN_Nbr=DN_List(1:7);
    DN_Pha=DN_List(:,7);
    DN_Spd=DN_List(:,8);

    Vs=mod(360*(0.751206 + 1336.855231*t - 0.000003*t*t),360);
    Vh=mod(360*(0.776935 +  100.002136*t + 0.000001*t*t),360);
    Vp=mod(360*(0.928693 +   11.302872*t - 0.000029*t*t),360);
    VN=mod(360*(0.719954 -    5.372617*t + 0.000006*t*t),360);
    Vp1=mod(360*(0.781169 +   0.004775*t + 0.000001*t*t),360);
    Vs(Vs<0)=Vs(Vs<0)+360;
    Vh(Vs<0)=Vh(Vh<0)+360;
    Vp(Vp<0)=Vp(Vp<0)+360;
    VN(VN<0)=VN(VN<0)+360;
    Vp1(Vp1<0)=Vp1(Vp1<0)+360;

    Vdeg=tHour*DN_Spd+Vs*DN_Nbr(:,2)+Vh*DN_Nbr(:,3)+...
        Vp*DN_Nbr(:,4)+VN*DN_Nbr(:,5)+Vp1*DN_Nbr(:,6)+DN_Pha;
    Vdeg=mod(Vdeg,360);
end

%%
function VARinterp=interpTPXO(TPXOvar,count,lon,lat,mask)
    %*****************************************************************
    % Extract TPXO data and interpolate onto ROMS grid
    % Inputs:
    % VAR: hRE, hIm, uRE, uIm, vRe, or vIm
    % harmonic: one of: M2 S2 N2 K2 K1 O1 P1 Q1 MF MM M4 MS4 MN4
    % lon, lat: 2D arrays of longitude and latitude to interpolate to
    % mask: array of 1s and 0s corresponding to wet and dry points of lon & lat
    % Output: VARinterp (VAR on lon, lat grid)
    % TPXO files must be on the matlab path
    % J. Luick, www.austides.com
    % Modified by C James October 2013
    %*****************************************************************

    VARinterp=zeros(size(mask));
    iswet=mask==1;

    x=TPXOvar.x_a30;
    y=TPXOvar.y_a30;
    z=squeeze(TPXOvar.z_a30(:,:,count));
    depth=TPXOvar.depth_a30;
    m=TPXOvar.mask_a30&depth>0;
    %注意：这里depth是TPXO的测深数据，海洋部分有数据，陆地值全为0;
    %      另外TPXO9的mask全是1的，“m=TPXOvar.mask_a30&depth>0”这一步操作就是创建TPXO网格的淹没mask（陆地为0，海洋为1）

    % if(exist('scatteredInterpolant','file') && exist('griddedInterpolant','file'))
    %     F=scatteredInterpolant(x(m),y(m),z(m),'nearest');
    %     z=F(x,y);
    %     F=griddedInterpolant(x',y',z');
    %     V1=F(lon(iswet),lat(iswet))';    %z=F(x,y) interpolates to 1-d vectors x and y  (z also is 1-d)
    %     VARinterp(iswet)=V1;
    % elseif exist('TriScatteredInterp','file')
    %     F=TriScatteredInterp(x(m),y(m),z(m),'nearest'); %#ok<*DTRIINT>
    %     z=F(x,y);
    %     F=TriScatteredInterp(x(:),y(:),z(:));
    %     V1=F(lon(iswet),lat(iswet));
    %     VARinterp(iswet)=V1;
    % elseif exist('griddata','file')
    %     z=griddata(x(m),y(m),z(m),x,y,'nearest');
    %     VARinterp(iswet)=griddata(x,y,z,lon(iswet),lat(iswet));
    % end

    %我进行的修改使用griddata函数插值，插值前需要进行转置，使其和ROMS网格的方向对应。
    %x =x' ; y=y' ; z = z' ;  depth = depth' ; m =m';

    z=griddata(x(m),y(m),z(m),x,y,'nearest');

    VARinterp(iswet)=griddata(x,y,z,lon(iswet),lat(iswet));

end
%%
function TPXO=readTPXOdata(TPXOfile,ROMSnames,lon,lat)
    %Read TPXO version 9 data
    %J. Luick, www.austides.com
    %With help from C. James

    lonmin=min(min(lon));
    lonmax=max(max(lon));
    latmin=min(min(lat));
    latmax=max(max(lat));

    bndx=[lon(1,1) lon(end,1) lon(end,end) lon(1,end)];
    bndy=[lat(1,1) lat(end,1) lat(end,end) lat(1,end)];

    var={'h','U','V'};

    count_a30=0;
    for n=1:length(ROMSnames)
        disp(['调和： ' char(ROMSnames(n))]);
        TPXOfile_grid=TPXOfile.grid.atlas30;
        count_a30=count_a30+1;
        TPXO.('harmonic_a30').harmonic(count_a30)=ROMSnames(n);
        TPXOfile_elev=TPXOfile.elev.(['TC_' lower(ROMSnames{n})]);
        TPXOfile_vel=TPXOfile.vel.(['TC_' lower(ROMSnames{n})]);
        file={TPXOfile_elev,TPXOfile_vel,TPXOfile_vel};
        for i=1:length(var)
            if strcmp(var{i},'h')
                coord='z';
            elseif strcmp(var{i},'U')
                coord='u';
            elseif strcmp(var{i},'V')
                coord='v';
            end
            X=ncread(file{i},['lon_' coord]);
            Y=ncread(file{i},['lat_' coord]);
            I=find((Y>=latmin-0.5)&(Y<=latmax+0.5));
            J=find((X>=lonmin-0.5)&(X<=lonmax+0.5));
            istart=I(1);
            jstart=J(1);
            icount=length(I);
            jcount=length(J);

            H=ncread(TPXOfile_grid,['h' coord],[istart jstart],[icount jcount]);
            Z=complex(ncread(file{i},[lower(var{i}) 'Re'],[istart jstart],[icount jcount]),...
                ncread(file{i},[lower(var{i}) 'Im'],[istart jstart],[icount jcount]));

            [x,y]=meshgrid(X(J),Y(I));
            if strcmp(var{i},'h')
                z=double(Z)/1000;
            elseif strcmp(var{i},'U') || strcmp(var{i},'V')
                z=double(Z)/10000;
            end
            depth=double(H);
            % is mask necessary here - think it is just to speed things up but
            % can cause problems for small grids.
            mask=inpolygon(x,y,bndx,bndy);
            % remove mask as a factor
            mask=true(size(mask));

            TPXO.(var{i}).x_a30=x;
            TPXO.(var{i}).y_a30=y;
            TPXO.(var{i}).depth_a30=depth;
            TPXO.(var{i}).mask_a30=mask;
            if strcmp(var{i},'h')
                TPXO.(var{i}).z_a30(:,:,count_a30)=z;
            else
                TPXO.(var{i}).z_a30(:,:,count_a30)=z./repmat(TPXO.(var{i}).depth_a30,[1 1 size(z,3)]);
            end
        end
    end

end

function [SEMA,  ECC, INC, PHA, w, TWOCIR]=ap2ep(Au, PHIu, Av, PHIv, plot_demo)
    %
    % Convert tidal amplitude and phase lag (ap-) parameters into tidal ellipse
    % (ep-) parameters. Please refer to ep2app for its inverse function.
    %
    % Usage:
    %
    % [SEMA,  ECC, INC, PHA, w]=ap2ep(Au, PHIu, Av, PHIv, plot_demo)
    %
    % where:
    %
    %     Au, PHIu, Av, PHIv are the amplitudes and phase lags (in degrees) of
    %     u- and v- tidal current 分量. They can be vectors or
    %     matrices or multidimensional arrays.
    %
    %     plot_demo is an optional argument, when it is supplied as an array
    %     of indices, say [i j k l], the program will plot an  ellipse
    %     corresponding to Au(i,j, k, l), PHIu(i,j,k,l), Av(i,j,k,l), and
    %     PHIv(i,j,k,l);
    %
    %     Any number of dimensions are allowed as long as your computer
    %     resource can handle.
    %
    %     SEMA: Semi-major axes, or the maximum speed;
    %     ECC:  Eccentricity, the ratio of semi-minor axis over
    %           the semi-major axis; its negative value indicates that the ellipse
    %           is traversed in clockwise direction.
    %     INC:  Inclination, the angles (in degrees) between the semi-major
    %           axes and u-axis.
    %     PHA:  Phase angles, the time (in angles and in degrees) when the
    %           tidal currents reach their maximum speeds,  (i.e.
    %           PHA=omega*tmax).
    %
    %           These four ep-parameters will have the same dimensionality
    %           (i.e., vectors, or matrices) as the input ap-parameters.
    %
    %     w:    Optional. If it is requested, it will be output as matrices
    %           whose rows allow for plotting ellipses and whose columns are
    %           for different ellipses corresponding columnwise to SEMA. For
    %           example, plot(real(w(1,:)), imag(w(1,:))) will let you see
    %           the first ellipse. You may need to use squeeze function when
    %           w is a more than two dimensional array. See example.m.
    %
    % Document:   tidal_ellipse.ps
    %
    % Revisions: May  2002, by Zhigang Xu,  --- adopting Foreman's northern
    % semi major axis convention.
    %
    % For a given ellipse, its semi-major axis is undetermined by 180. If we borrow
    % Foreman's terminology to call a semi major axis whose direction lies in a range of
    % [0, 180) as the northern semi-major axis and otherwise as a southern semi major
    % axis, one has freedom to pick up either northern or southern one as the semi major
    % axis without affecting anything else. Foreman (1977) resolves the ambiguity by
    % always taking the northern one as the semi-major axis. This revision is made to
    % adopt Foreman's convention. Note the definition of the phase, PHA, is still
    % defined as the angle between the initial current vector, but when converted into
    % the maximum current time, it may not give the time when the maximum current first
    % happens; it may give the second time that the current reaches the maximum
    % (obviously, the 1st and 2nd maximum current times are half tidal period apart)
    % depending on where the initial current vector happen to be and its rotating sense.
    %
    % Version 2, May 2002

    if nargin < 5
        plot_demo=0;  % by default, no plot for the ellipse
    end


    % Assume the input phase lags are in degrees and convert them in radians.
    PHIu = PHIu/180*pi;
    PHIv = PHIv/180*pi;

    % Make complex amplitudes for u and v
    i = sqrt(-1);
    u = Au.*exp(-i*PHIu);
    v = Av.*exp(-i*PHIv);

    % Calculate complex radius of anticlockwise and clockwise circles:
    wp = (u+i*v)/2;      % for anticlockwise circles
    wm = conj(u-i*v)/2;  % for clockwise circles
    % and their amplitudes and angles
    Wp = abs(wp);
    Wm = abs(wm);
    THETAp = angle(wp);
    THETAm = angle(wm);

    % calculate ep-parameters (ellipse parameters)
    SEMA = Wp+Wm;              % Semi  Major Axis, or maximum speed
    SEMI = Wp-Wm;              % Semin Minor Axis, or minimum speed
    ECC = SEMI./SEMA;          % Eccentricity

    PHA = (THETAm-THETAp)/2;   % Phase angle, the time (in angle) when
    % the velocity reaches the maximum
    INC = (THETAm+THETAp)/2;   % Inclination, the angle between the
    % semi major axis and x-axis (or u-axis).

    % convert to degrees for output
    PHA = PHA/pi*180;
    INC = INC/pi*180;
    THETAp = THETAp/pi*180;
    THETAm = THETAm/pi*180;

    %map the resultant angles to the range of [0, 360].
    PHA=mod(PHA+360, 360);
    INC=mod(INC+360, 360);

    % Mar. 2, 2002 Revision by Zhigang Xu    (REVISION_1)
    % Change the southern major axes to northern major axes to conform the tidal
    % analysis convention  (cf. Foreman, 1977, p. 13, Manual For Tidal Currents
    % Analysis Prediction, available in www.ios.bc.ca/ios/osap/people/foreman.htm)
    k = fix(INC/180);
    INC = INC-k*180;
    PHA = PHA+k*180;
    PHA = mod(PHA, 360);

    % plot at the request
    if nargout >= 5
        ndot=36;
        dot=2*pi/ndot;
        ot=[0:dot:2*pi-dot];
        w=wp(:)*exp(i*ot)+wm(:)*exp(-i*ot);
        w=reshape(w, [size(Au) ndot]);
    end

    if any(plot_demo)
        plot_ell(SEMA, ECC, INC, PHA, plot_demo);
    end

    if nargout == 6
        TWOCIR=struct('Wp', Wp, 'THETAp', THETAp, 'wp', ...
            wp, 'Wm', Wm, 'THETAm', THETAm, 'wm', wm, 'ot', ot, 'dot', dot);
    end


    %Authorship Copyright:
    %
    %    The author retains the copyright of this program, while  you are welcome
    % to use and distribute it as long as you credit the author properly and respect
    % the program name itself. Particularly, you are expected to retain the original
    % author's name in this original version or any of its modified version that
    % you might make. You are also expected not to essentially change the name of
    % the programs except for adding possible extension for your own version you
    % might create, e.g. ap2ep_xx is acceptable.  Any suggestions are welcome and
    % enjoy my program(s)!
    %
    %
    %Author Info:
    %_______________________________________________________________________
    %  Zhigang Xu, Ph.D.
    %  (pronounced as Tsi Gahng Hsu)
    %  Research Scientist
    %  Coastal Circulation
    %  Bedford Institute of Oceanography
    %  1 Challenge Dr.
    %  P.O. Box 1006                    Phone  (902) 426-2307 (o)
    %  Dartmouth, Nova Scotia           Fax    (902) 426-7827
    %  CANADA B2Y 4A2                   email xuz@dfo-mpo.gc.ca
    %_______________________________________________________________________
    %
    % Release Date: Nov. 2000, Revised on May. 2002 to adopt Foreman's northern semi
    % major axis convention.
end

%%
function varcheck(varname,default_value)
    % function varcheck(varname,default_value)
    % checks calling workspace for existence of variable var
    % if it is non-existent it creates it in gives it the value default_value
    % if it exists but is empty it also assigns it the value default_value
    % if it exists and has any other value it is not altered.
    % useful for testing optional inputs into functions
    % Charles James 2012

    if (nargin<2)||~ischar(varname)
        return;
    end

    a=evalin('caller',['exist(''' varname ''',''var'');']);

    if (a~=0)
        var=evalin('caller',varname);
        if isempty(var)
            var=default_value;
        end
    else
        var=default_value;
    end

    assignin('caller',varname,var);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%添加函数部分%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [SEMA,  ECC, INC, PHA, w]=xvzhigang_ap2ep(Au, PHIu, Av, PHIv, plot_demo)
    % Convert tidal amplitude and phase lag (ap-) parameters into tidal ellipse
    % (e-) parameters. Please refer to ep2app for its inverse function.
    %
    % Usage:
    %
    % [SEMA,  ECC, INC, PHA, w]=app2ep(Au, PHIu, Av, PHIv, plot_demo)
    %
    % where:
    %
    %     Au, PHIu, Av, PHIv are the amplitudes and phase lags (in degrees) of
    %     u- and v- tidal current 分量. They can be vectors or
    %     matrices or multidimensional arrays.
    %
    %     plot_demo is an optional argument, when it is supplied as an array
    %     of indices, say [i j k l], the program will plot an  ellipse
    %     corresponding to Au(i,j, k, l), PHIu(i,j,k,l), Av(i,j,k,l), and
    %     PHIv(i,j,k,l);
    %
    %     Any number of dimensions are allowed as long as your computer
    %     resource can handle.
    %
    %     SEMA: Semi-major axes, or the maximum speed;
    %     ECC:  Eccentricity, the ratio of semi-minor axis over
    %           the semi-major axis; its negative value indicates that the ellipse
    %           is traversed in clockwise direction.
    %     INC:  Inclination, the angles (in degrees) between the semi-major
    %           axes and u-axis.
    %     PHA:  Phase angles, the time (in angles and in degrees) when the
    %           tidal currents reach their maximum speeds,  (i.e.
    %           PHA=omega*tmax).
    %
    %           These four e-parameters will have the same dimensionality
    %           (i.e., vectors, or matrices) as the input ap-parameters.
    %
    %     w:    Optional. If it is requested, it will be output as matrices
    %           whose rows allow for plotting ellipses and whose columns are
    %           for different ellipses corresponding columnwise to SEMA. For
    %           example, plot(real(w(1,:)), imag(w(1,:))) will let you see
    %           the first ellipse. You may need to use squeeze function when
    %           w is a more than two dimensional array. See example.m.
    %
    % Document:   tidal_ellipse.ps

    if nargin < 5
        plot_demo=0;  % by default, no plot for the ellipse
    end


    % Assume the input phase lags are in degrees and convert them in radians.
    PHIu = PHIu/180*pi;
    PHIv = PHIv/180*pi;

    % Make complex amplitudes for u and v
    i = sqrt(-1);
    u = Au.*exp(-i*PHIu);
    v = Av.*exp(-i*PHIv);

    % Calculate complex radius of anticlockwise and clockwise circles:
    wp = (u+i*v)/2;      % for anticlockwise circles
    wm = conj(u-i*v)/2;  % for clockwise circles
    % and their amplitudes and angles
    Wp = abs(wp);
    Wm = abs(wm);
    THETAp = angle(wp);
    THETAm = angle(wm);

    % calculate e-parameters (ellipse parameters)
    SEMA = Wp+Wm;              % Semi  Major Axis, or maximum speed
    SEMI = Wp-Wm;              % Semin Minor Axis, or minimum speed
    ECC = SEMI./SEMA;          % Eccentricity

    PHA = (THETAm-THETAp)/2;   % Phase angle, the time (in angle) when
    % the velocity reaches the maximum
    INC = (THETAm+THETAp)/2;   % Inclination, the angle between the
    % semi major axis and x-axis (or u-axis).

    % convert to degrees for output
    PHA = PHA/pi*180;
    INC = INC/pi*180;
    THETAp = THETAp/pi*180;
    THETAm = THETAm/pi*180;

    % flip THETAp and THETAm, PHA, and INC in the range of
    % [-pi, 0) to [pi, 2*pi), which at least is my convention.
    id = THETAp < 0;   THETAp(id) = THETAp(id)+360;
    id = THETAm < 0;   THETAm(id) = THETAm(id)+360;
    id = PHA < 0;      PHA(id) = PHA(id)+360;
    id = INC < 0;      INC(id) = INC(id)+360;


    if nargout == 5
        ndot=36;
        dot=2*pi/ndot;
        ot=[0:dot:2*pi-dot];
        w=wp(:)*exp(i*ot)+wm(:)*exp(-i*ot);
        w=reshape(w, [size(Au) ndot]);
    end


    if any(plot_demo)
        plot_ell(SEMA, ECC, INC, PHA, plot_demo)
    end
end