import pytz
import sys
from datetime import datetime
from datetime import date

if len(sys.argv) > 1:
    t_date = sys.argv[1]

tz = pytz.timezone('Asia/Ho_Chi_Minh')

time = datetime.now(tz)

t_date = t_date.split('-')

d1 = date(time.year, time.month, time.day)
d2 = date(int(t_date[2]), int(t_date[1]), int(t_date[0]))

delta = d2 - d1

if delta.days > 96:
    print("False")
else:
    print("True")