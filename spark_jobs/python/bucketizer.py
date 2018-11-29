from pyspark.sql.types import StructType, StructField, ArrayType, StringType, DoubleType, IntegerType, DateType
from pyspark.sql import SparkSession
from pyspark.sql.functions import explode, col
from pyspark.ml.regression import LinearRegression
from pyspark.ml.clustering import KMeans
from pyspark.ml.feature import Bucketizer, StringIndexer, VectorAssembler

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

    df = (mount_df_from_collector(capability, params))

    splits = [0.0, 25.0, 50.0, 100.0, 200.0, 6000.0]
    bucketizer = Bucketizer(splits=splits, inputCol=input_col, outputCol=output_col)
    bucketizer.transform(df).save

    spark.stop()

