SELECT sum(extendedprice) / 7.0 AS avg_yearly
FROM
  lineitem,
  part
WHERE
  part.partkey = lineitem.partkey
  AND brand = 'Brand#23'
  AND container = 'MED BOX'
  AND quantity < (
    SELECT 0.2 * avg(quantity)
    FROM
      lineitem
    WHERE
      lineitem.partkey = part.partkey
  );
