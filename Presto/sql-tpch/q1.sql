SELECT
  returnflag,
  linestatus,
  sum(quantity)                                       AS sum_qty,
  sum(extendedprice)                                  AS sum_base_price,
  sum(extendedprice * (1 - discount))               AS sum_disc_price,
  sum(extendedprice * (1 - discount) * (1 + tax)) AS sum_charge,
  avg(quantity)                                       AS avg_qty,
  avg(extendedprice)                                  AS avg_price,
  avg(discount)                                       AS avg_disc,
  count(*)                                              AS count_order
FROM
  lineitem
WHERE
  shipdate <= DATE '1998-12-01' - INTERVAL '90' DAY
GROUP BY
returnflag,
linestatus
ORDER BY
returnflag,
linestatus;
