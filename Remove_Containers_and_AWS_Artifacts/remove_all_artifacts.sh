#!/bin/bash

# Creates the log directory and logfiles within
filenametime=$(date +"%m%d%Y%H%M%S")
cd ..
log_dir="logs"
SHELL_SCRIPT_NAME='remove_aws_artifacts'

if [ ! -d $log_dir ]; then
    mkdir $log_dir
fi

LOG_FILE="${log_dir}/${SHELL_SCRIPT_NAME}_${filenametime}.log"
exec > >(tee "$LOG_FILE") 2>&1
cd "Remove_Containers_and_AWS_Artifacts/"

# Each section below consists of running a certain script and removing the created artifact. 
# Please enter "n" or "no" in the prompt so that the script removes the artifacts accordingly. 
# The reason the prompts exist are in case you've already removed that particular artifact, giving
# you the choice to skip it where necessary. In that case, enter "y" or "yes" to skip that step

read -p "Have you removed the Athena table yet? [y/n] " continue
case $continue in 
    "n"|"no"|"N"|"NO"|"No"|"nO")
    echo "Removing Athena table"
    sleep 3
    chmod +x remove_athena_table.sh
    ./remove_athena_table.sh
    RC1=$?
    if [ $RC1 != 0 ]; then
        echo "Failed to remove the Athena table"
        echo "[ERROR:] RETURN CODE:  $RC1"
        echo "[ERROR:] REFER TO THE LOG FOR THE REASON FOR THE FAILURE."
        exit 1
    else
        echo "Athena table removed"
    fi
;;
esac

read -p "Have you removed the Athena database yet? [y/n] " continue
case $continue in 
    "n"|"no"|"N"|"NO"|"No"|"nO")
    echo "Removing Athena database"
    sleep 3
    chmod +x remove_athena_database.sh
    ./remove_athena_database.sh
    RC1=$?
    if [ $RC1 != 0 ]; then
        echo "Failed to remove the Athena database"
        echo "[ERROR:] RETURN CODE:  $RC1"
        echo "[ERROR:] REFER TO THE LOG FOR THE REASON FOR THE FAILURE."
        exit 1
    else
        echo "Athena database removed"
    fi
;;
esac

read -p "Have you removed the S3 bucket yet? [y/n] " continue
case $continue in 
    "n"|"no"|"N"|"NO"|"No"|"nO")
    echo "Removing the S3 bucket"
    sleep 3
    chmod +x remove_s3_buckets.py
    python3 remove_s3_buckets.py
    RC1=$?
    if [ $RC1 != 0 ]; then
        echo "Failed to remove the S3 bucket"
        echo "[ERROR:] RETURN CODE:  $RC1"
        echo "[ERROR:] REFER TO THE LOG FOR THE REASON FOR THE FAILURE."
        exit 1
    else
        echo "S3 bucket removed"
    fi
;;
esac

read -p "Have you removed the EC2 instance profile yet? [y/n] " continue
case $continue in 
    "n"|"no"|"N"|"NO"|"No"|"nO")
    echo "Removing EC2 instance profile"
    sleep 3
    chmod +x remove_ec2_instance_profile.sh
    ./remove_ec2_instance_profile.sh
    RC1=$?
    if [ $RC1 != 0 ]; then
        echo "Failed to remove the EC2 instance profile"
        echo "[ERROR:] RETURN CODE:  $RC1"
        echo "[ERROR:] REFER TO THE LOG FOR THE REASON FOR THE FAILURE."
        exit 1
    else
        echo "EC2 instance profile removed"
    fi
;;
esac

read -p "Have you removed the docker containers yet? [y/n] " continue
case $continue in 
    "n"|"no"|"N"|"NO"|"No"|"nO")
    echo "Removing docker containers"
    sleep 3
    chmod +x remove_docker_containers.sh
    ./remove_docker_containers.sh
    RC1=$?
    if [ $RC1 != 0 ]; then
        echo "Failed to remove the docker containers"
        echo "[ERROR:] RETURN CODE:  $RC1"
        echo "[ERROR:] REFER TO THE LOG FOR THE REASON FOR THE FAILURE."
        exit 1
    else
        echo "Docker containers removed"
    fi
;;
esac