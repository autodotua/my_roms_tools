%{
    %开关
     Lfloats == T

     %是否将漂浮子位置输出到控制台
      Fprint == T

     %重启时如何处理。
       FRREC == 0

     %生物
     FBIONAM =  behavior_oyster.in

     %漂浮子数量，
     NFLOATS == 9


G	网格层序号
C	水平坐标类型，0：代表网格点；1：代表经纬度
T	浮子轨迹类型，1：拉格朗日；2：isobaric；3：地势高度
N	该点释放的浮子数量
Ft0	释放时间，从初始化之后的时间（天）
F*0	释放位置，网格X坐标/经度、网格Y坐标/纬度、深度
Fdt	释放间隔（天）
Fd*	聚团的空间分布间隔


        
POS = G, C, T, N,   Ft0,    Fx0,    Fy0,    Fz0,    Fdt,    Fdx,    Fdy,   Fdz

      1  0  1  1    0.d0    5.d0    5.d0  -45.d0   0.d0     0.d0   0.d0   0.d0
      1  0  1  8    0.d0   10.d0   10.d0  -25.d0   0.25d0   0.d0   0.d0   0.d0
%}

function roms_create_floats(n,releaseTimes,releaseLocations,clusterReleaseIntervals,clusterDistributions, useLonLat,useMeterDepth,  printOutput)
    arguments
        n(:,1) double {mustBeInteger} %总数量
        releaseTimes(:,1) double % 开始释放的时间
        releaseLocations(:,3) %xyz坐标或lon-lat-depth坐标
        clusterReleaseIntervals(:,1) %作为时间聚团释放时，时间间隔（天）
        clusterDistributions(:,3) %作为空间聚团释放时，分布间隔
        useLonLat logical %是否提供经纬度而不是网格位置
        useMeterDepth logical %是否提供水深而不是垂直层数
        printOutput logical
    end

    g=1;
    if useLonLat
        c=1;
    else
        c=0;
    end

    if printOutput
        p='T';
    else
        p='F';
    end

    t=1;

    if useMeterDepth
        releaseLocations(:,3)=-abs(releaseLocations(:,3));
    end

    s=length(n);
    assert(s==size(releaseTimes,1),"releaseTimes的第一维应等于n")
    assert(s==size(releaseLocations,1),"releaseLocations的第一维应等于n")
    assert(s==size(clusterReleaseIntervals,1),"clusterReleaseIntervals的第一维应等于n")
    assert(s==size(clusterDistributions,1),"clusterDistributions的第一维应等于n")

    fid=fopen("floats.in","w");
    fprintf(fid,"Lfloats == T\n");
    fprintf(fid,"Fprint == %s\n",p);
    fprintf(fid,"FRREC == 0\n");
    fprintf(fid,"FBIONAM =  behavior_oyster.in\n");
    fprintf(fid,"NFLOATS == %d\n",sum(n));
    fprintf(fid,"POS = G, C, T, N,   Ft0,    Fx0,    Fy0,    Fz0,    Fdt,    Fdx,    Fdy,   Fdz\n");


    for i=1:s
        fprintf(fid,"%d %d %d %d %gd0 %gd0 %gd0 %gd0 %gd0 %gd0 %gd0 %gd0\n",...
            g,c,t,n(i),releaseTimes(i),releaseLocations(i,1),releaseLocations(i,2),releaseLocations(i,3),...
            clusterReleaseIntervals(i),clusterDistributions(i,1),clusterDistributions(i,2),clusterDistributions(i,3));
    end


    fclose(fid);
