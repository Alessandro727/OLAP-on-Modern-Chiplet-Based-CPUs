package main.scala

import org.apache.spark.sql.DataFrame
import org.apache.spark.SparkContext
import org.apache.spark.sql.functions.count

/**
 * JCC-H Query 4
 *
 */
class JQ04 extends JcchQuery {

  override def execute(sc: SparkContext, schemaProvider: JcchSchemaProvider): DataFrame = {

    // this is used to implicitly convert an RDD to a DataFrame.
    val sqlContext = new org.apache.spark.sql.SQLContext(sc)
    import sqlContext.implicits._
    import schemaProvider._

/**    val forders = order.filter($"o_orderdate" >= "1993-07-01" && $"o_orderdate" < "1993-10-01")
    val flineitems = lineitem.filter($"l_commitdate" < $"l_receiptdate")
      .select($"l_orderkey")
      .distinct

    flineitems.join(forders, $"l_orderkey" === forders("o_orderkey"))
      .groupBy($"o_orderpriority")
      .agg(count($"o_orderpriority"))
      .sort($"o_orderpriority")
*/
    sqlContext.sql("""select
        o_orderpriority,
        count(*) as order_count
from
        orders
where
        o_orderdate >= '1993-05-01'
        and o_orderdate < '1994-08-01'
        and exists (
                select
                        *
                from
                        lineitem
                where
                        l_orderkey = o_orderkey
                        and l_commitdate < l_receiptdate
        )
group by
        o_orderpriority
order by
        o_orderpriority""")
  }

}
