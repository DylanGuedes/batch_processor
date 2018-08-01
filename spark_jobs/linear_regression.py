from pyspark.sql.types import StructType, StructField, ArrayType, StringType, DoubleType, IntegerType, DateType
from pyspark.sql import SparkSession
from pyspark.sql.functions import explode, col
from pyspark.ml.feature import VectorAssembler
from pyspark.ml.regression import LinearRegression

import sys
import requests

DEFAULT_BATCH_PROCESSOR_URL = "http://batch-processor:4545"
DEFAULT_DATA_COLLECTOR_URL = "http://data-collector:3000"


def get_data_collection(capability):
    # get data from collector
    data_collector_url = DEFAULT_DATA_COLLECTOR_URL

    try:
        r = requests.post(data_collector_url + '/resources/data', json={"capabilities": [capability]})
        return r.json()["resources"]

    except:
        raise Exception("""
            Your data_collector looks weird.
            Usage: `train_model ${data_collector_url}`
            (default data_collector_url: http://data_collector:3000)
        """)


def extract_publish_strategy(opts):
    # Given the selected publish_strategy params, mount a known
    # publish_strategy hash
    return opts


def fields_name(capability, opts):
    fields = []
    opts_sch = opts[capability+"_schema"]
    for name, typ in opts_sch.items():
        fields.append(name)
    return fields


def mount_schema(capability, opts):
    # Given the selected schema params as hash, mount a known
    # Spark schema
    opts_sch = opts[capability+"_schema"]
    fields = []

    for name, typ in opts_sch.items():
        print("add field {0} of type {1}".format(name, typ))
        if typ == "string":
            fields.append(StructField(name, StringType(), False))
        elif typ == "double":
            fields.append(StructField(name, DoubleType(), False))
        elif typ == "integer":
            fields.append(StructField(name, IntegerType(), False))
        elif typ == "date":
            fields.append(StructField(name, StringType(), False))

    return StructType([
        StructField("uuid", StringType(), False),
        StructField("capabilities", StructType([
            StructField(capability, ArrayType(StructType(fields)))
        ]))
    ])


def save_model(model, publish_strategy):
    if (publish_strategy["name"] == "file" or publish_strategy["name"] == "hdfs"):
        file_path = publish_strategy["path"]
        if (publish_strategy["name"] == "hdfs"):
            file_path = "hdfs://hadoop:9000/"+file_path
        (model
                .write()
                .overwrite()
                .save(file_path))
        print("#"*40)
        print("Model saved at {0}".format(file_path))
        print("#"*40)


def retrieve_params(job_id):
    url = DEFAULT_BATCH_PROCESSOR_URL + '/api/retrieve_params'
    response = requests.get(url, params={'job_id': my_uuid})
    return response.json()


if __name__ == '__main__':
    my_uuid = sys.argv[1]
    params = retrieve_params(my_uuid)

    publish_strategy = extract_publish_strategy(params["publish_strategy"])
    capability_to_analyze = params["capability"]
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

    assembler = VectorAssembler(inputCols=params["features"], outputCol="features")
    assembled_df = assembler.transform(df)
    train, test = assembled_df.randomSplit([0.9, 0.1], seed=0)
    lr = (LinearRegression(maxIter=10)
            .setLabelCol(params["label_col"])
            .setFeaturesCol("features"))
    model = lr.fit(train)
    save_model(model, publish_strategy)
