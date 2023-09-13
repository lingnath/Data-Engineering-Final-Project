#!/bin/bash

s3_bucket=$(cat ../config_file.toml | grep 's3_bucket' | awk -F "=" '{print $2}' | tr -d "'" | tr -d " ")
aws_region=$(cat ../config_file.toml | grep 'region' | awk -F "=" '{print $2}' | tr -d "'" | tr -d " ")
athena_database_name=$(cat ../config_file.toml | grep 'athena_db' | awk -F "=" '{print $2}' | tr -d "'" | tr -d " ")
athena_table_name=$(cat ../config_file.toml | grep 'athena_table' | awk -F "=" '{print $2}' | tr -d "'" | tr -d " ")

# Removes the table in Athena for this project
aws athena start-query-execution \
 --query-string "DROP table ${athena_database_name}.${athena_table_name}" \
 --region ${aws_region} \
 --result-configuration "OutputLocation=s3://${s3_bucket}/athena_metadata/"