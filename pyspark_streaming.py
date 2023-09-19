import os
from dotenv import load_dotenv
from pyspark.sql import SparkSession
from pyspark.sql.types import *
from pyspark.sql.functions import *
import toml

# Loading and assigning variables
BOOTSTRAP_SERVERS = 'localhost:9092'
load_dotenv('../../.env')
app_config = toml.load('../../config_file.toml')
s3_bucket = app_config['aws']['s3_bucket']

ACCESS_KEY = os.getenv('ACCESS_KEY')
SECRET_KEY = os.getenv('SECRET_KEY')

# Sometimes, there may be errors with writing hudi tables to the S3 bucket. 
# A way to tell is by running the execute_pyspark.sh script and if it exits without you pressing Ctrl+c, then there is likely an issue
# with the hudi file. The following error will likely pop up in the console: 
# org.apache.hudi.exception.HoodieKeyException: recordKey value: "null" for field: "record_id" cannot be null or empty.
# To resolve this, we need to print out the streaming dataframe to figure out if the streaming data is the reason behind this. To do so,
# we need to go into the pyspark terminal to print the transform_df dataframe. Do the following:
# In the spark-3.3.3-bin-hadoop3/bin folder, enter the below command:
# ./pyspark --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.3.1 --conf "spark.serializer=org.apache.spark.serializer.KryoSerializer" --conf "spark.sql.hive.convertMetastoreParquet=false"
# Once you enter the pyspark terminal, copy and paste all the below code up until transform_df = df.select(col("value").cast("string"))...
# Then enter the following code:
# query = transform_df.writeStream \
#     .outputMode("append") \
#     .format("console") \
#     .start()
# At this point, you should see the dataframe being constantly updated with streaming data from Kafka. If you see that the streaming data
# is empty, this means that there are likely issues with mysql, kafka, or debezium connector. In this case, you may need to delete all the
# containers for this project and recreate them again, via the remove_all_artifacts.sh and create_all_artifacts.sh shell scripts respectively.
# Or you could just delete and recreate them manually.

if __name__ == "__main__":
    # Building spark session with the jar files we downloaded earlier
    spark = SparkSession.builder \
    .appName("S3 access") \
    .config("spark.jars", "../jars/hadoop-aws-3.3.3.jar,../jars/aws-java-sdk-bundle-1.12.451.jar") \
    .getOrCreate()

    # Enabling Spark to read s3 bucket via AWS access and secret access key
    spark._jsc.hadoopConfiguration().set("spark.hadoop.fs.s3a.access.key", ACCESS_KEY)
    spark._jsc.hadoopConfiguration().set("spark.hadoop.fs.s3a.secret.key", SECRET_KEY)

    # Reading schema from s3 bucket
    schema = spark.read.json(f's3a://{s3_bucket}/artifacts/bus_status_schema.json').schema

    # Reading spark streaming from kafka topic in our docker container
    df = spark \
        .readStream \
        .format("kafka") \
        .option("kafka.bootstrap.servers", BOOTSTRAP_SERVERS) \
        .option("subscribe", "dbserver1.demo.bus_status") \
        .option("startingOffsets", "latest") \
        .load()

    # Parsing the data from spark streaming to dataframe format
    transform_df = df.select(col("value").cast("string")).alias("value").withColumn("jsonData",from_json(col("value"),schema)).select("jsonData.payload.after.*")

    # Creating checkpoint location for hudi
    checkpoint_location = f"s3a://{s3_bucket}/checkpoints/"

    # Configuring hudi
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

    # Creating output s3 path
    s3_path = f"s3a://{s3_bucket}/output/"

    # Configuring hudi write
    def write_batch(batch_df, batch_id):
       batch_df.write.format("org.apache.hudi") \
       .options(**hudi_options) \
       .mode("append") \
       .save(s3_path)

    # Writing to s3 bucket
    transform_df.writeStream.option("checkpointLocation", checkpoint_location).queryName("wcd-bus-streaming").foreachBatch(write_batch).start().awaitTermination()
