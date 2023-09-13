#!/bin/bash

s3_bucket=$(cat ../config_file.toml | grep 's3_bucket' | awk -F "=" '{print $2}' | tr -d "'" | tr -d " ")
aws_region=$(cat ../config_file.toml | grep 'region' | awk -F "=" '{print $2}' | tr -d "'" | tr -d " ")
athena_database_name=$(cat ../config_file.toml | grep 'athena_db' | awk -F "=" '{print $2}' | tr -d "'" | tr -d " ")
athena_table_name=$(cat ../config_file.toml | grep 'athena_table' | awk -F "=" '{print $2}' | tr -d "'" | tr -d " ")

# Create the athena table for this project
aws athena start-query-execution \
--query-string "CREATE EXTERNAL TABLE IF NOT EXISTS ${athena_database_name}.${athena_table_name} (
  record_id int,
  id int,
  routeid int,
  directionid string,
  kph int,
  predictable int,
  secssincereport int,
  heading int,
  lat double,
  lon double,
  leadingvehicleid int,
  event_time timestamp
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'
STORED AS INPUTFORMAT 'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat' OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat'
LOCATION 's3://${s3_bucket}/output/'
TBLPROPERTIES ('classification' = 'parquet');" \
--region ${aws_region} \
--result-configuration "OutputLocation=s3://${s3_bucket}/athena_metadata/"
