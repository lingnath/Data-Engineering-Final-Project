#!/bin/bash

# Creates the log directory and logfiles within
filenametime=$(date +"%m%d%Y%H%M%S")
cd ..
log_dir="logs"
SHELL_SCRIPT_NAME='create_aws_artifacts'

if [ ! -d $log_dir ]; then
    mkdir $log_dir
fi

LOG_FILE="${log_dir}/${SHELL_SCRIPT_NAME}_${filenametime}.log"
exec > >(tee "$LOG_FILE") 2>&1
cd "Create_Containers_and_AWS_Artifacts/"

# Each section below consists of running a certain script and creating a new artifact. 
# Please enter "n" or "no" in the prompt so that the script creates the artifacts accordingly. 
# The reason the prompts exist are in case you've already created that particular artifact, giving
# you the choice to skip it where necessary. In that case, enter "y" or "yes" to skip that step

read -p "Have you created the docker containers yet? [y/n] " continue
case $continue in 
    "n"|"no"|"N"|"NO"|"No"|"nO")
    echo "Creating the docker containers"
    sleep 3
    chmod +x create_docker_containers.sh
    ./create_docker_containers.sh
    RC1=$?
    if [ $RC1 != 0 ]; then
        echo "Failed to create the docker containers"
        echo "[ERROR:] RETURN CODE:  $RC1"
        echo "[ERROR:] REFER TO THE LOG FOR THE REASON FOR THE FAILURE."
        exit 1
    else
        echo "Docker containers created"
    fi
;;
esac

read -p "Have you created the EC2 instance profile yet? [y/n] " continue
case $continue in 
    "n"|"no"|"N"|"NO"|"No"|"nO")
    echo "Creating the EC2 instance profile"
    sleep 3
    chmod +x create_ec2_instance_profile.sh
    ./create_ec2_instance_profile.sh
    RC1=$?
    if [ $RC1 != 0 ]; then
        echo "Failed to create the EC2 instance profile"
        echo "[ERROR:] RETURN CODE:  $RC1"
        echo "[ERROR:] REFER TO THE LOG FOR THE REASON FOR THE FAILURE."
        exit 1
    else
        echo "EC2 instance profile created"
    fi
;;
esac

read -p "Have you created the S3 bucket yet? [y/n] " continue
case $continue in 
    "n"|"no"|"N"|"NO"|"No"|"nO")
    echo "Creating the S3 bucket and folders within"
    sleep 3
    chmod +x create_s3_buckets.py
    python3 create_s3_buckets.py
    RC1=$?
    if [ $RC1 != 0 ]; then
        echo "Failed to create the S3 bucket"
        echo "[ERROR:] RETURN CODE:  $RC1"
        echo "[ERROR:] REFER TO THE LOG FOR THE REASON FOR THE FAILURE."
        exit 1
    else
        echo "S3 bucket created"
    fi
;;
esac

read -p "Have you created the Athena database yet? [y/n] " continue
case $continue in 
    "n"|"no"|"N"|"NO"|"No"|"nO")
    echo "Creating the Athena database"
    sleep 3
    chmod +x create_athena_database.sh
    ./create_athena_database.sh
    RC1=$?
    if [ $RC1 != 0 ]; then
        echo "Failed to create the Athena database"
        echo "[ERROR:] RETURN CODE:  $RC1"
        echo "[ERROR:] REFER TO THE LOG FOR THE REASON FOR THE FAILURE."
        exit 1
    else
        echo "Athena database created"
    fi
;;
esac

read -p "Have you created the Athena table yet? [y/n] " continue
case $continue in 
    "n"|"no"|"N"|"NO"|"No"|"nO")
    echo "Creating the Athena table"
    sleep 3
    chmod +x create_athena_table.sh
    ./create_athena_table.sh
    RC1=$?
    if [ $RC1 != 0 ]; then
        echo "Failed to create the Athena table"
        echo "[ERROR:] RETURN CODE:  $RC1"
        echo "[ERROR:] REFER TO THE LOG FOR THE REASON FOR THE FAILURE."
        exit 1
    else
        echo "Athena table created"
    fi
;;
esac
