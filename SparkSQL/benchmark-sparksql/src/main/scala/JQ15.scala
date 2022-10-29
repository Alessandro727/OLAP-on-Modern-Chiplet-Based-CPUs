package main.scala

import org.apache.spark.sql.DataFrame
import org.apache.spark.SparkContext
import org.apache.spark.sql.functions.max
import org.apache.spark.sql.functions.sum
import org.apache.spark.sql.functions.udf

/**
 * JCC-H Query 15
 *
 */
class JQ15 extends JcchQuery {

  override def execute(sc: SparkContext, schemaProvider: JcchSchemaProvider): DataFrame = {

    // this is used to implicitly convert an RDD to a DataFrame.
    val sqlContext = new org.apache.spark.sql.SQLContext(sc)
    import sqlContext.implicits._
    import schemaProvider._

    val decrease = udf { (x: Double, y: Double) => x * (1 - y) }

    val revenue = lineitem.filter($"l_shipdate" >= "1994-05-01" &&
      $"l_shipdate" < "1994-08-01")
      .select($"l_suppkey", decrease($"l_extendedprice", $"l_discount").as("value"))
      .groupBy($"l_suppkey")
      .agg(sum($"value").as("total"))
    // .cache

    revenue.agg(max($"total").as("max_total"))
      .join(revenue, $"max_total" === revenue("total"))
      .join(supplier, $"l_suppkey" === supplier("s_suppkey"))
      .select($"s_suppkey", $"s_name", $"s_address", $"s_phone", $"total")
      .sort($"s_suppkey")
  }

}
