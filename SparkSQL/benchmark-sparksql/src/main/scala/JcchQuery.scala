package main.scala

import org.apache.spark.SparkContext
import org.apache.spark.SparkConf
import java.io.BufferedWriter
import java.io.File
import java.io.FileWriter
import org.apache.spark.sql._
import scala.collection.mutable.ListBuffer
import java.util.concurrent.TimeUnit
import scala.concurrent.ExecutionContext.Implicits.global
import sys.process._

/**
 * Parent class for TPC-H queries.
 *
 * Defines schemas for tables and reads pipe ("|") separated text files into these tables.
 *
 * Savvas Savvides <savvas@purdue.edu>
 *
 */
abstract class JcchQuery {

  // get the name of the class excluding dollar signs and package
  private def escapeClassName(className: String): String = {
    className.split("\\.").last.replaceAll("\\$", "")
  }

  def getName(): String = escapeClassName(this.getClass.getName)

  /**
   *  implemented in children classes and hold the actual query
   */
  def execute(sc: SparkContext, jcchSchemaProvider: JcchSchemaProvider): DataFrame
}

object JcchQuery {

  def outputDF(df: DataFrame, outputDir: String, className: String): Unit = {

    if (outputDir == null || outputDir == "")
      df.collect().foreach(println)
    else
      //df.write.mode("overwrite").json(outputDir + "/" + className + ".out") // json to avoid alias
      df.write.mode("overwrite").format("com.databricks.spark.csv").option("header", "true").save(outputDir + "/" + className)
  }

  def executeQueries(sc: SparkContext, schemaProvider: JcchSchemaProvider, queryNum: Int): ListBuffer[(String, Float)] = {

    // if set write results to hdfs, if null write to stdout
    val scriptPath = System.getProperty("user.dir")
    val OUTPUT_DIR: String = "file://"+scriptPath
    val results = new ListBuffer[(String, Float)]

    var fromNum = 1;
    var toNum = 22;
    if (queryNum != 0) {
      fromNum = queryNum;
      toNum = queryNum;
    }


    for (queryNo <- 1 to 10) {
      val t0 = System.nanoTime()


      val query = Class.forName(f"main.scala.JQ${queryNum}%02d").newInstance.asInstanceOf[JcchQuery]

      val dataf = query.execute(sc, schemaProvider)

      outputDF(dataf, OUTPUT_DIR, query.getName())

      val t1 = System.nanoTime()

      val elapsed = (t1 - t0) / 1000000000.0f // second
      results += new Tuple2(query.getName(), elapsed)
    }

    return results
  }

  def main(args: Array[String]): Unit = {

    var queryNum = 0;
    if (args.length > 0)
      queryNum = args(0).toInt

    val conf = new SparkConf().setAppName("Simple Application").set("spark.sql.broadcastTimeout", "5000")

    val sc = new SparkContext(conf)

    // read files from local FS
    val scriptPath = System.getProperty("user.dir")
    val INPUT_DIR = "file:///"+scriptPath+"/benchmark-sparksql/JCC-H_dbgen"

    val schemaProvider = new JcchSchemaProvider(sc, INPUT_DIR)

    val output = new ListBuffer[(String, Float)]
    output ++= executeQueries(sc, schemaProvider, queryNum)

    val outFile = new File("JCCHQueriesExecTimes.txt")
    val bw = new BufferedWriter(new FileWriter(outFile, true))

    output.foreach {
      case (key, value) => bw.write(f"${key}%s\t${value}%1.8f\n")
    }

    bw.close()
  }
}

