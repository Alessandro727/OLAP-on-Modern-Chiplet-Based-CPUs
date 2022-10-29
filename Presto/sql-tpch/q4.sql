SELECT
  orderpriority,
  count(*) AS order_count
FROM orders
WHERE
  orderdate >= DATE '1993-07-01'
  AND orderdate < DATE '1993-07-01' + INTERVAL '3' MONTH
AND EXISTS (
SELECT *
FROM lineitem
WHERE
lineitem.orderkey = orders.orderkey
AND commitdate < receiptdate
)
GROUP BY
orderpriority
ORDER BY
orderpriority;
