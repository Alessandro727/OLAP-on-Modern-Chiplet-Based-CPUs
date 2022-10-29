import numpy as np
import matplotlib.pyplot as plt
from scipy.stats.mstats import gmean
import matplotlib
import sys

matplotlib.use("pgf")
matplotlib.rcParams.update({
    "pgf.texsystem": "pdflatex",
    'font.family': 'serif',
    'text.usetex': True,
    'pgf.rcfonts': False,
})


#SparkSQL
noi1m = []
for t in ['01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22']:
    f=open('1_workers/TPCHQueriesExecTimes.txt',"r")
    lines=f.readlines()

    x=0
    query_times = 0
    for i in lines:
            if "Q"+t+"\t" in i and x==3:
                    seconds = float(i.split("Q"+t+"\t")[1])
                    query_times = query_times + seconds
            if "Q"+t+"\t" in i and x!=3:
                    x=x+1

    noi1m.append(round(query_times/7.0,3))


values=sys.argv[1].split(' ')

SparkSQL = [1]

for x in values[1:]:
    noiWm = []
    for t in ['01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22']:
        f=open(str(x)+'_workers/TPCHQueriesExecTimes.txt',"r")
        lines=f.readlines()

        x=0
        query_times = 0
        for i in lines:
                if "Q"+t+"\t" in i and x==3:
                        seconds = float(i.split("Q"+t+"\t")[1])
                        query_times = query_times + seconds
                if "Q"+t+"\t" in i and x!=3:
                        x=x+1

        noiWm.append(round(query_times/7.0,3))



    speed_noiW_m=[]

    for i in range(len(noi1m)):
            speed_noiW_m.append(noi1m[i]/noiWm[i])

    noiW_m_gmean = gmean(speed_noiW_m)

    SparkSQL.append(noiW_m_gmean)


plt.rc('text', usetex=True)

plt.figure(figsize=(3.5,2))

c=1
size=[]
for x in values:
    size.append(c)
    c+=1

plt.plot([1,2,3,4,5,6,7], SparkSQL, '^-', color='tomato', markersize=10, label= 'SparkSQL')


plt.ylim(ymin=0)
# general layout
plt.xticks(size, values)
plt.xticks(fontfamily='sans-serif',fontweight='medium',fontsize=16,rotation=0)
plt.xlabel('Number of Worker Instances',fontfamily='sans-serif',fontweight='medium',fontsize=16)
plt.yticks([0,1,2,3,4],['0','1','2','3','4'],fontfamily='sans-serif',fontweight='medium',fontsize=16)
plt.ylabel('Speedup',fontfamily='sans-serif',fontweight='medium',fontsize=16)


plt.savefig('SparkSQL_number_of_instances_speedup.pdf',bbox_inches='tight',dpi=6000,backend='pgf')

