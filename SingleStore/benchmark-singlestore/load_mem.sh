mysqlimport --use-threads=64 -u root -h 127.0.0.1 -P 3306 -L tpch --fields-terminated-by="|" --lines-terminated-by="|\n" --server-public-key-path=.ssh/ssdb_key ./benchmark-singlestore/dbgen/*.tbl
