#!/bin/bash

ec2_role_instance_profile_name=$(cat ../config_file.toml | grep 'ec2_role_instance_profile_name' | awk -F "=" '{print $2}' | tr -d "'" | tr -d " ")

# Create the instance profile
aws iam create-instance-profile \
 --instance-profile-name ${ec2_role_instance_profile_name}

# Create the IAM role
aws iam create-role \
 --role-name ${ec2_role_instance_profile_name} \
 --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "ec2.amazonaws.com"}, "Action": "sts:AssumeRole"}]}'

# Attach the IAM role to the instance profile
aws iam add-role-to-instance-profile \
 --instance-profile-name ${ec2_role_instance_profile_name} \
 --role-name ${ec2_role_instance_profile_name}

# Attach S3 full access so that pyspark can read the s3 buckets
aws iam attach-role-policy \
 --role-name ${ec2_role_instance_profile_name} \
 --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

# Giving time for aws to detect the newly created instance profile before attaching to our EC2 instance
sleep 5

# Get EC2 instance id
ec2_instance_id=$(ec2-metadata -i | grep 'instance-id' | awk -F ": " '{print $2}')

# Attach the iam instance profile to our EC2 instance
aws ec2 associate-iam-instance-profile --iam-instance-profile Name=${ec2_role_instance_profile_name} --instance-id ${ec2_instance_id}
