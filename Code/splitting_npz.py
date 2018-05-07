import numpy as np 
import pandas as pd

#The .npz Files are:
#kristina_longliner.measures.npz  kristina_trawl.measures.npz
#kristina_ps.measures.npz

#For longliner
kr_LL = np.load('kristina_longliner.measures.npz')
kr_LL = kr_LL['x']
kr_LL = pd.DataFrame(kr_LL)
#print(kr_LL)
kr_LL1, kr_LL2, kr_LL3, kr_LL4,\
 kr_LL5, kr_LL6, kr_LL7, kr_LL8,\
 kr_LL9, kr_LL10 = np.array_split(kr_LL,10)
kr_LL1.name = 'kr_LL1'
kr_LL2.name = 'kr_LL2'
kr_LL3.name = 'kr_LL3'
kr_LL4.name = 'kr_LL4'
kr_LL5.name = 'kr_LL5'
kr_LL6.name = 'kr_LL6'
kr_LL7.name = 'kr_LL7'
kr_LL8.name = 'kr_LL8'
kr_LL9.name = 'kr_LL9'
kr_LL10.name = 'kr_LL10'
list_kr_LL = [kr_LL1, kr_LL2, kr_LL3, kr_LL4,\
 kr_LL5, kr_LL6, kr_LL7, kr_LL8,\
 kr_LL9, kr_LL10]

for i in list_kr_LL :
	i.to_csv(i.name + '.csv.gz', compression='gzip')

#Now for Trawl
kr_tr = np.load('kristina_trawl.measures.npz')
kr_tr = kr_tr['x']
kr_tr = pd.DataFrame(kr_tr)
kr_tr1, kr_tr2, kr_tr3, kr_tr4,\
 kr_tr5, kr_tr6, kr_tr7, kr_tr8,\
 kr_tr9, kr_tr10 = np.array_split(kr_tr,10)
kr_tr1.name = 'kr_tr1'
kr_tr2.name = 'kr_tr2'
kr_tr3.name = 'kr_tr3'
kr_tr4.name = 'kr_tr4'
kr_tr5.name = 'kr_tr5'
kr_tr6.name = 'kr_tr6'
kr_tr7.name = 'kr_tr7'
kr_tr8.name = 'kr_tr8'
kr_tr9.name = 'kr_tr9'
kr_tr10.name = 'kr_tr10'
list_kr_tr = [kr_tr1, kr_tr2, kr_tr3, kr_tr4,\
 kr_tr5, kr_tr6, kr_tr7, kr_tr8,\
 kr_tr9, kr_tr10]

for i in list_kr_tr :
        i.to_csv(i.name + '.csv.gz', compression='gzip')

#Now for Purse Siene
kr_ps = np.load('kristina_ps.measures.npz')
kr_ps = kr_ps['x']
kr_ps = pd.DataFrame(kr_ps)
kr_ps1, kr_ps2, kr_ps3, kr_ps4,\
 kr_ps5, kr_ps6, kr_ps7, kr_ps8,\
 kr_ps9, kr_ps10 = np.array_split(kr_ps,10)
kr_ps1.name = 'kr_ps1'
kr_ps2.name = 'kr_ps2'
kr_ps3.name = 'kr_ps3'
kr_ps4.name = 'kr_ps4'
kr_ps5.name = 'kr_ps5'
kr_ps6.name = 'kr_ps6'
kr_ps7.name = 'kr_ps7'
kr_ps8.name = 'kr_ps8'
kr_ps9.name = 'kr_ps9'
kr_ps10.name = 'kr_ps10'

list_kr_ps = [kr_ps1, kr_ps2, kr_ps3, kr_ps4,\
 kr_ps5, kr_ps6, kr_ps7, kr_ps8,\
 kr_ps9, kr_ps10]

for i in list_kr_ps :
        i.to_csv(i.name + '.csv.gz', compression='gzip')

