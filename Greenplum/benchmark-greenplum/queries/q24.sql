select count(*) from lineitem, partsupp where l_partkey = ps_partkey and l_suppkey = ps_suppkey;
