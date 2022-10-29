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


# width of the bars
barWidth = 0.25

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

# The x position of bars
r1 = np.arange(len(speed_query_WIN))
r2 = [x + barWidth for x in r1]
r3 = [x + barWidth*2 for x in r1]
r4 = [x + barWidth*3 for x in r1]


plt.rc('text', usetex=True)

plt.figure(figsize=(7,4))

# Create blue bars
plt.bar(r1, speed_query_SPMWIN, width = barWidth, color = 'DodgerBlue', edgecolor = 'blue', label='Presto', fill=True, hatch='+++')

plt.bar(r2, speed_query_WIN, width = barWidth, color = 'LightBlue', edgecolor = 'blue', label='Presto', fill=True, hatch='///')


plt.axhline(1, color='black',ls='--')

plt.ylim(ymin=0)
# general layout
plt.xticks([r + barWidth for r in range(len(speed_query_WIN))], ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '16', '17', '18', '19', '20', '21', '22'])
plt.xticks(fontfamily='sans-serif',fontweight='medium',fontsize=15,rotation=0)
plt.yticks([0,1,2,3,4,5],['0','1','2','3','4','5'],fontfamily='sans-serif',fontweight='medium',fontsize=16)
plt.ylabel('Speedup',fontfamily='sans-serif',fontweight='medium',fontsize=16)

plt.savefig('Presto_thread_placement.pdf',bbox_inches='tight',dpi=6000,backend='pgf')


