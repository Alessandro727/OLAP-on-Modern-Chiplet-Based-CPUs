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

policies=['FT', 'INT']

for i in policies:
do
	echo ""
	echo ""
	echo "Testing WIM mode with $i policy..."
	echo ""
	echo ""
	cd ../
	./SingleStore_benchmark.sh -t -s 100 -m WIM -p $i -d data_placement/WIM_${i}/
	cd data_placement/
done

policies=['FT', 'MEM', 'INT']

for i in policies:
do
        echo ""
        echo ""
        echo "Testing WIN mode with $i policy..."
        echo ""
        echo ""
        cd ../
        ./SingleStore_benchmark.sh -t -s 100 -m WIN -p $i -d data_placement/WIN_${i}/
        cd data_placement/
done

for i in policies:
do
        echo ""
        echo ""
        echo "Testing WIC mode with $i policy..."
        echo ""
        echo ""
        cd ../
        ./SingleStore_benchmark.sh -t -s 100 -m WIC -p $i -d data_placement/WIC_${i}/
        cd data_placement/
done

python3.6 create_plot.py
