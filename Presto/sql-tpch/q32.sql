SELECT 0.5 * sum(totalprice)
FROM
 orders
WHERE
 orderdate >= date('1994-01-01')
 AND orderdate < date('1994-01-01') + interval '1' YEAR;

