SELECT
  lineitem.orderkey,
  sum(extendedprice * (1 - discount)) AS revenue,
  orderdate,
  shippriority
FROM
  customer,
  orders,
  lineitem
WHERE
  mktsegment = 'BUILDING'
  AND customer.custkey = orders.custkey
  AND lineitem.orderkey = orders.orderkey
  AND orderdate < DATE '1995-03-15'
  AND shipdate > DATE '1995-03-15'
GROUP BY
  lineitem.orderkey,
  orderdate,
  shippriority
ORDER BY
  revenue DESC,
  orderdate
LIMIT 10;
