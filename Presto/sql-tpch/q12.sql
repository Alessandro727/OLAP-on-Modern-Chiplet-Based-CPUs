SELECT
  shipmode,
  sum(CASE
      WHEN orderpriority = '1-URGENT'
           OR orderpriority = '2-HIGH'
        THEN 1
      ELSE 0
      END) AS high_line_count,
  sum(CASE
      WHEN orderpriority <> '1-URGENT'
           AND orderpriority <> '2-HIGH'
        THEN 1
      ELSE 0
      END) AS low_line_count
FROM
  orders,
  lineitem
WHERE
  orders.orderkey = lineitem.orderkey
  AND shipmode IN ('MAIL', 'SHIP')
  AND commitdate < lineitem.receiptdate
  AND shipdate < lineitem.commitdate
  AND receiptdate >= DATE '1994-01-01'
  AND receiptdate < DATE '1994-01-01' + INTERVAL '1' YEAR
GROUP BY
  shipmode
ORDER BY
  shipmode;
