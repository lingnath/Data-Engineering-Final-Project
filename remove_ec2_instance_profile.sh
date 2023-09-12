#!/bin/bash

ec2_role_instance_profile_name=$(cat config_file.toml | grep 'ec2_role_instance_profile_name' | awk -F "=" '{print $2}' | tr -d "'" | tr -d " ")

# Detach S3 full access
aws iam detach-role-policy \
 --role-name ${ec2_role_instance_profile_name} \
 --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

aws iam remove-role-from-instance-profile \
 --instance-profile-name ${ec2_role_instance_profile_name} \
 --role-name ${ec2_role_instance_profile_name}

aws iam delete-role \
 --role-name ${ec2_role_instance_profile_name}
 
aws iam delete-instance-profile \
 --instance-profile-name ${ec2_role_instance_profile_name}
