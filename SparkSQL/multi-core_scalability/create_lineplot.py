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


SparkSQL_results = []

for s in x_values:
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



normalized_res=[]
for s in range(len(SparkSQL_results)):
        normalized_res.append(round(SparkSQL_results[0]/SparkSQL_results[s],3))


#df1=pd.DataFrame({'x': [1,2,4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64], 'y': normalized_res, 'y1': [1,2,4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64]})
df1=pd.DataFrame({'x': x_values, 'y': normalized_res, 'y1': x_values})

font = {'family': 'sans-serif',
        'color':  'black',
        'weight': 'medium',
        'size': 15,
        }


plt.figure(figsize=(7,4))

plt.plot( 'x', 'y', '^-', data=df1, color='tomato',linewidth=2, label='SparkSQL')


#plt.xticks([0,16,32,48,64],['0','16','32','48','64'],fontfamily='sans-serif',fontweight='medium',fontsize=15,color='black')
plt.xticks(numa_lines,numa_lines_str,fontfamily='sans-serif',fontweight='medium',fontsize=15,color='black')
#plt.yticks([0,10,20,30,40,50,60],['0','10','20','30','40','50','60'],fontfamily='sans-serif',fontweight='medium',fontsize=15,color='black')
plt.yticks(y_values,y_values_str,fontfamily='sans-serif',fontweight='medium',fontsize=15,color='black')

for h in numa_lines_str:
	if h!=0:
		plt.axvline(h, color='gray')

#plt.axvline(16, color='gray')
#plt.axvline(32, color='gray')
#plt.axvline(48, color='gray')
#plt.axvline(64, color='gray')


plt.xlabel("Cores",fontfamily='sans-serif',fontweight='medium',fontsize=15)
plt.ylabel("Normalized Speedup",fontfamily='sans-serif',fontweight='medium',fontsize=15)

plt.legend(prop={'size': 18}) 
plt.savefig('SparkSQL_cores_scalability.pdf',bbox_inches='tight',dpi=6000, backend='pgf')




