EXPLAIN ANALYZE SELECT
  c_count,
  count(*) AS custdist
FROM (
       SELECT
         customer.custkey AS c_custkey,
         count(orders.orderkey)
       FROM
         customer
         LEFT OUTER JOIN orders ON
                                  customer.custkey = orders.custkey
                                  AND orders.comment NOT LIKE '%special%requests%'
       GROUP BY
         customer.custkey
     ) AS c_orders (c_custkey, c_count)
GROUP BY
  c_count
ORDER BY
  custdist DESC,
  c_count DESC;
