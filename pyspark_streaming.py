import os
from dotenv import load_dotenv
from pyspark.sql import SparkSession
from pyspark.sql.types import *
from pyspark.sql.functions import *
import toml

# NOTE: This variable needs to be reviewed if we are working with a new MSK
BOOTSTRAP_SERVERS = 'localhost:9092'
load_dotenv('../../.env')
app_config = toml.load('../../config_file.toml')
s3_bucket = app_config['aws']['s3_bucket']

ACCESS_KEY = os.getenv('ACCESS_KEY')
SECRET_KEY = os.getenv('SECRET_KEY')

# To go into the pyspark terminal to print the transform_df dataframe to debug potential spark streaming issues, do the following:
# In the spark-3.3.3-bin-hadoop3/bin folder, enter the below command:
# ./pyspark --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.3.1 --conf "spark.serializer=org.apache.spark.serializer.KryoSerializer" --conf "spark.sql.hive.convertMetastoreParquet=false"
# Once you enter the pyspark terminal, copy and paste all the below code up until transform_df = df.select(col("value").cast("string"))...
# Then enter the following code:
# query = transform_df.writeStream \
#     .outputMode("append") \
#     .format("console") \
#     .start()
# At this point, you should see the dataframe being constantly being updated with streaming data from Kafka

if __name__ == "__main__":
    spark = SparkSession.builder \
    .appName("S3 access") \
    .config("spark.jars", "../jars/hadoop-aws-3.3.3.jar,../jars/aws-java-sdk-bundle-1.12.451.jar") \
    .getOrCreate()

    spark._jsc.hadoopConfiguration().set("spark.hadoop.fs.s3a.access.key", ACCESS_KEY)
    spark._jsc.hadoopConfiguration().set("spark.hadoop.fs.s3a.secret.key", SECRET_KEY)

   # NOTE: we cant load the schema file from the local machine anymore, so we have to pull it from s3
    schema = spark.read.json(f's3a://{s3_bucket}/artifacts/bus_status_schema.json').schema

 # We have to connect to the bootstrap servers, instead of kafka:9092
    df = spark \
        .readStream \
        .format("kafka") \
        .option("kafka.bootstrap.servers", BOOTSTRAP_SERVERS) \
        .option("subscribe", "dbserver1.demo.bus_status") \
        .option("startingOffsets", "latest") \
        .load()

    transform_df = df.select(col("value").cast("string")).alias("value").withColumn("jsonData",from_json(col("value"),schema)).select("jsonData.payload.after.*")

   # NOTE: We cannot checkpoint to a local machine because we are working on the cloud. S3 is a reliable location for the cluster
    checkpoint_location = f"s3a://{s3_bucket}/checkpoints/"

    table_name = 'bus_status'
    hudi_options = {
       'hoodie.table.name': table_name,
       "hoodie.datasource.write.table.type": "COPY_ON_WRITE",
       'hoodie.datasource.write.recordkey.field': 'record_id',
       'hoodie.datasource.write.partitionpath.field': 'routeId',
       'hoodie.datasource.write.table.name': table_name,
       'hoodie.datasource.write.operation': 'upsert',
       'hoodie.datasource.write.precombine.field': 'event_time',
      'hoodie.upsert.shuffle.parallelism': 100,
       'hoodie.insert.shuffle.parallelism': 100
   }

    s3_path = f"s3a://{s3_bucket}/output/"

    def write_batch(batch_df, batch_id):
       batch_df.write.format("org.apache.hudi") \
       .options(**hudi_options) \
       .mode("append") \
       .save(s3_path)

    transform_df.writeStream.option("checkpointLocation", checkpoint_location).queryName("wcd-bus-streaming").foreachBatch(write_batch).start().awaitTermination()
