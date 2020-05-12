import pytz
import datetime

tz = pytz.timezone('Asia/Ho_Chi_Minh')
print(datetime.datetime.now(tz))