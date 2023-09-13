import os
import boto3
from dotenv import load_dotenv
import toml

# Loading config toml file and .env file to gather the variables from the respective files
load_dotenv('../.env')
app_config = toml.load('../config_file.toml')
s3_bucket = app_config['aws']['s3_bucket']

ACCESS_KEY = os.getenv('ACCESS_KEY')
SECRET_KEY = os.getenv('SECRET_KEY')

# Creating boto3 session for S3
session = boto3.Session(
    aws_access_key_id=ACCESS_KEY,
    aws_secret_access_key=SECRET_KEY
)

s3 = session.resource('s3')
s3_client = session.client('s3')

# Removing S3 bucket, including all the files and folders within
bucket = s3.Bucket(s3_bucket)
bucket_versioning = s3.BucketVersioning(s3_bucket)
if bucket_versioning.status == 'Enabled':
    bucket.object_versions.delete()
else:
    bucket.objects.all().delete()
response = bucket.delete()