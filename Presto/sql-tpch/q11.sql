SELECT
  partsupp.partkey,
  sum(supplycost * availqty) AS value
FROM
  partsupp,
  supplier,
  nation
WHERE
  partsupp.suppkey = supplier.suppkey
  AND supplier.nationkey = nation.nationkey
  AND nation.name = 'GERMANY'
GROUP BY
  partsupp.partkey
HAVING
  sum(supplycost * availqty) > (
    SELECT sum(supplycost * availqty) * 0.0001
    FROM
      partsupp,
      supplier,
      nation
    WHERE
      partsupp.suppkey = supplier.suppkey
      AND supplier.nationkey = nation.nationkey
      AND nation.name = 'GERMANY'
  )
ORDER BY
  value DESC;
