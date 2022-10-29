SELECT 100.00 * sum(CASE
                    WHEN type LIKE 'PROMO%'
                      THEN extendedprice * (1 - discount)
                    ELSE 0
                    END) / sum(extendedprice * (1 - discount)) AS promo_revenue
FROM
  lineitem,
  part
WHERE
  lineitem.partkey = part.partkey
  AND shipdate >= DATE '1995-09-01'
  AND shipdate < DATE '1995-09-01' + INTERVAL '1' MONTH;
