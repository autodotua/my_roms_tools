function draw_profile(filePath,vars,varNames,direction,degrees,maxDepth,verticleColorRange,horizontalColorRange,textCorner,colorbarLabels)
    arguments
        filePath(1,1) string %文件
        vars(:,1) string %变量名
        varNames(:,1) string %变量描述
        direction(1,1) string {mustBeMember(direction,["lon","lat"])} %剖面方向，沿什么方向切割
        degrees(:,1) double %需要剖的经度/纬度
        maxDepth(:,1) %最大深度，[]表示自动，(1,1)表示全部应用，(:,1)表示为每个var设置不同的最大深度。
        verticleColorRange(:,2) double  %色条的最小值和最大值
        horizontalColorRange(:,2) double  %表层平面色条的最小值和最大值
        textCorner(1,1) string {mustBeMember(textCorner, {'rb', 'lt', 'rt', 'lb'})} = 'lt',
        colorbarLabels(:,1)=[]
    end

    configs
    tl=tiledlayout(length(vars),length(degrees)+1);
    set_tiledlayout_compact(tl);
    [lon_rho,lat_rho]=roms_load_grid_rho;
    latMin=min(lat_rho,[],'all');
    latMax=max(lat_rho,[],'all');
    lonMin=min(lon_rho,[],'all');
    lonMax=max(lon_rho,[],'all');
    gridfile=fullfile(roms.project_dir,roms.input.grid);
    h=read_data(gridfile,'h');
    s_rho=read_data(gridfile,'Cs_r'); %这里用Cs_r好像是不均匀网格，s_rho是均匀网格，可能和Tcline有关。用s_rho是错误的（至少在h>Tcline的海域）。
    s_rho=reshape(s_rho,[1,1,length(s_rho)]);
    z_rho=repmat(h,1,1,length(s_rho)) .* repmat(s_rho,[size(h),1]);
    %这里的z_rho求出来和通过get_roms_grid_info的z_r相比，差了1.001~1.005倍，不清楚原因
    for i=1:length(vars)
        var=vars(i);
        disp("var = "+var)
        rawVarData=read_data(filePath,var);

        nexttile
        flatData=squeeze(mean(rawVarData(:,:,end,:),4));
        draw_background(lon_rho,lat_rho)
        pcolorjw(lon_rho,lat_rho,flatData)
        for d=degrees'
            if direction=="lon"
                plot([d;d],[0;90],'-k');
            elseif direction=="lat"
                plot([0,180],[d,d],'-k');
            end
        end
        if direction=="lon"
            xticks(degrees);
        elseif direction=="lat"
            yticks(degrees);
        end
        caxis(horizontalColorRange(i,:))
        draw_border
        text_corner(varNames(i),'lt');
        color_ncl(37)

        minY=0;
        for j=1:length(degrees)
            nexttile;
            degree=degrees(j);
            disp("degree = "+degree)
            %只支持横平竖直的网格
            if direction=="lon"
                X=lat_rho(1,:);
                index=find(squeeze(lon_rho(:,1))>=degree,1);
                Y=z_rho(index,:,:);
            elseif direction=="lat"
                X=lon_rho(:,1);
                index=find(squeeze(lat_rho(1,:))>=degree,1);
                Y=z_rho(:,index,:);
            end
            X=repmat(X(:),1,size(z_rho,3)+1);
            Y=squeeze(Y);
            Y(:,end+1)=0;
            minY=min([minY,min(Y,[],'all')]);

            varData=mean(rawVarData,4);
            if direction=="lon"
                Z=squeeze(varData(index,:,:));
                xlim([latMin,latMax])
            elseif direction=="lat"
                Z=squeeze(varData(:,index,:));
                xlim([lonMin,lonMax])
            end
            Z(:,end+1)=Z(:,end);

            hold on
            pcolorjw(X,Y,Z)
            color_ncl(10)
            apply_font
            caxis(verticleColorRange(i,:))
            text_corner(varNames(i)+newline+degree+"°",textCorner);
        end

        for j=1:length(degrees)
            nexttile((i-1)*(length(degrees)+1)+j+1);
            if isempty(maxDepth)
                ylim([minY,0])
            elseif length(maxDepth)==1
                ylim([-maxDepth,0])
            else
                ylim([-maxDepth(i),0])
            end
            
            draw_border
            if(j>1)
                yticks([])
            end
            if j==length(degrees)
                c=colorbar;
                if ~isempty(colorbarLabels)
                    c.Label.String=colorbarLabels(i);
                end
            end
        end
    end
