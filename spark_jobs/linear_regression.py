from pyspark.sql.types import StructType, StructField, ArrayType, StringType, DoubleType, IntegerType, DateType
from pyspark.sql import SparkSession
from pyspark.sql.functions import explode, col
import requests
import sys
from pyspark.ml import Pipeline
from pyspark.ml.regression import DecisionTreeRegressor
from pyspark.ml.feature import VectorIndexer
from pyspark.ml.evaluation import RegressionEvaluator
import pyspark.mllib
import pyspark.mllib.regression
from pyspark.ml.feature import VectorAssembler
from pyspark.ml.regression import LinearRegression

DEFAULT_DATA_COLLECTOR_URL = "http://data-collector:3000"

def extract_schema_string(args):
    capabilities_schema = {}

    for idx, u in enumerate(args):
        if u.find('schema') != -1:
            capability_name = args[idx]
            capability_schema = {}
            schema_size = int(args[idx+1])
            convenient_list = args[idx+2:(idx+2)+(schema_size*2)]
            for attr_idx, attr_name in enumerate(convenient_list):
                if not (attr_idx&1):
                    attr_type = convenient_list[attr_idx+1]
                    capability_schema[attr_name] = attr_type
            capabilities_schema[capability_name] = capability_schema

    return capabilities_schema


def mount_spark_capability_schema(capability, capability_string_schema):
    fields = []

    for name, typ in capability_string_schema.items():
        if typ == "string":
            fields.append(StructField(name, StringType(), True))
        elif typ == "double":
            fields.append(StructField(name, DoubleType(), True))
        elif typ == "integer":
            fields.append(StructField(name, IntegerType(), True))
        elif typ == "date":
            fields.append(StructField(name, StringType(), True))

    return StructType([
        StructField("uuid", StringType(), False),
        StructField("capabilities", StructType([
            StructField(capability, ArrayType(StructType(fields)))
        ]))
    ])


def get_data_collection(capability):
    data_collector_url = DEFAULT_DATA_COLLECTOR_URL
    # get data from collector

    try:
        r = requests.post(data_collector_url + '/resources/data', json={"capabilities": [capability]})
        return r.json()["resources"]

    except:
        raise Exception("""
            Your data_collector looks weird.
            Usage: `train_model ${data_collector_url}`
            (default data_collector_url: http://data_collector:3000)
        """)


def get_correlation_attrs(argv):
    for idx, u in enumerate(argv):
        if (u == "--others"):
            return argv[idx+1:]


def extract_publish_strategy(argv):
    for idx, u in enumerate(argv):
        if (u == "--publish"):
            if argv[idx+1] == "console":
                return {"strategy": "console", "truncate": False}
            elif argv[idx+1] == "hdfs":
                return {"strategy": "hdfs", "file_name": argv[idx+2]}


def get_features(argv):
    features = []
    for idx, u in enumerate(argv):
        if (u == "--others"):
            features = argv[idx+1:]
            return (argv[idx], features)


def linreg(features, capability, df):
    features_df = df.select(list(map(lambda x: "{0}.{1}".format(capability, x), features[2:])))
    features = features[2:]
    features_df.show(truncate=False)

    assembler = VectorAssembler(inputCols=features,
            outputCol='features')
    print(features_df.columns)

    assembled_df = assembler.transform(features_df)
    train, test = assembled_df.randomSplit([0.6, 0.4], seed=0)
    lr = LinearRegression(maxIter=10).setLabelCol(features[0]).setFeaturesCol("features")
    model = lr.fit(train)
    testing_summary = model.evaluate(test)
    return testing_summary.predictions.select('baths','beds','sq__ft','prediction')


if __name__ == '__main__':
    spark = SparkSession.builder.getOrCreate()
    spark.sparkContext.setLogLevel("ERROR")

    publish_strategy = extract_publish_strategy(sys.argv)
    schema_string = extract_schema_string(sys.argv)
    capability, features = get_features(sys.argv)

    for k, v in schema_string.items():
        capability = k.replace("_schema", "")
        sch = mount_spark_capability_schema(capability, v)
        data_collection = get_data_collection(capability)
        df = spark.createDataFrame(data_collection, sch)

        df = linreg(features, capability, df.select(explode(col("capabilities.{0}".format(capability))).alias(capability)))

        if publish_strategy["strategy"] == "console":
            df.show(truncate=publish_strategy["truncate"])
        elif publish_strategy["strategy"] == "hdfs":
            (df.write.mode('overwrite')
                    .option("header", "true")
                    .format("csv")
                    .save("hdfs://hadoop:9000/model.csv"))
