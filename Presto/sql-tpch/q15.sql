CREATE OR REPLACE VIEW revenue AS
  SELECT
    lineitem.suppkey AS supplier_no,
    sum(extendedprice * (1 - discount)) AS total_revenue
  FROM
    lineitem
  WHERE
    shipdate >= DATE '1996-01-01'
    AND shipdate < DATE '1996-01-01' + INTERVAL '3' MONTH
GROUP BY
  lineitem.suppkey;

SELECT
  supplier.suppkey,
  name,
  address,
  phone,
  total_revenue
FROM
  supplier,
  revenue
WHERE
  supplier.suppkey = supplier_no
  AND total_revenue = (
    SELECT max(total_revenue)
    FROM
      revenue
  )
ORDER BY
  supplier.suppkey;
