# 需要安装motuclient
#python -m pip install motuclient==1.8.4 --no-cache-dir 
import subprocess
from datetime import datetime, timedelta
import os.path
import calendar
import sys

# 输入参数
dataType='z'
xmin = 115
xmax = 135
ymin = 20
ymax = 36

startDate = datetime(2021, 1, 1, 0)
endDate = datetime(2022, 1, 1, 0)

outputDir = "."  # 输出目录
username = ""
password = ""


##########用户输入区结束##########

if len(sys.argv)>1:
    dataType=sys.argv[1]

if dataType=='c':
    service_id = "GLOBAL_ANALYSISFORECAST_PHY_001_024-TDS"        #水动力和温盐
    product_id = "cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m"      #海流，每日
    timeType="daily"
    variables = [
        "uo",       #东方向流速(m/s)
        "vo",       #北方向流速(m/s)
    ]
elif dataType=='s':
    service_id = "GLOBAL_ANALYSISFORECAST_PHY_001_024-TDS"        #水动力和温盐
    product_id = "cmems_mod_glo_phy-so_anfc_0.083deg_P1D-m"       #盐度，每日
    timeType="daily"
    variables = [
        "so",       #盐度(10^-3)
    ]
elif dataType=='t':
    service_id = "GLOBAL_ANALYSISFORECAST_PHY_001_024-TDS"        #水动力和温盐
    product_id = "cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m"   #温度，每日
    timeType="daily"
    variables = [
        "thetao",   #温度(°C)
    ]
elif dataType=='z':
    service_id = "GLOBAL_ANALYSISFORECAST_PHY_001_024-TDS"        #水动力和温盐
    product_id = "cmems_mod_glo_phy_anfc_0.083deg_P1D-m"   #温度，每日
    timeType="daily"
    variables = [
        "zos",       #海面高度(m)
    ]
elif dataType=='b':
    service_id = "GLOBAL_ANALYSIS_FORECAST_BIO_001_028-TDS"       #生态指标
#   product_id = "global-analysis-forecast-bio-001-028-daily"     #生态指标，每日
    product_id = "global-analysis-forecast-bio-001-028-monthly"   #生态指标，每月
    timeType="monthly"
    variables = [
        "chl",      #叶绿素a(mg/m^3)
        "dissic",   #溶解无机碳(mol/m^3)
        "fe",       #溶解铁(mmol/m^3)
        "no3",      #硝酸盐(mmol/m^3)
        "nppv",     #生物净初级生产力(mg C/m^3/d)
        "o2",       #溶解氧(mmol/m^3)
        "ph",       #pH值
        "phyc",     #浮游植物(mmol C/m^3)
        "po4",      #磷酸盐(mmol/m^3)
        "si",       #硅酸盐(mmol/m^3)
        "spco2",    #二氧化碳分压(Pa)
        "talk"      #总碱度(mol/m^3)
    ]

depth_min = 0
depth_max = 6000

# 迭代日期范围，每次下载一天的数据
currentDate = startDate
while currentDate <= endDate:
    # 构建输出文件名
    if timeType=="monthly":
        outputFileName = dataType+currentDate.strftime("%Y%m") + ".nc"
    elif timeType=="daily":
        outputFileName = dataType+currentDate.strftime("%Y%m%d") + ".nc"
    else:
        raise ValueError("timeType值不对")
    outputFilePath=os.path.join(outputDir,outputFileName)

    if os.path.isfile(outputFilePath):
        print("文件"+outputFileName+"已存在")
    else:
        if timeType=="monthly":
            dateMin=currentDate.strftime("%Y-%m")+"-01 00:00:00"
            dateMax=currentDate.strftime("%Y-%m")+"-"+str(calendar.monthrange(currentDate.year,currentDate.month)[1])+" 23:59:59"
        elif timeType=="daily":
            dateMin=currentDate.strftime("%Y-%m-%d")+" 00:00:00"
            dateMax=currentDate.strftime("%Y-%m-%d")+" 23:59:59"
        # 构建命令
        command = [
            "python", "-m", "motuclient",
            "--motu", 'https://nrt.cmems-du.eu/motu-web/Motu',
            "--service-id", service_id,
            "--product-id", product_id,
            "--longitude-min", str(xmin),
            "--longitude-max", str(xmax),
            "--latitude-min", str(ymin),
            "--latitude-max", str(ymax),
            "--date-min", dateMin,
            "--date-max", dateMax,
            "--depth-min", str(depth_min),
            "--depth-max", str(depth_max),
        ]

        for variable in variables:
            command.extend(["--variable", variable])

        command.extend([
            "--out-dir", outputDir,
            "--out-name", outputFileName,
            "--user", username,
            "--pwd", password
        ])

        # 执行命令
        print("正在下载"+outputFileName)
        subprocess.run(command, check=True)
        if os.path.isfile(outputFilePath):
            print("下载"+outputFileName+"完成")
        else:
            print("下载"+outputFileName+"失败")

    # 增加日期以继续迭代到下一天
    if timeType=="monthly":
        month=currentDate.month
        while month==currentDate.month:
            currentDate += timedelta(days=1)
    elif timeType=="daily":
        currentDate += timedelta(days=1)
    else:
        raise ValueError("timeType值不对")