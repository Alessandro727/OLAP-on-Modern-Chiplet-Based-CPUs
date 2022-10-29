SELECT
  supplier.name,
  count(*) AS numwait
FROM
  supplier,
  lineitem l1,
  orders,
  nation
WHERE
  supplier.suppkey = l1.suppkey
  AND orders.orderkey = l1.orderkey
  AND orderstatus = 'F'
  AND l1.receiptdate > l1.commitdate
  AND exists(
    SELECT *
    FROM
      lineitem l2
    WHERE
      l2.orderkey = l1.orderkey
      AND l2.suppkey <> l1.suppkey
  )
  AND NOT exists(
    SELECT *
    FROM
      lineitem l3
    WHERE
      l3.orderkey = l1.orderkey
      AND l3.suppkey <> l1.suppkey
      AND l3.receiptdate > l3.commitdate
  )
  AND supplier.nationkey = nation.nationkey
  AND nation.name = 'SAUDI ARABIA'
GROUP BY
  supplier.name
ORDER BY
  numwait DESC,
  supplier.name
LIMIT 100;
