import numpy as np
import matplotlib.pyplot as plt
from scipy.stats.mstats import gmean
import matplotlib

matplotlib.use("pgf")
matplotlib.rcParams.update({
    "pgf.texsystem": "pdflatex",
    'font.family': 'serif',
    'text.usetex': True,
    'pgf.rcfonts': False,
})


SparkSQL_WIM_FT = []
for t in ['01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22']:
    f=open('WIM+FT/TPCHQueriesExecTimes.txt',"r")
    lines=f.readlines()

    x=0
    query_times = 0
    for i in lines:
            if "Q"+t+"\t" in i and x==3:
                    seconds = float(i.split("Q"+t+"\t")[1])
                    query_times = query_times + seconds
            if "Q"+t+"\t" in i and x!=3:
                    x=x+1

    SparkSQL_WIM_FT.append(round(query_times/7.0,3))




SparkSQL_WIN_MEM = []

for t in ['01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22']:
    f=open('WIN+MEM/TPCHQueriesExecTimes.txt',"r")
    lines=f.readlines()

    x=0
    query_times = 0
    for i in lines:
            if "Q"+t+"\t" in i and x==3:
                    seconds = float(i.split("Q"+t+"\t")[1])
                    query_times = query_times + seconds
            if "Q"+t+"\t" in i and x!=3:
                    x=x+1

    SparkSQL_WIN_MEM.append(round(query_times/7.0,3))

speed_query_WIN=[]

for i in range(len(SparkSQL_WIM_FT)):
        speed_query_WIN.append(SparkSQL_WIM_FT[i]/SparkSQL_WIN_MEM[i])


speed_query_gmean=[gmean(speed_query_WIN)]


pop=plt.bar([0.125], speed_query_gmean, width=0.15, color = 'tomato', edgecolor = 'red', label='SparkSQL', fill=True, hatch='+')


plt.figure(figsize=(3,6.4))

plt.axhline(y=1, color='black', lw=2, ls='--')

plt.ylabel("Normalized speedup",fontfamily='sans-serif',fontweight='medium',fontsize=20)

plt.yticks([0,1,2,3,4],['0','1','2','3','4'],fontfamily='sans-serif',fontweight='medium',fontsize=20)

plt.tick_params(axis='x', which='both', bottom=False, top=False, labelbottom=False) 

plt.gca().yaxis.set_label_position("right")
plt.gca().yaxis.tick_right()

plt.legend(prop={'size': 20}, loc='upper center')
plt.savefig('SparkSQL_skewed_workloads_gmean.pdf',bbox_inches='tight',dpi=6000,backend='pgf')


