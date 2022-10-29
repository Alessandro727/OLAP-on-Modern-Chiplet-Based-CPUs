SELECT
  name,
  customer.custkey,
  orders.orderkey,
  orderdate,
  totalprice,
  sum(quantity)
FROM
  customer,
  orders,
  lineitem
WHERE
  orders.orderkey IN (
    SELECT lineitem.orderkey
    FROM
      lineitem
    GROUP BY
      lineitem.orderkey
    HAVING
      sum(quantity) > 300
  )
  AND customer.custkey = orders.custkey
  AND orders.orderkey = lineitem.orderkey
GROUP BY
  name,
  customer.custkey,
  orders.orderkey,
  orderdate,
  totalprice
ORDER BY
  totalprice DESC,
  orderdate
LIMIT 100;
