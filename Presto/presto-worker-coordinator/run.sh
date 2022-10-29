#!/bin/bash

numactl --physcpubind=0-15 --membind=0-3 bin/launcher run
