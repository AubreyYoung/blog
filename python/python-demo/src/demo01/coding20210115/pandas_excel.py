
import pandas as pd

frame = pd.read_excel("data2.xlsx")
print(frame)

print("###############################################################")

import numpy as np

frame = pd.DataFrame(np.random.random((4,4)),
                     index=['exp1','exp2','exp3','exp4'],
                     columns=['jan2015','Fab2015','Mar2015','Apr2005'])
print(frame)
frame.to_excel("data2.xlsx")