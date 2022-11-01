## Greenplum

Greenplum Database (GPDB) is an advanced, fully featured, open
source data warehouse, based on PostgreSQL. It provides powerful and rapid analytics on
petabyte scale data volumes. Uniquely geared toward big data
analytics, Greenplum Database is powered by the world’s most advanced
cost-based query optimizer delivering high analytical query
performance on large data volumes.

### Installing

To install dependencies and Greenplum Database, run the following script:

    user@mac01:~$ ./install.sh

### Running Experiments

To run the TPC-H benchmark in WIC+MEM mode:

	user@mac01:~$ ./Greenplum_benchmark.sh -t -s 100 -p MEM -b TPC-H

You can also run the JCC-H benchmark:

	user@mac01:~$ ./Greenplum_benchmark.sh -t -s 100 -p MEM -b JCC-H

Or change the data placement policy (MEM, FT or INT):

	user@mac01:~$ ./Greenplum_benchmark.sh -t -s 100 -p INT -b TPC-H

### Data Placement

To perform the same experiment as in the paper and generate the plot:

	user@mac01:~$ cd data_placement
	user@mac01:~$ ./data_placement.sh

### Number of Worker Instances

To perform the same experiment as in the paper and generate the plot:

	user@mac01:~$ cd number_of_worker_instances
	user@mac01:~$ ./number_of_worker_instances.sh