SELECT
  o_year,
  sum(CASE
      WHEN nation = 'BRAZIL'
        THEN volume
      ELSE 0
      END) / sum(volume) AS mkt_share
FROM (
       SELECT
         extract(YEAR FROM orderdate)     AS o_year,
         extendedprice * (1 - discount) AS volume,
         n2.name                          AS nation
       FROM
         part,
         supplier,
         lineitem,
         orders,
         customer,
         nation n1,
         nation n2,
         region
       WHERE
         part.partkey = lineitem.partkey
         AND supplier.suppkey = lineitem.suppkey
         AND lineitem.orderkey = orders.orderkey
         AND orders.custkey = customer.custkey
         AND customer.nationkey = n1.nationkey
         AND n1.regionkey = region.regionkey
         AND region.name = 'AMERICA'
         AND supplier.nationkey = n2.nationkey
         AND orderdate BETWEEN DATE '1995-01-01' AND DATE '1996-12-31'
         AND type = 'ECONOMY ANODIZED STEEL'
     ) AS all_nations
GROUP BY
  o_year
ORDER BY
  o_year;
