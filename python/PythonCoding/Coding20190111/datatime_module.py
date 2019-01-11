import datetime
today = datetime.date.today()
print(today)
yesterday = today - datetime.timedelta(days=1)
print(yesterday)
tommorrow = today + datetime.timedelta(days=1)
print(tommorrow)

print("昨天：%s，今天：%s，明天：%s" %(yesterday,today,tommorrow))