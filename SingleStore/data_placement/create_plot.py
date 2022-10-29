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


#SingleStore
wim_ft = []
for i in range(1,23):
    file = open('WIM_FT/q'+str(i)+'_result.txt', 'r')
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

    wim_ft.append(round(query_times/7.0,3))


wim_int = []
for i in range(1,23):
    file = open('WIM_INT/q'+str(i)+'_result.txt', 'r')
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

    wim_int.append(round(query_times/7.0,3))


win_ft = []
for i in range(1,23):
    file = open('WIN_FT/q'+str(i)+'_result.txt', 'r')
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

    win_ft.append(round(query_times/7.0,3))


win_mem = []
for i in range(1,23):
    file = open('WIN_MEM/q'+str(i)+'_result.txt', 'r')
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

    win_mem.append(round(query_times/7.0,3))



win_int = []
for i in range(1,23):
    file = open('WIN_INT/q'+str(i)+'_result.txt', 'r')
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

    win_int.append(round(query_times/7.0,3))


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


wim_int_speed = []

for i in range(len(wim_ft)):
        wim_int_speed.append(wim_ft[i]/wim_int[i])

win_ft_speed = []

for k in range(len(wim_ft)):
        win_ft_speed.append(wim_ft[k]/win_ft[k])

win_int_speed = []

for i in range(len(wim_ft)):
        win_int_speed.append(wim_ft[i]/win_int[i])

win_mem_speed = []

for k in range(len(wim_ft)):
        win_mem_speed.append(wim_ft[k]/win_mem[k])

wic_ft_speed = []

for k in range(len(wim_ft)):
        wic_ft_speed.append(wim_ft[k]/wic_ft[k])

wic_int_speed = []

for i in range(len(wim_ft)):
        wic_int_speed.append(wim_ft[i]/wic_int[i])

wic_mem_speed = []

for k in range(len(wim_ft)):
        wic_mem_speed.append(wim_ft[k]/wic_mem[k])



wim_int_gmean = gmean(wim_int_speed)


win_ft_gmean = gmean(win_ft_speed)


win_int_gmean = gmean(win_int_speed)


win_mem_gmean = gmean(win_mem_speed)


wic_ft_gmean = gmean(wic_ft_speed)


wic_int_gmean = gmean(wic_int_speed)


wic_mem_gmean = gmean(wic_mem_speed)


SingleStore = [wim_int_gmean, win_ft_gmean, win_int_gmean, win_mem_gmean, wic_ft_gmean, wic_int_gmean, wic_mem_gmean]


plt.figure(figsize=(3.5,2))


pop=plt.bar([0,0.4,0.8,1.2,1.6,2,2.4], SingleStore, width=0.2, color = 'violet', edgecolor = 'purple', label='SingleStore', fill=True, hatch='---')

ticks=["WIM+INT", "WIN+FT", "WIN+INT", "WIN+MEM", "WIC+FT", "WIC+INT", "WIC+MEM"]

plt.axhline(y=1, color='black', lw=2)

plt.ylabel("Normalized speedup",fontsize=15,fontfamily='sans-serif',fontweight='medium')

plt.title('Speedup over WIM+FT',fontsize=15,fontfamily='sans-serif',fontweight='medium')
plt.xticks([0,0.4,0.8,1.2,1.6,2,2.4],ticks,fontfamily='sans-serif',fontweight='medium',fontsize=15,rotation='vertical')
plt.yticks([0,0.5,1,1.5,2,2.5],['0.0','0.5','1.0','1.5','2.0','2.5'],fontfamily='sans-serif',fontweight='medium',fontsize=15)


plt.savefig('Singlestore_data_placement.pdf',bbox_inches='tight',dpi=6000,backend='pgf')


