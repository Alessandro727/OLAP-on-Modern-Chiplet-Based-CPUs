package main.scala

import org.apache.spark.SparkContext

// JCC-H table schemas
case class JCustomer(
  c_custkey: Long,
  c_name: String,
  c_address: String,
  c_nationkey: Long,
  c_phone: String,
  c_acctbal: Double,
  c_mktsegment: String,
  c_comment: String)

case class JLineitem(
  l_orderkey: Long,
  l_partkey: Long,
  l_suppkey: Long,
  l_linenumber: Long,
  l_quantity: Double,
  l_extendedprice: Double,
  l_discount: Double,
  l_tax: Double,
  l_returnflag: String,
  l_linestatus: String,
  l_shipdate: String,
  l_commitdate: String,
  l_receiptdate: String,
  l_shipinstruct: String,
  l_shipmode: String,
  l_comment: String)

case class JNation(
  n_nationkey: Long,
  n_name: String,
  n_regionkey: Long,
  n_comment: String)

case class JOrder(
  o_orderkey: Long,
  o_custkey: Long,
  o_orderstatus: String,
  o_totalprice: Double,
  o_orderdate: String,
  o_orderpriority: String,
  o_clerk: String,
  o_shippriority: Long,
  o_comment: String)

case class JPart(
  p_partkey: Long,
  p_name: String,
  p_mfgr: String,
  p_brand: String,
  p_type: String,
  p_size: Long,
  p_container: String,
  p_retailprice: Double,
  p_comment: String)

case class JPartsupp(
  ps_partkey: Long,
  ps_suppkey: Long,
  ps_availqty: Long,
  ps_supplycost: Double,
  ps_comment: String)

case class JRegion(
  r_regionkey: Long,
  r_name: String,
  r_comment: String)

case class JSupplier(
  s_suppkey: Long,
  s_name: String,
  s_address: String,
  s_nationkey: Long,
  s_phone: String,
  s_acctbal: Double,
  s_comment: String)

class JcchSchemaProvider(sc: SparkContext, inputDir: String) {

  // this is used to implicitly convert an RDD to a DataFrame.
  val sqlContext = new org.apache.spark.sql.SQLContext(sc)
  import sqlContext.implicits._

  val dfMap = Map(
    "customer" -> sc.textFile(inputDir + "/customer.tbl*").map(_.split('|')).map(p =>
      JCustomer(p(0).trim.toLong, p(1).trim, p(2).trim, p(3).trim.toLong, p(4).trim, p(5).trim.toDouble, p(6).trim, p(7).trim)).toDF(),

    "lineitem" -> sc.textFile(inputDir + "/lineitem.tbl*").map(_.split('|')).map(p =>
      JLineitem(p(0).trim.toLong, p(1).trim.toLong, p(2).trim.toLong, p(3).trim.toLong, p(4).trim.toDouble, p(5).trim.toDouble, p(6).trim.toDouble, p(7).trim.toDouble, p(8).trim, p(9).trim, p(10).trim, p(11).trim, p(12).trim, p(13).trim, p(14).trim, p(15).trim)).toDF(),

    "nation" -> sc.textFile(inputDir + "/nation.tbl*").map(_.split('|')).map(p =>
      JNation(p(0).trim.toLong, p(1).trim, p(2).trim.toLong, p(3).trim)).toDF(),

    "region" -> sc.textFile(inputDir + "/region.tbl*").map(_.split('|')).map(p =>
      JRegion(p(0).trim.toLong, p(1).trim, p(2).trim)).toDF(),

    "orders" -> sc.textFile(inputDir + "/orders.tbl*").map(_.split('|')).map(p =>
      JOrder(p(0).trim.toLong, p(1).trim.toLong, p(2).trim, p(3).trim.toDouble, p(4).trim, p(5).trim, p(6).trim, p(7).trim.toLong, p(8).trim)).toDF(),

    "part" -> sc.textFile(inputDir + "/part.tbl*").map(_.split('|')).map(p =>
      JPart(p(0).trim.toLong, p(1).trim, p(2).trim, p(3).trim, p(4).trim, p(5).trim.toLong, p(6).trim, p(7).trim.toDouble, p(8).trim)).toDF(),

    "partsupp" -> sc.textFile(inputDir + "/partsupp.tbl*").map(_.split('|')).map(p =>
      JPartsupp(p(0).trim.toLong, p(1).trim.toLong, p(2).trim.toLong, p(3).trim.toDouble, p(4).trim)).toDF(),

    "supplier" -> sc.textFile(inputDir + "/supplier.tbl").map(_.split('|')).map(p =>
      JSupplier(p(0).trim.toLong, p(1).trim, p(2).trim, p(3).trim.toLong, p(4).trim, p(5).trim.toDouble, p(6).trim)).toDF())


//  sc.textFile(inputDir + "/supplier.tbl").map(_.split('|')).filter(_.size <= 6).toDF().show(Int.MaxValue)


  // for implicits
  val customer = dfMap.get("customer").get
  val lineitem = dfMap.get("lineitem").get
  val nation = dfMap.get("nation").get
  val region = dfMap.get("region").get
  val orders = dfMap.get("orders").get
  val part = dfMap.get("part").get
  val partsupp = dfMap.get("partsupp").get
  val supplier = dfMap.get("supplier").get

  dfMap.foreach {
    case (key, value) => value.createOrReplaceTempView(key)
  }

  dfMap.foreach {
    case (key, value) => sqlContext.cacheTable(key)
  }

}
