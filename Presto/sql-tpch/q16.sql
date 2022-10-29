SELECT
  brand,
  type,
  size,
  count(DISTINCT partsupp.suppkey) AS supplier_cnt
FROM
  partsupp,
  part
WHERE
  part.partkey = partsupp.partkey
  AND brand <> 'Brand#45'
  AND type NOT LIKE 'MEDIUM POLISHED%'
  AND size IN (49, 14, 23, 45, 19, 3, 36, 9)
  AND partsupp.suppkey NOT IN (
    SELECT supplier.suppkey
    FROM
      supplier
    WHERE
      supplier.comment LIKE '%Customer%Complaints%'
  )
GROUP BY
  brand,
  type,
  size
ORDER BY
  supplier_cnt DESC,
  brand,
  type,
  size;
