import base64

info = b'adadqe'

bm = base64.b64encode(info)
print(bm)

b=base64.b64decode(bm)
print(b)
print(info)