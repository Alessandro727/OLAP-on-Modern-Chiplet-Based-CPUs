#!/bin/bash

cd ..

./Presto_benchmark.sh -t -s 100 -m WIN -d thread_placement/WIN/

./Presto_benchmark.sh -t -s 100 -m WIM -p FT -d thread_placement/WIM+FT/

./Presto_benchmark.sh -t -s 100 -m SPMWIN -d thread_placement/SPMWIN/

cd thread_placement/

python3.6 create_barplot.py

python3.6 create_barplot_gmean.py

