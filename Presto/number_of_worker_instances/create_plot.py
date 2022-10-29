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


noi1m = []
for i in range(1,23):
    file = open('1_workers/Q'+str(i)+'_result.txt', 'r')
    lines=file.readlines()
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

    noi1m.append(round(query_times/7.0,3))


values=sys.argv[1].split(' ')

Presto = [1]

for x in values[1:]:
    noiWm = []
    for i in range(1,23):
        file = open(str(x)+'_workers/Q'+str(i)+'_result.txt', 'r')
        lines=file.readlines()
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

        noiWm.append(round(query_times/7.0,3))



    speed_noiW_m=[]

    for i in range(len(noi1m)):
            speed_noiW_m.append(noi1m[i]/noiWm[i])

    noiW_m_gmean = gmean(speed_noiW_m)

    Presto.append(noiW_m_gmean)


plt.rc('text', usetex=True)

plt.figure(figsize=(3.5,2))

c=1
size=[]
for x in values:
    size.append(c)
    c+=1

plt.plot([1,2,3,4,5,6,7], Presto, '.-', color='DeepSkyBlue', markersize=10, label='Presto')


plt.ylim(ymin=0)
# general layout
plt.xticks(size, values)
plt.xticks(fontfamily='sans-serif',fontweight='medium',fontsize=16,rotation=0)
plt.xlabel('Number of Worker Instances',fontfamily='sans-serif',fontweight='medium',fontsize=16)
plt.yticks([0,1,2,3,4],['0','1','2','3','4'],fontfamily='sans-serif',fontweight='medium',fontsize=16)
plt.ylabel('Speedup',fontfamily='sans-serif',fontweight='medium',fontsize=16)


plt.savefig('Presto_number_of_instances_speedup.pdf',bbox_inches='tight',dpi=6000,backend='pgf')

