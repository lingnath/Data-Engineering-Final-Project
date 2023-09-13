#!/bin/bash

athena_db=$(cat ../config_file.toml | grep 'athena_db' | awk -F "=" '{print $2}' | tr -d "'" | tr -d " ")
aws_region=$(cat ../config_file.toml | grep 'region' | awk -F "=" '{print $2}' | tr -d "'" | tr -d " ")
s3_bucket=$(cat ../config_file.toml | grep 's3_bucket' | awk -F "=" '{print $2}' | tr -d "'" | tr -d " ")

# Removes the database in Athena for this project
aws athena start-query-execution --query-string "DROP database ${athena_db}" \
 --region ${aws_region} \
 --result-configuration "OutputLocation=s3://${s3_bucket}/athena_metadata/"
