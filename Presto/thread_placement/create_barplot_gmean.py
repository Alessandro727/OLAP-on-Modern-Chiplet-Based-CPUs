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



Presto_WIM_FT = []

    for t in [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22]:

        f=open(str(s)+"WIM+FT/Q"+str(i)+"_result.txt","r")
        lines=f.readlines()

        x=0
        query_times = 0
        for i in lines:
                if 'real\t' in i and x==3:
                        minutes = float(i.split('real\t')[1].split('m')[0])
                        seconds = float(i.split('real\t')[1].split('m')[1].split('s')[0])
                        time = minutes*60+seconds
                        query_times = query_times + time
                if 'real\t' in i and x!=3:
                        x=x+1

        Presto_WIM_FT.append(round(query_times/7.0,3))


Presto_WIN = []

    for t in [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22]:

        f=open(str(s)+"WIN/Q"+str(i)+"_result.txt","r")
        lines=f.readlines()

        x=0
        query_times = 0
        for i in lines:
                if 'real\t' in i and x==3:
                        minutes = float(i.split('real\t')[1].split('m')[0])
                        seconds = float(i.split('real\t')[1].split('m')[1].split('s')[0])
                        time = minutes*60+seconds
                        query_times = query_times + time
                if 'real\t' in i and x!=3:
                        x=x+1

        Presto_WIN.append(round(query_times/7.0,3))



Presto_SPMWIN = []

    for t in [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22]:

        f=open(str(s)+"SPMWIN/Q"+str(i)+"_result.txt","r")
        lines=f.readlines()

        x=0
        query_times = 0
        for i in lines:
                if 'real\t' in i and x==3:
                        minutes = float(i.split('real\t')[1].split('m')[0])
                        seconds = float(i.split('real\t')[1].split('m')[1].split('s')[0])
                        time = minutes*60+seconds
                        query_times = query_times + time
                if 'real\t' in i and x!=3:
                        x=x+1

        Presto_SPMWIN.append(round(query_times/7.0,3))


speed_query_WIN=[]

for i in range(len(Presto_WIM_FT)):
        speed_query_WIN.append(Presto_WIM_FT[i]/Presto_WIN[i])


speed_query_SPMWIN=[]

for i in range(len(Presto_WIM_FT)):
        speed_query_SPMWIN.append(Presto_WIM_FT[i]/Presto_SPMWIN[i])



plt.figure(figsize=(3,6.37))


WIN_gmean = [gmean(speed_query_WIN)]

pop=plt.bar([0.25],WIN_gmean,width=0.15, color = 'LightBlue', edgecolor = 'blue', label='WIN', fill=True, hatch='///')

SPMWIN_gmean = [gmean(speed_query_SPMWIN)]

pop=plt.bar([0],SPMWIN_gmean,width=0.15, color = 'DodgerBlue', edgecolor = 'blue', label='SPMWIN', fill=True, hatch='+++')



ticks=["SPMWIN", "WIN"]

plt.axhline(y=1, color='black', lw=2, ls='--')

plt.ylabel("Normalized speedup",fontfamily='sans-serif',fontweight='medium',fontsize=20)

plt.yticks([0,1,2,3,4],['0','1','2','3','4'],fontfamily='sans-serif',fontweight='medium',fontsize=20)

plt.tick_params(axis='x', which='both', bottom=False, top=False, labelbottom=False)

plt.gca().yaxis.set_label_position("right")
plt.gca().yaxis.tick_right()

plt.legend(prop={'size': 18}, loc='upper center')
plt.savefig('Presto_thread_placement_gmean.pdf',bbox_inches='tight',dpi=6000,backend='pgf')

