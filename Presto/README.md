## Presto

Presto is a distributed SQL query engine designed to query large data sets distributed over one or more heterogeneous data sources.

### Running Experiments

To run the TPC-H benchmark in WIN+MEM mode:

	user@mac01:~$ ./Presto_benchmark.sh -t -s 100 -m WIN -p MEM

You can also change the deployment design (WIN, WIM or WIC):

	user@mac01:~$ ./Presto_benchmark.sh -t -s 100 -m WIM -p FT

Or change the data placement policy (MEM, FT or INT):

	user@mac01:~$ ./Presto_benchmark.sh -t -s 100 -m WIN -p INT

For more options run:

	user@mac01:~$ ./Presto_benchmark.sh -h

P.S.: Set the Scale Factor so that it is no more than half of the total amount of RAM available.

### Data Placement Test

To perform the same experiment as in the paper and generate the plot:

	user@mac01:~$ cd data_placement
	user@mac01:~$ ./data_placement.sh

### Multi-core Scalability Test

To perform the same experiment as in the paper and generate the plot:

	user@mac01:~$ cd multi-core_scalability
	user@mac01:~$ ./multi-core_scalability.sh

### Number of Worker Instances Test

To perform the same experiment as in the paper and generate the plot:

	user@mac01:~$ cd number_of_worker_instances
	user@mac01:~$ ./number_of_worker_instances.sh

### Thread Placement Test

To perform the same experiment as in the paper and generate the plot:

	user@mac01:~$ cd thread_placement
	user@mac01:~$ ./thread_placement.sh



