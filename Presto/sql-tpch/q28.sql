SELECT
  supplier.name,
  address
FROM
  supplier, nation
WHERE
  supplier.suppkey IN (
    SELECT partsupp.suppkey
    FROM
      partsupp
    WHERE
      partsupp.partkey IN (
        SELECT part.partkey
        FROM
          part
        WHERE
          part.name LIKE 'forest%'
      )
      AND availqty > (
        SELECT 0.5 * sum(totalprice)
        FROM
          orders, customer
        WHERE
          orders.custkey = customer.custkey
          AND orderdate >= date('1994-01-01')
          AND orderdate < date('1994-01-01') + interval '1' YEAR
)
)
AND supplier.nationkey = nation.nationkey
AND nation.name = 'CANADA'
ORDER BY supplier.name;
