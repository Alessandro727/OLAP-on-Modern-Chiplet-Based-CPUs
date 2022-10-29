SELECT
  acctbal,
  supplier.name,
  nation.name,
  part.partkey,
  mfgr,
  address,
  phone,
  supplier.comment
FROM
  part,
  supplier,
  partsupp,
  nation,
  region
WHERE
  part.partkey = partsupp.partkey
  AND supplier.suppkey = partsupp.suppkey
  AND size = 15
  AND type LIKE '%BRASS'
  AND supplier.nationkey = nation.nationkey
  AND nation.regionkey = region.regionkey
  AND region.name = 'EUROPE'
  AND supplycost = (
    SELECT min(supplycost)
    FROM
      partsupp, supplier, part,
      nation, region
    WHERE
      part.partkey = partsupp.partkey
      AND supplier.suppkey = partsupp.suppkey
      AND supplier.nationkey = nation.nationkey
      AND nation.regionkey = region.regionkey
      AND region.name = 'EUROPE'
  )
ORDER BY
  acctbal DESC,
  nation.name,
  supplier.name,
  part.partkey
LIMIT 100;
