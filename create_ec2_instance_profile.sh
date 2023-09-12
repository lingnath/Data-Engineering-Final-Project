#!/bin/bash

ec2_role_instance_profile_name=$(cat config_file.toml | grep 'ec2_role_instance_profile_name' | awk -F "=" '{print $2}' | tr -d "'" | tr -d " ")


aws iam create-instance-profile \
 --instance-profile-name ${ec2_role_instance_profile_name}

aws iam create-role \
 --role-name ${ec2_role_instance_profile_name} \
 --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "ec2.amazonaws.com"}, "Action": "sts:AssumeRole"}]}'

aws iam add-role-to-instance-profile \
 --instance-profile-name ${ec2_role_instance_profile_name} \
 --role-name ${ec2_role_instance_profile_name}

# Attach S3 full access so that pyspark can read the s3 buckets
aws iam attach-role-policy \
 --role-name ${ec2_role_instance_profile_name} \
 --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess