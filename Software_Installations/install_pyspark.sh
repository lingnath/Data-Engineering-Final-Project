#!/bin/bash

# Moving out of the Software_Installations folder so that the pyspark package gets its own folder
cd ..
# Please replace apt-get with yum if you are using Amazon AMI, which uses RHEL
sudo apt-get update
# If you are using Amazon AMI, please change to "sudo yum install java-1.8.0" for the line immediately below
sudo apt-get install default-jdk -y
# Getting the Spark package (We will use Spark version 3.3.3)
wget https://dlcdn.apache.org/spark/spark-3.3.3/spark-3.3.3-bin-hadoop3.tgz
# Unzip the Spark package
tar -xvf spark-3.3.3-bin-hadoop3.tgz
# Download the jar files needed in order to read s3 files from the pyspark cli
cd spark-3.3.3-bin-hadoop3/jars
wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.3/hadoop-aws-3.3.3.jar
wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.451/aws-java-sdk-bundle-1.12.451.jar
