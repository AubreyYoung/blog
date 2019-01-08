import gzip
'''
f = gzip.open('file.txt.gz', 'rb')
file_content = f.read()
f.close()
'''

content = "Lots of content here"
f = gzip.open('file.txt.gz', 'wb')
f.write(content,data)
f.close()

f_in = open('file.txt', 'rb')
f_out = gzip.open('file.txt.gz', 'wb')
f_out.writelines(f_in)
f_out.close()

