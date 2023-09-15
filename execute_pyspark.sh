#!/bin/bash

# Executing the pyspark streaming script. Please press Ctrl+c in the terminal to end this script. This script is designed to run indefinitely.
cd spark-3.3.3-bin-hadoop3/bin
./spark-submit --master local[*] --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.3.3,org.apache.hudi:hudi-spark3-bundle_2.12:0.12.3 --conf "spark.serializer=org.apache.spark.serializer.KryoSerializer" ../../pyspark_streaming.py
