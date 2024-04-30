function roms_create_timely_floats(locations,countPerLocation,startTimes,intervalDays, useLonLat,useMeterDepth,  printOutput)
    arguments
        locations(:,3) double %xyz坐标或lon-lat-depth坐标
        countPerLocation(:,1) double {mustBeInteger} %每个地方一共释放多少粒子
        startTimes(1,1) double % 开始释放的时间
        intervalDays(1,1) double %每隔多少天释放一个
        useLonLat logical %是否提供经纬度而不是网格位置
        useMeterDepth logical %是否提供水深而不是垂直层数
        printOutput logical
    end
    locationCount=size(locations,1);
    n=countPerLocation*ones(locationCount,1);
    t0=startTimes*ones(locationCount,1);
    tc=intervalDays*ones(locationCount,1);
    roms_create_floats(n,t0,locations,tc,zeros(locationCount,3),useLonLat,useMeterDepth,printOutput);