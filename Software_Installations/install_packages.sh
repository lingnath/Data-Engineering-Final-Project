#!/bin/bash

# Please replace apt-get with yum if you are using Amazon AMI, which uses RHEL
sudo apt-get update
# Install AWS CLI
# sudo apt-get install awscli -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt-get install unzip
unzip awscliv2.zip
sudo ./aws/install
sudo apt-get install pip -y
sudo apt-get install amazon-ec2-utils -y
# Install and activate Python venv
sudo apt install python3.12-venv
python3 -m venv python_env
source python_env/bin/activate
# Install Python packages
pip3 install boto3
pip3 install python_dotenv
pip3 install toml
