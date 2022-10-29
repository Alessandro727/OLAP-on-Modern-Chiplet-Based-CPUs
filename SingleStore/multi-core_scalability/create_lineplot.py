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

SingleStore_results = []

for s in x_values:
    total_time = 0
    for t in [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22]:

        f=open(str(s)+"_cores/q"+str(t)+"_result.txt","r")
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

        total_time=total_time+(round(query_times/7.0,3))

    SingleStore_results.append(total_time)



normalized_res=[]
for s in range(len(SingleStore_results)):
        normalized_res.append(round(SingleStore_results[0]/SingleStore_results[s],3))


df1=pd.DataFrame({'x': x_values, 'y': normalized_res, 'y1': x_values})

font = {'family': 'sans-serif',
        'color':  'black',
        'weight': 'medium',
        'size': 15,
        }


plt.figure(figsize=(7,4))

plt.plot( 'x', 'y', 'X-', data=df1, color='fuchsia',linewidth=2, label='SingleStore')


plt.xticks(numa_lines,numa_lines_str,fontfamily='sans-serif',fontweight='medium',fontsize=15,color='black')
plt.yticks(y_values,y_values_str,fontfamily='sans-serif',fontweight='medium',fontsize=15,color='black')

for h in y_values:
	if h != 0:
		plt.axvline(h, color='gray')


plt.xlabel("Cores",fontfamily='sans-serif',fontweight='medium',fontsize=15)
plt.ylabel("Normalized Speedup",fontfamily='sans-serif',fontweight='medium',fontsize=15)

plt.legend(prop={'size': 18}) 
plt.savefig('SingleStore_cores_scalability.pdf',bbox_inches='tight',dpi=6000, backend='pgf')




