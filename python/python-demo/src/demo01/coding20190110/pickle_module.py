try:
    import _pickle as pickle
except:
    import pickle
import pprint

info=[1,2,3,'abc','Aubrey']
print("原始数据:",pprint.pformat(info))

data1 = pickle.dumps(info)
data2 = pickle.loads(data1)

print("序列化:%r" %data1)
print("反序列化:%r" %data2)