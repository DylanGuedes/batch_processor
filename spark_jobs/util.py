from pyspark.sql.types import StructType, StructField, ArrayType, StringType, DoubleType, IntegerType, DateType
from pyspark.sql.functions import explode, col
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


def fields_name(capability, opts):
    fields = []
    opts_sch = opts["schema"]
    for name, typ in opts_sch.items():
        fields.append(name)
    return fields


def mount_schema(capability, opts):
    # Given the selected schema params as hash, mount a known
    # Spark schema
    opts_sch = opts["schema"]
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


def retrieve_params(job_id):
    url = DEFAULT_BATCH_PROCESSOR_URL + '/api/retrieve_params'
    response = requests.get(url, params={'job_id': job_id})
    return response.json()


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
