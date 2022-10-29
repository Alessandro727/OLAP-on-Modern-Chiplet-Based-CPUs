SELECT sum(extendedprice * (1 - discount)) AS revenue
FROM
  lineitem,
  part
WHERE
  (
    part.partkey = lineitem.partkey
    AND brand = 'Brand#12'
    AND container IN ('SM CASE', 'SM BOX', 'SM PACK', 'SM PKG')
    AND quantity >= 1 AND quantity <= 1 + 10
    AND size BETWEEN 1 AND 5
    AND shipmode IN ('AIR', 'AIR REG')
    AND shipinstruct = 'DELIVER IN PERSON'
  )
  OR
  (
    part.partkey = lineitem.partkey
    AND brand = 'Brand#23'
    AND container IN ('MED BAG', 'MED BOX', 'MED PKG', 'MED PACK')
    AND quantity >= 10 AND quantity <= 10 + 10
    AND size BETWEEN 1 AND 10
    AND shipmode IN ('AIR', 'AIR REG')
    AND shipinstruct = 'DELIVER IN PERSON'
  )
  OR
  (
    part.partkey = lineitem.partkey
    AND brand = 'Brand#34'
    AND container IN ('LG CASE', 'LG BOX', 'LG PACK', 'LG PKG')
    AND quantity >= 20 AND quantity <= 20 + 10
    AND size BETWEEN 1 AND 15
    AND shipmode IN ('AIR', 'AIR REG')
    AND shipinstruct = 'DELIVER IN PERSON'
  );
