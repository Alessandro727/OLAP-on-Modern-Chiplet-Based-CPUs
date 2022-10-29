SELECT
  nation.name,
  sum(extendedprice * (1 - discount)) AS revenue
FROM
  customer,
  orders,
  lineitem,
  supplier,
  nation,
  region
WHERE
  customer.custkey = orders.custkey
  AND lineitem.orderkey = orders.orderkey
  AND lineitem.suppkey = supplier.suppkey
  AND customer.nationkey = supplier.nationkey
  AND supplier.nationkey = nation.nationkey
  AND nation.regionkey = region.regionkey
  AND region.name = 'ASIA'
  AND orderdate >= DATE '1994-01-01'
  AND orderdate < DATE '1994-01-01' + INTERVAL '1' YEAR
GROUP BY
nation.name
ORDER BY
revenue DESC;
