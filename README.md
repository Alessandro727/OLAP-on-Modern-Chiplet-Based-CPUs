# OLAP on Modern Chiplet-Based Processors
<a name="readme-top"></a>

Systematic experimental study and investigation of the efficiency of resource utilisation by distributed query engines. 

The code and scripts provided allow the replication of the experiments shown in the 'OLAP on Modern Chiplet-Based Processors' paper currently under review for VLDB2024.

## Getting Started

These instructions will give you the opportunity to replicate the performed experiments on your own local machines.
For each system evaluated, there is a brief guide inside each folder on how to install the additional requirements and run the test.

### Prerequisites

* Linux 16.04.
* Java 8 Update 151 or higher (8u151+), 64-bit. Both Oracle JDK and OpenJDK are supported.
* User with passwordless sudo access.
* There must be no password required for any machine in the cluster to access via SSH (including the local machine: e.g., user@mac01:~$ ssh 127.0.0.1) 

### Installing

To install general dependencies, run the following script:

    user@mac01:~$ ./install_requirements.sh

## Contact

Alessandro Fogli - a.fogli18@imperial.ac.uk
