#!/bin/bash

cd ..
./SparkSQL_benchmark.sh -t -s 100 -m WIM -w 1 -p FT -b JCC-H -d skewed_workloads/WIM+FT/

./SparkSQL_benchmark.sh -t -s 100 -m WIN -w 1 -p MEM -b JCC-H -d skewed_workloads/WIN+MEM/

cd skewed_workloads

python3.6 create_barplot.py

python3.6 create_barplot_gmean.py
