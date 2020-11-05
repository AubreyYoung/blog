# -*- coding: utf-8 -*-
"""
-------------------------------------------------
@version: 0.1
@Author: yangguang02
@license: Apache Licence 
@contact: yangguang1900@163.com
@site: https://github.com/AubreyYoung/blog
@software: PyCharm
@file: CreateImage
@ProjectName: python-demo
@Date: 2020/11/5 9:33
-------------------------------------------------
"""

from PIL import Image

# 打开一个jpg图像文件，注意是当前路径:
im = Image.open('picture1.png')
# 获得图像尺寸:
w, h = im.size
print('Original image size: %sx%s' % (w, h))
# 缩放到50%:
im.thumbnail((w//2, h//2))
print('Resize image to: %sx%s' % (w//2, h//2))
# 把缩放后的图像用jpeg格式保存:
im.save('thumbnail.jpg', 'jpeg')


from PIL import ImageFilter

# 打开一个jpg图像文件，注意是当前路径:
im = Image.open('picture1.png')
# 应用模糊滤镜:
im2 = im.filter(ImageFilter.BLUR)
im2.save('blur.jpg', 'jpeg')