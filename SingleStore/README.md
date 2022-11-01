## SingleStore

SingleStore is a modern relational database for cloud and on-premises delivering immediate insights for modern applications and analytical systems.

### Installing

To install dependencies and the SingleStore Database, run the following script:

    user@mac01:~$ ./install.sh

### Running Experiments

To run the TPC-H benchmark in WIN+MEM mode:

	user@mac01:~$ ./SingleStore_benchmark.sh -t -s 100 -m WIN -p MEM

You can also change the deployment design (WIN, WIM or WIC):

	user@mac01:~$ ./SingleStore_benchmark.sh -t -s 100 -m WIM -p FT

Or change the data placement policy (MEM, FT or INT):

	user@mac01:~$ ./SingleStore_benchmark.sh -t -s 100 -m WIN -p INT 

Or run the JCC-H benchmark:

	user@mac01:~$ ./SingleStore_benchmark.sh -t -s 100 -m WIN -p MEM -b JCC-H

For more options run:

	user@mac01:~$ ./SingleStore_benchmark.sh -h

P.S.: Set the Scale Factor so that it is no more than a quarter of the total amount of RAM available.

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



