from pyspark.sql.types import StructType, StructField, ArrayType, StringType, DoubleType, IntegerType, DateType
from pyspark.sql import SparkSession
from pyspark.sql.functions import explode, col
from pyspark.ml.feature import VectorAssembler
from pyspark.ml.regression import LinearRegression
from pyspark.ml.clustering import KMeans
from util import mount_df_from_collector, retrieve_params, fields_name

import sys


if __name__ == '__main__':
    # Loading the dataset
    my_uuid = str(sys.argv[1])
    params = retrieve_params(my_uuid)

    functional_params = params["functional_params"]
    capability = params["interscity"]["capability"]

    spark = SparkSession.builder.getOrCreate()
    spark.sparkContext.setLogLevel("ERROR")

    features = list(map(lambda a: a.strip(), functional_params["features"].split(",")))
    df = (mount_df_from_collector(capability, params)
            .select(features)
            .na
            .drop())

    assembler = VectorAssembler(inputCols=features, outputCol="features")
    assembled_df = assembler.transform(df).select("features")

    # Running KMeans
    how_many_clusters = int(functional_params.get("k", 2))
    seed_to_use = functional_params.get("seed", 1)
    kmeans = KMeans().setK(how_many_clusters).setSeed(seed_to_use)
    model = kmeans.fit(assembled_df)

    publish_strategy = params["publish_strategy"]
    model_host = functional_params.get("model_host", "/tmp/data/")
    model_file_path = publish_strategy["path"]
    model.write().overwrite().save(model_host + model_file_path)

    centers = []
    for k in model.clusterCenters():
        centers.append(k.tolist())

    center_host = functional_params.get("centers_host", "/tmp/data/")
    center_path = functional_params.get("centers_path", None)
    centers_df = spark.createDataFrame(centers, features)

    if (center_path != None):
        centers_df.write.mode("overwrite").save(center_host + center_path)
    else:
        centers_df.show(truncate=False)
    spark.stop()
