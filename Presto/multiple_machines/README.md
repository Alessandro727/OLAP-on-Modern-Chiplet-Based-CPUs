# Presto on Multiple Machines

## Getting Started

These instructions will give you the opportunity to run the TPC-H benchmark with Presto on multiple machines. Also, this test only involves a single network card per machine. 

### Prerequisites

* There must be no password required for any machine in the cluster to access via SSH (including the local machine: e.g., user@mac01:~$ ssh 127.0.0.1)

### Running test

#### 1. Download the repository and install all requirements:

On each machine in the cluster:

    user@mac01:~$ git clone https://github.com/Alessandro727/ICDE2023_Towards_NUMA-Aware_Distributed_Query_Engines.git

	user@mac01:~$ cd ICDE2023_Towards_NUMA-Aware_Distributed_Query_Engines

	user@mac01:~$ ./install_requirements.sh
	

#### 2. Create mlist.txt

Choose a machine in the cluster that will act as the Coordinator-worker. On this machine, create the mlist.txt file and enter the IP address of each machine in the cluster.

Example with 3 machines:

	user@mac01:~$ cat Presto/multiple_machines/mlist.txt

	192.168.10.10
	192.168.10.11
	192.168.10.12


#### 3. Start the Worker machines in the cluster. 

On each Worker machine run: 

	user@mac01:~$ ./multiple_machines.sh [--coordinator-worker yes|no] [-n machine_number] [-a ip_address_coordinator_worker_machine:port_coordinator_worker_machine] [-l local_ip_address] [-m WIM|WIN] [-c cluster_size] -s scale-factor 

Example with 2 machines in a cluster of 3 machines:

	user@mac02:~$ ./multiple_machines.sh -coordinator-worker no -n 2 -a 192.168.10.10:8090 -l 192.168.10.11 -m WIM -c 4

	user@mac03:~$ ./multiple_machines.sh -coordinator-worker no -n 3 -a 192.168.10.10:8090 -l 192.168.10.12 -m WIM -c 4

#### 4. Start the Coordinator-worker machine.

On the Coordinator-worker machine:

	user@mac01:~$ ./multiple_machines.sh --coordinator-worker yes -n 1 -a 192.168.10.10:8090 -l 192.168.10.10 -m WIM -c 4


