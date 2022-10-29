SELECT 0.5 * sum(quantity)
FROM
 lineitem
WHERE
 shipdate >= date('1994-01-01')
 AND shipdate < date('1994-01-01') + interval '1' YEAR;
