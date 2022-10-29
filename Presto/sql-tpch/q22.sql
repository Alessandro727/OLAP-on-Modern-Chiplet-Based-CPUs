SELECT
  cntrycode,
  count(*)       AS numcust,
  sum(acctbal) AS totacctbal
FROM (
       SELECT
         substr(phone, 1, 2) AS cntrycode,
         acctbal
       FROM
         customer
       WHERE
         substr(phone, 1, 2) IN
         ('13', '31', '23', '29', '30', '18', '17')
         AND acctbal > (
           SELECT avg(acctbal)
           FROM
             customer
           WHERE
             acctbal > 0.00
             AND substr(phone, 1, 2) IN
                 ('13', '31', '23', '29', '30', '18', '17')
         )
         AND NOT exists(
           SELECT *
           FROM
             orders
           WHERE
             orders.custkey = customer.custkey
         )
     ) AS custsale
GROUP BY
  cntrycode
ORDER BY
  cntrycode;
