spark = SparkSession.builder.getOrCreate()
DEFAULT_URI = "mongodb://interscity-mongo/data_collector_development"
DEFAULT_COLLECTION = "city_resources"
pipeline = "{'$match': {'capability': '"+capability+"'}}"

df = (spark
        .read
        .format("com.mongodb.spark.sql.DefaultSource")
        .option("spark.mongodb.input.uri", "{0}.{1}".format(DEFAULT_URI, DEFAULT_COLLECTION))
        .option("pipeline", pipeline)
        .load())

assembler = VectorAssembler(inputCols=features, outputCol="features")
rf = RandomForestRegressor(featuresCol="features")

features = ["temperature", "polluting-index", "hangover"]
pipeline = Pipeline(stages=[assembler, rf])
model = pipeline.fit(df)

mytest = spark.createDataFrame((20.5, 43, True), features)
prediction = model.transform(mytest)
