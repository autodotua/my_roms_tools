import requests 
import os
import time
from datetime import datetime
from datetime import timedelta
start=datetime(2021,1,1,0)
end=datetime(2022,1,1,0)
span=timedelta(hours=3)
xmin=116; xmax=133
ymin=20; ymax=35
#http://ncss.hycom.org/thredds/ncss/GLBy0.08/expt_93.0?var=surf_el&var=salinity&var=water_temp&var=water_u&var=water_v&north=34&west=119&east=125&south=28&horizStride=1&time=2022-10-21T09%3A00%3A00Z&vertCoord=&accept=netcdf4
baseUrl="http://ncss.hycom.org/thredds/ncss/GLBy0.08/expt_93.0"
downloadFolder=r"C:\Users\autod\Desktop\dhbio\data\hycom"
proxies = {
  "http": "http://localhost:7890",
  "https": "http://localhost:7890",
}

def download():

    time=start
    while time<=end:
        hasError=False
        try:
            filename=f"{time.year}{'%02d' % time.month}{'%02d' % time.day}{'%02d' % time.hour}.nc"
            filename=os.path.join(downloadFolder,filename)
            if os.path.exists(filename):
                print('文件'+filename+'已存在，跳过')
            else:
                print("")
                print("开始下载："+str(time))
                url=f"{baseUrl}?var=surf_el&var=salinity&var=water_temp&var=water_u&var=water_v&"+\
                    f"north={ymax}&west={xmin}&east={xmax}&south={ymin}&horizStride=1&"+\
                        f"time={time.year}-{'%02d' % time.month}-{'%02d' % time.day}T{'%02d' % time.hour}%3A00%3A00Z"+\
                        "&vertCoord=&addLatLon=true&accept=netcdf4"
                #print("链接为："+url)
                host='ncss.hycom.org'
                ua='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.5005.124 Safari/537.36 Edg/102.0.1245.41'
                # nc=requests.get(url,headers={'Host':host,'UserAgent':ua},proxies=proxies,timeout=600)
                nc=requests.get(url,headers={'Host':host,'UserAgent':ua},timeout=600)
                if not nc.ok:
                    print("下载失败："+str(time)+"，代码："+str(nc.status_code))
                else:
                    print("下载完成："+str(time))
                    with open(filename, "wb") as code:
                        code.write(nc.content)
        except Exception as ex:
            print(ex)
            print("请求失败，跳过当前项")
            hasError=True
        if time<end and time+span>end:
            time=end
        else:
            time=time+span
    if hasError:
        raise RuntimeError("存在错误请求")

if __name__=="__main__":
    ok=False
    i=1
    while(True):
        try:
            print("第"+str(i)+"次尝试")
            i=i+1
            download()
            ok=True
        except:
            time.sleep(600)
            pass
        

