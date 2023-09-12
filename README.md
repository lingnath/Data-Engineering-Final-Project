# Data-Engineering-Final-Project

## 1. Create a security group with the following inbound configurations:
  - Port 22 from MY IP
  - All traffic from MY IP
  - Port 8080 from IPb4
## 2. Create an EC2 instance with the following configurations:
  - Ubuntu
  - t2.xlarge
  - Create or use an existing key pair
  - Using security group that we created
  - 100 GB of EBS storage
## 3. Setup Folder and Files
  - Copy the files from this repository into your EC2 instance folders
  - Go into the folder and run "chmod +x *.sh" so that all shell script files are executable
  - Run the package installation files in the following order: install_packages.sh -> install_docker.sh -> install_docker_compose.sh
  - Run aws configure to set up aws account on the EC2 instance
  - Ensure the aws account user has the following policies attached
    - AmazonEC2FullAccess
    - AmazonAthenaFullAccess
    - AmazonS3FullAccess
    - IAMFullAccess
  - Create a .env file in the following format:
  <br>ACCESS_KEY=''
  <br>SECRET_KEY=''
  - Enter your credentials in the .env file
  - In the config_file.toml, enter the fields according to what you want
  - Run the create_docker_containers.sh file
  - Run the create_ec2_instance_profile.sh file
  - Attach this newly created IAM role (from create_ec2_instance_profile.sh script) to the EC2 instance you're currently running this on
## 4. Setup and Run Nifi
  - Create port forwarding for port 8080 (nifi)
  - Enter the nifi UI
  - Import the template (the xml file) into the Nifi UI
  - In ConvertJSONToSQL processor, right click it and click Configure
  - Inside the JDBC Connection Pool, press the "->" button
  - Make sure the State is enabled. If not, enable it
  - Run the following processors in Nifi UI: InvokeHTTP, ConverterJSONToSQL, PutSQL
## 5. (If necessary) Recreate Nifi DBCPConnectionPool
  - The DBCPConnectionPool may fail to work. To tell if it failed, the queue for failure, original in ConvertJSONToSQL piles up with none going to the sql route.
  - In this case, delete the DBCPConnectionPool
  - Then in ConvertJSONToSQL processor, re-enter the property for JDBC Connection Pool as "DBCPConnectionPool 1.12.0"
  - Press the "->" button
  - Click on gear icon beside the DBCPConnectionPool
  - For Database Connection URL, enter "jdbc:mysql://mysql:3306/demo"
  - For Database Driver Class Name, enter "com.mysql.jdbc.Driver"
  - For Database Driver Location(s), enter "/opt/nifi/nifi-current/custom-jars/mysql-connector-java-5.1.17-bin.jar"
  - For Database User, enter "root"
  - For Password, enter "debezium"
  - Ensure PutSQL processor is using the newly recreated DBCPConnectionPool
## 6. Check if mysql is working
  - docker exec -it mysql bash
  - mysql -u root -p
  - Enter "debezium" as password
  - use demo;
  - select * from bus_status limit 10;
## 7. Check if kafka is connected to debezium
  - docker exec -it kafka bash
  - bin/kafka-topics.sh --list --zookeeper zookeeper:2181
  - You should see the following topics: dbhistory.demo, dbserver1, dbserver1.demo.bus_status, my-connect-configs, my-connect-offsets, my_connect_statuses
  - To check if kafka consumer is receiving the changes in the mysql database, enter "bin/kafka-console-consumer.sh --topic dbserver1.demo.bus_status --bootstrap-server '{kafka container_id}':9092"
  - You should see json data come out
## 8. Setup AWS Artifacts
  - Run the following scripts in this order: create_s3_buckets.py -> install_pyspark.sh -> execute_pyspark.sh -> create_athena_database.sh -> create_athena_table.sh
## 9. Create Dashboards on Superset
  - Create a port forwarding connection for port 8088
  - Paste in [http://localhost:8088/login/](http://localhost:8088/login/) to login
  - Create a new database by entering the following to connect Superset to Athena:
awsathena+rest://{aws access key}:{aws secret access key}@athena.{aws region}.amazonaws.com/?s3_staging_dir=s3://{s3 bucket}/superset_metadata&work_group=primary
  - Add the necessary datasets in Superset
  - Build dashboards to your heart's content
## 10. Stop Streaming Project
  - For the execute_pyspark.sh script you were running in the terminal, press Ctrl+C to stop the script from running
  - For the kafka consumer you were running, also press Ctrl+C to stop the consumer from listening
  - Stop the running processes in the Nifi UI
  - Stop the running containers by running "docker stop {container name}"
## 11. (Optional) Remove AWS Artifacts
  - Once you're done with the project, run the following scripts in this order: remove_athena_table.sh -> remove_athena_database.sh -> remove_s3_buckets.py -> remove_ec2_instance_profile.sh
