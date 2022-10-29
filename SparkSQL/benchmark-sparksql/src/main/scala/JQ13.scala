package main.scala

import org.apache.spark.sql.DataFrame
import org.apache.spark.SparkContext
import org.apache.spark.sql.functions.count
import org.apache.spark.sql.functions.udf

/**
 * JCC-H Query 13
 *
 */
class JQ13 extends JcchQuery {

  override def execute(sc: SparkContext, schemaProvider: JcchSchemaProvider): DataFrame = {

    // this is used to implicitly convert an RDD to a DataFrame.
    val sqlContext = new org.apache.spark.sql.SQLContext(sc)
    import sqlContext.implicits._
    import schemaProvider._
/**
    val special = udf { (x: String) => x.matches(".*special.*requests.*") }

    customer.join(order, $"c_custkey" === order("o_custkey")
      && !special(order("o_comment")), "left_outer")
      .groupBy($"o_custkey")
      .agg(count($"o_orderkey").as("c_count"))
      .groupBy($"c_count")
      .agg(count($"o_custkey").as("custdist"))
      .sort($"custdist".desc, $"c_count".desc)
*/
    sqlContext.sql("""select
        c_count,
        count(*) as custdist
from
        (
                select
                        c_custkey,
                        count(o_orderkey) c_count
                from
                        customer left outer join orders on
                                c_custkey = o_custkey
                                and o_comment not like '%express%deposits%'
                group by
                        c_custkey
        ) as c_orders
group by
        c_count
order by
        custdist desc,
        c_count desc""")
  }

}
