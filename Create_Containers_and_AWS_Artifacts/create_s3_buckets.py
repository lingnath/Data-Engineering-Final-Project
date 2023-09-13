import os
import boto3
from dotenv import load_dotenv
import toml

# Loading the variables from the .env and config_file.toml respectively
load_dotenv('../.env')
app_config = toml.load('../config_file.toml')
s3_bucket = app_config['aws']['s3_bucket']
aws_region = app_config['aws']['region']
ACCESS_KEY = os.getenv('ACCESS_KEY')
SECRET_KEY = os.getenv('SECRET_KEY')

# Creating the boto3 session
session = boto3.Session(
    aws_access_key_id=ACCESS_KEY,
    aws_secret_access_key=SECRET_KEY
)

s3 = session.resource('s3')
s3_client = session.client('s3')

# Create bucket
s3_client.create_bucket(
    Bucket=s3_bucket,  
    CreateBucketConfiguration={'LocationConstraint': aws_region} 
)

# Create folders within the bucket
folders = ['checkpoints/', 'output/', 'superset_metadata/', 'athena_metadata/']
for folder in folders:
    s3_client.put_object(
        Bucket=s3_bucket,
        Key=(folder))

# Upload the json schema to the bucket
s3_client.upload_file('bus_status_schema.json', s3_bucket, 'artifacts/bus_status_schema.json')
