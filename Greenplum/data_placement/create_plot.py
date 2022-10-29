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

#Greenplum
wic_ft = []
for i in range(1,23):
    file = open('WIC_FT/q'+str(i)+'_result.txt', 'r')
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

    wic_ft.append(round(query_times/7.0,3))


wic_mem = []
for i in range(1,23):
    file = open('WIC_MEM/q'+str(i)+'_result.txt', 'r')
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

    wic_mem.append(round(query_times/7.0,3))


wic_int = []
for i in range(1,23):
    file = open('WIC_INT/q'+str(i)+'_result.txt', 'r')
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

    wic_int.append(round(query_times/7.0,3))


wic_int_speed = []

for i in range(len(wic_ft)):
        wic_int_speed.append(wic_ft[i]/wic_int[i])

wic_mem_speed = []

for k in range(len(wic_ft)):
        wic_mem_speed.append(wic_ft[k]/wic_mem[k])


wic_int_gmean = gmean(wic_int_speed)


wic_mem_gmean = gmean(wic_mem_speed)


Greenplum = [wic_int_gmean, wic_mem_gmean]


plt.figure(figsize=(3.5,2))


pop=plt.bar([0,0.4], Greenplum, width=0.2, color = 'LightGreen', edgecolor = 'green', label='Greenplum', fill=True, hatch='xxx')

ticks=["WIC+INT", "WIC+MEM"]

plt.axhline(y=1, color='black', lw=2)

plt.ylabel("Normalized speedup",fontfamily='sans-serif',fontweight='medium',fontsize=15)

plt.xticks([0,0.4],ticks,fontfamily='sans-serif',fontweight='medium',fontsize=15,rotation='vertical')
plt.yticks([0,0.5,1,1.5,2,2.5],['0.0','0.5','1.0','1.5','2.0','2.5'],fontfamily='sans-serif',fontweight='medium',fontsize=15)

plt.title("Speedup over WIC+FT",fontfamily='sans-serif',fontweight='medium',fontsize=15)

plt.savefig('Greenplum_data_placement.pdf',bbox_inches='tight',dpi=6000,backend='pgf')


