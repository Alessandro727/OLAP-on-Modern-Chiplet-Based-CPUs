import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import sys
import matplotlib

matplotlib.use("pgf")
matplotlib.rcParams.update({
    "pgf.texsystem": "pdflatex",
    'font.family': 'sans-serif',
    'font.style': 'normal',
    'font.weight': 'medium',
    'text.usetex': True,
    'pgf.rcfonts': False,
})


SparkSQL_results = []

values=sys.argv[1].split(' ')

max_cores=values[len(values)-1]

x_values=[]
numa_lines=[]
numa_lines_str=[]

for i in sys.argv[1].split(' '):
        x_values.append(int(i))

y_values=[]
y_values_str=[]


for v in range(int(max_cores)+1):
        if v%int(sys.argv[2])==0:
                numa_lines.append(int(v))
                numa_lines_str.append(str(v))
        if v%10==0:
                y_values.append(int(v))
                y_values_str.append(str(v))


for s in ["1",str(max_cores)]:
    total_time=0
    for t in ['01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22']:
        f=open(str(s)+"_cores/TPCHQueriesExecTimes.txt","r")
        lines=f.readlines()

        x=0
        query_times = 0
        for i in lines:
            if "Q"+t+"\t" in i and x==3:
                    seconds = float(i.split("Q"+t+"\t")[1])
                    query_times = query_times + seconds
            if "Q"+t+"\t" in i and x!=3:
                    x=x+1

        total_time=total_time+(round(query_times/7.0,3))

    SparkSQL_results.append(total_time)



total_time = 0
for t in ['01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22']:
        f=open("WIN+MEM/TPCHQueriesExecTimes.txt","r")
        lines=f.readlines()

        x=0
        query_times = 0
        for i in lines:
            if "Q"+t+"\t" in i and x==3:
                    seconds = float(i.split("Q"+t+"\t")[1])
                    query_times = query_times + seconds
            if "Q"+t+"\t" in i and x!=3:
                    x=x+1

        total_time=total_time+(round(query_times/7.0,3))

SparkSQL_results.append(total_time)


plt.figure(figsize=(3,6.35))

SparkSQL_WIM_FT = SparkSQL_results[0]/SparkSQL_results[1]

SparkSQL_WIN_MEM = SparkSQL_results[0]/SparkSQL_results[2]


plt.bar([0.2,1.0],[SparkSQL_WIM_FT,SparkSQL_WIN_MEM], width=0.2, color = 'tomato', edgecolor = 'red', label='SparkSQL', fill=True, hatch='+')


ticks=["WIM+FT", "WIN+MEM"]


plt.ylabel("Normalized speedup",fontfamily='sans-serif',fontweight='medium',fontsize=20)

plt.xticks([0.2,1.0],ticks,fontfamily='sans-serif',fontweight='medium',fontsize=20,rotation=25)

#plt.yticks([0,10,20,30,40,50,60],['0','10','20','30','40','50','60'],fontfamily='sans-serif',fontweight='medium',fontsize=20)
plt.yticks(y_values,y_values_str,fontfamily='sans-serif',fontweight='medium',fontsize=20)


plt.gca().yaxis.set_label_position("right")
plt.gca().yaxis.tick_right()


plt.savefig('SparkSQL_multicore_speedup_barplot.pdf',bbox_inches='tight',dpi=6000,backend='pgf')

