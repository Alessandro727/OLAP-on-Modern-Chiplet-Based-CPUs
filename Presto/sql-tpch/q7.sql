SELECT
  supp_nation,
  cust_nation,
  l_year,
  sum(volume) AS revenue
FROM (
       SELECT
         n1.name                          AS supp_nation,
         n2.name                          AS cust_nation,
         extract(YEAR FROM shipdate)      AS l_year,
         extendedprice * (1 - discount) AS volume
       FROM
         supplier,
         lineitem,
         orders,
         customer,
         nation n1,
         nation n2
       WHERE
         supplier.suppkey = lineitem.suppkey
         AND orders.orderkey = lineitem.orderkey
         AND customer.custkey = orders.custkey
         AND supplier.nationkey = n1.nationkey
         AND customer.nationkey = n2.nationkey
         AND (
           (n1.name = 'FRANCE' AND n2.name = 'GERMANY')
           OR (n1.name = 'GERMANY' AND n2.name = 'FRANCE')
         )
         AND shipdate BETWEEN DATE '1995-01-01' AND DATE '1996-12-31'
     ) AS shipping
GROUP BY
  supp_nation,
  cust_nation,
  l_year
ORDER BY
  supp_nation,
  cust_nation,
  l_year;
