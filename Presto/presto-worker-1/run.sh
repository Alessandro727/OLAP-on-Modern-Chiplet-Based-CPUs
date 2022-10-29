#!/bin/bash

numactl --physcpubind=16-31 --membind=0-3 bin/launcher run
