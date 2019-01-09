import json

l = ['iplaypython',[1,2,3], {'name':'xiaoming'}]
encoded_json = json.dumps(l)
print(encoded_json)

decode_json = json.loads(encoded_json)
print(type(decode_json))
print(decode_json)