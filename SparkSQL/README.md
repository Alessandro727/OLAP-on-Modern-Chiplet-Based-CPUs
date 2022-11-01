## SparkSQL

Spark SQL is a Spark module for structured data processing. It provides a programming abstraction called DataFrames and can also act as a distributed SQL query engine. 

### Running Experiments

To run the TPC-H benchmark in WIN+MEM mode:

	user@mac01:~$ ./SparkSQL_benchmark.sh -t -s 100 -m WIN -p MEM

You can also change the deployment design (WIN, WIM or WIC):

	user@mac01:~$ ./SparkSQL_benchmark.sh -t -s 100 -m WIM -p FT

Or change the data placement policy (MEM, FT or INT):

	user@mac01:~$ ./SparkSQL_benchmark.sh -t -s 100 -m WIN -p INT

Or run the JCC-H benchmark:

	user@mac01:~$ ./SparkSQL_benchmark.sh -t -s 100 -m WIN -p MEM -b JCC-H

For more options run:

	user@mac01:~$ ./SparkSQL_benchmark.sh -h

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

### Skewed Workloads Test

To perform the same experiment as in the paper and generate the plot:

	user@mac01:~$ cd skewed_workloads
	user@mac01:~$ ./skewed_workloads.sh



