from pyspark.sql.types import StructType, StructField, ArrayType, StringType, DoubleType, IntegerType, DateType
from pyspark.sql import SparkSession
from pyspark.sql.functions import explode, col
from pyspark.ml.feature import VectorAssembler
from pyspark.ml.regression import LinearRegression
from util import mount_schema, get_data_collection, retrieve_params, fields_name

import sys


if __name__ == '__main__':
    my_uuid = str(sys.argv[1])
    params = retrieve_params(my_uuid)

    publish_strategy = params["publish_strategy"]
    capability_to_analyze = params["interscity"]["capability"]
    sch = mount_schema(capability_to_analyze, params)

    spark = SparkSession.builder.getOrCreate()
    spark.sparkContext.setLogLevel("ERROR")

    fields = fields_name(capability_to_analyze, params)
    data_collection = get_data_collection(capability_to_analyze)
    exploded_fields = list(map(lambda x: col(capability_to_analyze+'.'+x), fields))
    df = (spark
            .createDataFrame(data_collection, sch)
            .select(
                explode(col("capabilities.{0}".format(capability_to_analyze))).alias(capability_to_analyze))
            .select(exploded_fields))

    features = list(map(lambda a: a.strip(), params["functional_params"]["features"].split(",")))

    assembler = VectorAssembler(inputCols=features, outputCol="features")
    assembled_df = assembler.transform(df)
    lr = (LinearRegression(maxIter=10)
            .setLabelCol(params["functional_params"]["label_col"])
            .setFeaturesCol("features"))
    model = lr.fit(assembled_df)
    save_model(model, publish_strategy)
    spark.stop()
