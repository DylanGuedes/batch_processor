from pyspark.sql.types import StructType, StructField, ArrayType, IntegerType
from pyspark.sql import SparkSession
from pyspark.sql.functions import explode, col
from pyspark.ml.feature import VectorAssembler
from pyspark.ml.regression import LinearRegression

import requests

DEFAULT_DATA_COLLECTOR_URL = "http://data-collector:3000"


if __name__ == '__main__':
    data_collector_url = DEFAULT_DATA_COLLECTOR_URL

    collection = (requests
        .post(data_collector_url + '/resources/data', json={"capabilities": ["house_pricing"]})
        .json()["resources"])

    spark = SparkSession.builder.getOrCreate()
    spark.sparkContext.setLogLevel("ERROR")

    sch = StructType([
        StructField("uuid", StringType(), False),
        StructField("capabilities", StructType([
            StructField("house_pricing", ArrayType(StructType([
                StructField("beds", IntegerType(), False),
                StructField("baths", IntegerType(), False),
                StructField("sq__ft", IntegerType(), False),
                StructField("price", IntegerType(), False)
            ])))
        ]))
    ])

    df = (spark
            .createDataFrame(collection, sch)
            .select(explode(col("capabilities.{0}".format("house_pricing"))).alias("house_pricing"))
            .withColumn("beds", col("house_pricing.beds"))
            .withColumn("baths", col("house_pricing.baths"))
            .withColumn("sq__ft", col("house_pricing.sq__ft"))
            .withColumn("price", col("house_pricing.price")))

    assembler = VectorAssembler(inputCols=["beds", "baths", "sq__ft"], outputCol="features")
    assembled_df = assembler.transform(df)
    lr = LinearRegression(maxIter=10).setLabelCol("price") .setFeaturesCol("features")
    model = lr.fit(assembled_df)
    test_df = spark.createDataFrame((([1., 1., 70.]),), ["beds", "baths", "sq__ft"])
    assembled_test_df = model.transform(assembler.transform(test_df))
    assembled_test_df.show(truncate=False)
