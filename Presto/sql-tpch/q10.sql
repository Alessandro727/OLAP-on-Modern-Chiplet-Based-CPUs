SELECT
  customer.custkey,
  customer.name,
  sum(extendedprice * (1 - discount)) AS revenue,
  acctbal,
  nation.name,
  address,
  phone,
  customer.comment
FROM
  customer,
  orders,
  lineitem,
  nation
WHERE
  customer.custkey = orders.custkey
  AND lineitem.orderkey = orders.orderkey
  AND orderdate >= DATE '1993-10-01'
  AND orderdate < DATE '1993-10-01' + INTERVAL '3' MONTH
  AND returnflag = 'R'
  AND customer.nationkey = nation.nationkey
GROUP BY
  customer.custkey,
  customer.name,
  acctbal,
  phone,
  nation.name,
  address,
  customer.comment
ORDER BY
  revenue DESC
LIMIT 20;
