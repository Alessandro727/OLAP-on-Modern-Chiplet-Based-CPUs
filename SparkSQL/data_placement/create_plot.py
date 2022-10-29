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


#SparkSQL
wim_ft = []
for t in ['01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22']:
    f=open('WIM_FT/TPCHQueriesExecTimes.txt',"r")
    lines=f.readlines()

    x=0
    query_times = 0
    for i in lines:
            if "Q"+t+"\t" in i and x==3:
                    seconds = float(i.split("Q"+t+"\t")[1])
                    query_times = query_times + seconds
            if "Q"+t+"\t" in i and x!=3:
                    x=x+1

    wim_ft.append(round(query_times/7.0,3))


wim_int = []
for t in ['01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22']:
    f=open('WIM_INT/TPCHQueriesExecTimes.txt',"r")
    lines=f.readlines()

    x=0
    query_times = 0
    for i in lines:
            if "Q"+t+"\t" in i and x==3:
                    seconds = float(i.split("Q"+t+"\t")[1])
                    query_times = query_times + seconds
            if "Q"+t+"\t" in i and x!=3:
                    x=x+1

    wim_int.append(round(query_times/7.0,3))


win_ft = []
for t in ['01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22']:
    f=open('WIN_FT/TPCHQueriesExecTimes.txt',"r")
    lines=f.readlines()

    x=0
    query_times = 0
    for i in lines:
            if "Q"+t+"\t" in i and x==3:
                    seconds = float(i.split("Q"+t+"\t")[1])
                    query_times = query_times + seconds
            if "Q"+t+"\t" in i and x!=3:
                    x=x+1

    win_ft.append(round(query_times/7.0,3))


win_mem = []
for t in ['01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22']:
    f=open('WIN_MEM/TPCHQueriesExecTimes.txt',"r")
    lines=f.readlines()

    x=0
    query_times = 0
    for i in lines:
            if "Q"+t+"\t" in i and x==3:
                    seconds = float(i.split("Q"+t+"\t")[1])
                    query_times = query_times + seconds
            if "Q"+t+"\t" in i and x!=3:
                    x=x+1

    win_mem.append(round(query_times/7.0,3))



win_int = []
for t in ['01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22']:
    f=open('WIN_INT/TPCHQueriesExecTimes.txt',"r")
    lines=f.readlines()

    x=0
    query_times = 0
    for i in lines:
            if "Q"+t+"\t" in i and x==3:
                    seconds = float(i.split("Q"+t+"\t")[1])
                    query_times = query_times + seconds
            if "Q"+t+"\t" in i and x!=3:
                    x=x+1

    win_int.append(round(query_times/7.0,3))


wic_ft = []
for t in ['01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22']:
    f=open('WIC_FT/TPCHQueriesExecTimes.txt',"r")
    lines=f.readlines()

    x=0
    query_times = 0
    for i in lines:
            if "Q"+t+"\t" in i and x==3:
                    seconds = float(i.split("Q"+t+"\t")[1])
                    query_times = query_times + seconds
            if "Q"+t+"\t" in i and x!=3:
                    x=x+1

    wic_ft.append(round(query_times/7.0,3))


wic_mem = []
for t in ['01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22']:
    f=open('WIC_MEM/TPCHQueriesExecTimes.txt',"r")
    lines=f.readlines()

    x=0
    query_times = 0
    for i in lines:
            if "Q"+t+"\t" in i and x==3:
                    seconds = float(i.split("Q"+t+"\t")[1])
                    query_times = query_times + seconds
            if "Q"+t+"\t" in i and x!=3:
                    x=x+1

    wic_mem.append(round(query_times/7.0,3))


wic_int = []
for t in ['01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22']:
    f=open('WIC_INT/TPCHQueriesExecTimes.txt',"r")
    lines=f.readlines()

    x=0
    query_times = 0
    for i in lines:
            if "Q"+t+"\t" in i and x==3:
                    seconds = float(i.split("Q"+t+"\t")[1])
                    query_times = query_times + seconds
            if "Q"+t+"\t" in i and x!=3:
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


SparkSQL = [wim_int_gmean, win_ft_gmean, win_int_gmean, win_mem_gmean, wic_ft_gmean, wic_int_gmean, wic_mem_gmean]


plt.figure(figsize=(3.5,2))


pop=plt.bar([0,0.4,0.8,1.2,1.6,2,2.4], SparkSQL, width=0.2, color = 'tomato', edgecolor = 'red', fill=True, hatch='+')

ticks=["WIM+INT", "WIN+FT", "WIN+INT", "WIN+MEM", "WIC+FT", "WIC+INT", "WIC+MEM"]

plt.axhline(y=1, color='black', lw=2)

plt.ylabel("Normalized speedup",fontsize=15,fontfamily='sans-serif',fontweight='medium')

plt.title('Speedup over WIM+FT',fontsize=15,fontfamily='sans-serif',fontweight='medium')
plt.xticks([0,0.4,0.8,1.2,1.6,2,2.4],ticks,fontfamily='sans-serif',fontweight='medium',fontsize=15,rotation='vertical')
plt.yticks([0,0.5,1,1.5,2,2.5],['0.0','0.5','1.0','1.5','2.0','2.5'],fontfamily='sans-serif',fontweight='medium',fontsize=15)


plt.savefig('SparkSQL_data_placement.pdf',bbox_inches='tight',dpi=6000,backend='pgf')


