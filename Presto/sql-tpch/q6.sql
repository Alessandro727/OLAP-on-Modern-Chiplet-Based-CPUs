SELECT sum(extendedprice * discount) AS revenue
FROM
  lineitem
WHERE
  shipdate >= DATE '1994-01-01'
  AND shipdate < DATE '1994-01-01' + INTERVAL '1' YEAR
AND discount BETWEEN decimal '0.06' - decimal '0.01' AND decimal '0.06' + decimal '0.01'
AND quantity < 24;
