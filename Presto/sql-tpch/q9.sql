SELECT
  nation,
  o_year,
  sum(amount) AS sum_profit
FROM (
       SELECT
         nation.name                                                          AS nation,
         extract(YEAR FROM orderdate)                                  AS o_year,
         extendedprice * (1 - discount) - supplycost * quantity AS amount
       FROM
         part,
         supplier,
         lineitem,
         partsupp,
         orders,
         nation
       WHERE
         supplier.suppkey = lineitem.suppkey
         AND partsupp.suppkey = lineitem.suppkey
         AND partsupp.partkey = lineitem.partkey
         AND part.partkey = lineitem.partkey
         AND orders.orderkey = lineitem.orderkey
         AND supplier.nationkey = nation.nationkey
         AND part.name LIKE '%green%'
     ) AS profit
GROUP BY
  nation,
  o_year
ORDER BY
  nation,
  o_year DESC;
