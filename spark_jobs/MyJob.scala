import org.apache.spark.sql.{SparkSession, Row}
import org.apache.spark.sql.types.{
  StructType, StructField, DoubleType, IntegerType
}

class SimpleApp {
  def main(args: Array[String]) {
    val spark = SparkSession.builder.appName("My Application").getOrCreate()
    val rdd = spark.sparkContext.parallelize(Seq(
        Row(1000, 1, 1),
        Row(1200, 1, 1),
        Row(4000, 2, 2),
        Row(5000, 2, 3)))
    val schema = new StructType(Array(
				StructField("price", DoubleType, nullable = false),
				StructField("baths", IntegerType, nullable = false),
				StructField("rooms", IntegerType, nullable = false)))
    val df = spark.createDataFrame(rdd, schema)

    df.show()
    df.describe().show()

    spark.stop()
  }
}
