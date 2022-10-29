#!/bin/bash

NUMACTL_OUT=$(numactl --hardware)

TEMP=${NUMACTL_OUT##available: }
NUM_NUMA_NODES=${TEMP::1}

if [[ $NUM_NUMA_NODES -le 1 ]]; then
	echo 'You need a multisocket system to run this benchmark:'
	echo 'Number of NUMA nodes: 1'
	exit 1
fi

NUMACORES=$(grep ^cpu\\scores /proc/cpuinfo | uniq |  awk '{print $4}')

TOTAL_CORES=$(($NUMACORES*$NUM_NUMA_NODES))

cores="1 "
c=1
p=1

while((p <= $TOTAL_CORES))
do
    for b in {1..$TOTAL_CORES}
    do
        while((c <= b))
        do
          p=$((p * 2))
          c=$((c + 1))
        done
        if(( p > $TOTAL_CORES)); then
            break
        fi
        cores=$cores" $p"
    done
done


for i in $cores
do
	echo ""
	echo ""
	echo "Number of running instances: $i"
	echo ""
	echo ""
	CORES=$((${TOTAL_CORES}/${i}))
	cd ../
	./Presto_benchmark.sh -t -s 100 -m WIM -w $i -c $CORES -d number_of_worker_instances/${i}_workers/
	cd number_of_worker_instances/
done

python3.6 create_plot.py $cores
