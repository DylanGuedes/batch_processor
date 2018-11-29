import org.apache.spark.sql.{SparkSession, Row}
import org.apache.spark.sql.types.{
  StructType, StructField, DoubleType, IntegerType
}
import play.api.libs.ws._
import play.api.libs.ws.ahc._
import akka.actor.ActorSystem
import akka.stream.ActorMaterializer
import scala.concurrent.Future

object InterSCityJobs {
  def main(args: Array[String]) {
    val job_id = "a58d09b4-a3b3-4c05-8940-360b7d2a1ba2"
    val endpoint = "http://localhost:4545/api/request_params?job_id=${job_id}"
    implicit val system = ActorSystem()
    implicit val materializer = ActorMaterializer()

    val wsClient = StandaloneAhcWSClient()

    val k = wsClient.url(endpoint).get()
    println(k)
    //   .map { response ⇒
    //   val statusText: String = response.statusText
    //   val body = response.body[String]
    //   println(s"Got a response $statusText")
    // }

    // val k = wsClient.url(endpoint).get()
    // println(" k => ")
    // println(k)
      
    //   .map { response ⇒
    //   val statusText: String = response.statusText
    //   val body = response.body[String]
    //   println(s"Got a response $statusText")
    // }
    // val spark = SparkSession.builder.appName("My Application").getOrCreate()
    // val rdd = spark.sparkContext.parallelize(Seq(
    //     Row(1000, 1, 1),
    //     Row(1200, 1, 1),
    //     Row(4000, 2, 2),
    //     Row(5000, 2, 3)))
    // val schema = new StructType(Array(
		// 		StructField("price", IntegerType, nullable = false),
		// 		StructField("baths", IntegerType, nullable = false),
		// 		StructField("rooms", IntegerType, nullable = false)))
    // val df = spark.createDataFrame(rdd, schema)
    //
    // df.show()
    // df.describe().show()
    //
    // spark.stop()
  }
}
