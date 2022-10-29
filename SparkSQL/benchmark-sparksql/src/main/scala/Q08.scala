package main.scala

import org.apache.spark.sql.DataFrame
import org.apache.spark.SparkContext
import org.apache.spark.sql.functions.sum
import org.apache.spark.sql.functions.udf

/**
 * TPC-H Query 8
 * Savvas Savvides <savvas@purdue.edu>
 *
 */
class Q08 extends TpchQuery {

  override def execute(sc: SparkContext, schemaProvider: TpchSchemaProvider): DataFrame = {

    // this is used to implicitly convert an RDD to a DataFrame.
    val sqlContext = new org.apache.spark.sql.SQLContext(sc)
    import sqlContext.implicits._
    import schemaProvider._

    val getYear = udf { (x: String) => x.substring(0, 4) }
    val decrease = udf { (x: Double, y: Double) => x * (1 - y) }
    val isBrazil = udf { (x: String, y: Double) => if (x == "BRAZIL") y else 0 }

    val fregion = region.filter($"r_name" === "AMERICA")
    val forder = order.filter($"o_orderdate" <= "1996-12-31" && $"o_orderdate" >= "1995-01-01")
    val fpart = part.filter($"p_type" === "ECONOMY ANODIZED STEEL")

    val nat = nation.join(supplier, $"n_nationkey" === supplier("s_nationkey"))

    val line = lineitem.select($"l_partkey", $"l_suppkey", $"l_orderkey",
      decrease($"l_extendedprice", $"l_discount").as("volume")).
      join(fpart, $"l_partkey" === fpart("p_partkey"))
      .join(nat, $"l_suppkey" === nat("s_suppkey"))

    nation.join(fregion, $"n_regionkey" === fregion("r_regionkey"))
      .select($"n_nationkey")
      .join(customer, $"n_nationkey" === customer("c_nationkey"))
      .select($"c_custkey")
      .join(forder, $"c_custkey" === forder("o_custkey"))
      .select($"o_orderkey", $"o_orderdate")
      .join(line, $"o_orderkey" === line("l_orderkey"))
      .select(getYear($"o_orderdate").as("o_year"), $"volume",
        isBrazil($"n_name", $"volume").as("case_volume"))
      .groupBy($"o_year")
      .agg(sum($"case_volume") / sum("volume"))
      .sort($"o_year")
/**
    sqlContext.sql("""select
        o_year,
        sum(case
                when nation = 'CHINA' then volume
                else 0
        end) / sum(volume) as mkt_share
from
        (
                select
                        extract(year from o_orderdate) as o_year,
                        l_extendedprice * (1 - l_discount) as volume,
                        n2.n_name as nation
                from
                        part,
                        supplier,
                        lineitem,
                        orders,
                        customer,
                        nation n1,
                        nation n2,
                        region
                where
                        p_partkey = l_partkey
                        and s_suppkey = l_suppkey
                        and l_orderkey = o_orderkey
                        and o_custkey = c_custkey
                        and c_nationkey = n1.n_nationkey
                        and n1.n_regionkey = r_regionkey
                        and r_name = 'ASIA'
                        and s_nationkey = n2.n_nationkey
                        and o_orderdate between '1993-01-01' and '1994-12-31'
                        and p_type = 'SHINY MINED GOLD'
        ) as all_nations
group by
        o_year
order by
        o_year""")
*/
  }

}
