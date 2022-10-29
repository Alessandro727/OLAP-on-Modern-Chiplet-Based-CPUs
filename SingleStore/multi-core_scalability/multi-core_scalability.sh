#!/bin/bash

NUMACTL_OUT=$(numactl --hardware)

TEMP=${NUMACTL_OUT##available: }
NUM_NUMA_NODES=${TEMP::1}

if [[ $NUM_NUMA_NODES -le 1 ]]; then
	error 'You need a multisocket system to run this benchmark:'
	error 'Number of NUMA nodes: 1'
	exit 1
fi

NUMACORES=$(grep ^cpu\\scores /proc/cpuinfo | uniq |  awk '{print $4}')

TOTAL_CORES=$(($NUMACORES*$NUM_NUMA_NODES))

cores="1 2"

for ((v = 1; v <= $TOTAL_CORES; v += 1)) ; do
	if [[ $(($v%4)) == 0 ]]; then
		cores=$cores" $v"
	fi
done

for i in $cores
do
        echo ""
        echo ""
        echo "Number of cores: $i"
        echo ""
        echo ""
        cd ..
        ./SingleStore_benchmark.sh -t -s 100 -m WIM -w 1 -c $i -d multi-core_scalability/${i}_cores/
        cd multi-core_scalability/
done

cd ..
./SingleStore_benchmark.sh -t -s 100 -m WIN -p MEM -d multi-core_scalability/WIN+MEM/
cd multi-core_scalability/

python3.6 create_lineplot.py $cores $NUMACORES

python3.6 create_barplot.py $cores $NUMACORES


