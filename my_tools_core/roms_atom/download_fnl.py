import sys, os
import requests

from datetime import date
from dateutil.relativedelta import relativedelta
begin=date(2020,1,1)
end=date(2021,1,1)

def check_file_status(filepath, filesize):
    sys.stdout.write('\r')
    sys.stdout.flush()
    size = int(os.stat(filepath).st_size)
    percent_complete = (size/filesize)*100
    sys.stdout.write('%.3f %s' % (percent_complete, '% Completed'))
    sys.stdout.flush()

# Try to get password
#pswd=''
if len(sys.argv) < 2 and not 'RDAPSWD' in os.environ:
    try:
        import getpass
        input = getpass.getpass
    except:
        try:
            input = raw_input
        except:
            pass
    pswd = input('Password: ')
else:
    try:
        pswd = sys.argv[1]
    except:
        pswd = os.environ['RDAPSWD']
        
url = 'https://rda.ucar.edu/cgi-bin/login'
values = {'email' : 'autodotua@outlook.com', 'passwd' : pswd, 'action' : 'login'}
# Authenticate
ret = requests.post(url,data=values)
if ret.status_code != 200:
    print('Bad Authentication')
    print(ret.text)
    exit(1)
dspath = 'https://rda.ucar.edu/data/ds083.2/'
filelist = []
oneday=relativedelta(days=1)
day=begin
while day<end+oneday:
    for hour in ['00','06','12','18']:
        file=f'grib2/{day.year:04d}/{day.year:04d}.{day.month:02d}/fnl_{day.year:04d}{day.month:02d}{day.day:02d}_{hour}_00.grib2'
        filename=dspath+file
        file_base = os.path.basename(file)

        if os.path.exists(file_base):
            print('文件'+file_base+'已存在，跳过')
        else:
            print('Downloading',file_base)
            req = requests.get(filename, cookies = ret.cookies, allow_redirects=True, stream=True)
            filesize = int(req.headers['Content-length'])
            with open(file_base, 'wb') as outfile:
                chunk_size=1048576
                for chunk in req.iter_content(chunk_size=chunk_size):
                    outfile.write(chunk)
                    if chunk_size < filesize:
                        check_file_status(file_base, filesize)
            check_file_status(file_base, filesize)
        print()
    day=day+oneday
