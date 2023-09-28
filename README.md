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
  - Go into the Software_Installations folder and run "chmod +x *.sh" so that all shell script files are executable
  - Run the software installation files in the following order: install_packages.sh -> install_docker.sh -> install_pyspark.sh
  - Run aws configure to set up aws account on the EC2 instance
    - AWS Access Key ID [None]: {access key}
    - AWS Secret Access Key [None]: {secret access key}
    - Default region name [None]: {aws region your EC2 is in}
    - Default output format [None]: json
  - Ensure the aws account user has the following policies attached
    - AmazonEC2FullAccess
    - AmazonAthenaFullAccess
    - AmazonS3FullAccess
    - IAMFullAccess
  - In the main folder, create a .env file in the following format:
  <br>ACCESS_KEY=''
  <br>SECRET_KEY=''
  - Enter your credentials in the .env file
  - In the config_file.toml, enter the fields according to what you want
  - (Optional) In Superset there is an option to create a map such that you can render streets and other cool features in your dashboard. This is possible since we have geodata (longitude and latitude) in our dataset. To do this, you need to create a mapbox account and create an access token.
    - To do so, go to this website: https://account.mapbox.com/
    - Create an account (if you haven't done so already)
    - Generate an access token
    - In the create_docker_containers.sh file, under the "docker run superset" line, enter the access token beside the MAPBOX_API_KEY and **MAKE SURE** the double quotes are not erased.
## 4. Create Docker Containers and AWS Artifacts
  - Go to Create_Containers_and_AWS_Artifacts folder and run "chmod +x *.sh" so that all shell script files are executable
  - Run create_all_artifacts.sh script
## 5. Check if mysql is working
  - docker exec -it mysql bash
  - mysql -u root -p
  - Enter "debezium" as password
  - use demo;
  - select * from bus_status limit 10;
  - If the demo database does not exist, this means the set_up_mysql.sh failed to run in the container, likely due to connection issues
    - In this case, run the following scripts again:
      - docker cp set_up_mysql.sh mysql:/set_up_mysql.sh
      - docker exec mysql ./set_up_mysql.sh
    - Go into the mysql container and check if the demo database and the bus_status table exists. It should work this time.
## 6. Setup and Run Nifi
  - Create a port forwarding connection for port 8080 (nifi)
  - Enter the nifi UI
  - Import the template (the xml file) into the Nifi UI and select the imported template. You should see a Nifi workflow.
  - In ConvertJSONToSQL processor, right click it and click Configure
  - Go to Properties tab
  - At the value beside the JDBC Connection Pool, press the "->" button
  - Click on gear icon beside the DBCPConnectionPool
  - Go to Properties tab
  - For Password, enter "debezium"
  - Make sure the State for this connection pool is enabled. If not, enable it.
  - Run the following processors in Nifi UI: InvokeHTTP, ConverterJSONToSQL, PutSQL
  - The DBCPConnectionPool may fail to work. 
    - To tell if it failed, the queue for failure, original in ConvertJSONToSQL piles up with none going to the sql route.
    - In this case, delete the DBCPConnectionPool
    - Then in ConvertJSONToSQL processor, re-enter the property for JDBC Connection Pool as "DBCPConnectionPool 1.12.0"
    - Press the "->" button
    - Click on gear icon beside the DBCPConnectionPool
    - Go to Properties tab
    - For Database Connection URL, enter "jdbc:mysql://mysql:3306/demo"
    - For Database Driver Class Name, enter "com.mysql.jdbc.Driver"
    - For Database Driver Location(s), enter "/opt/nifi/nifi-current/custom-jars/mysql-connector-java-5.1.17-bin.jar"
    - For Database User, enter "root"
    - For Password, enter "debezium"
    - Enable this connection pool
    - Ensure ConvertJSONToSQL and PutSQL processors are using the newly recreated DBCPConnectionPool
    - Re-run the following processors in Nifi UI: InvokeHTTP, ConverterJSONToSQL, PutSQL
## 7. Check if kafka is connected to debezium
  - docker exec -it kafka bash
  - bin/kafka-topics.sh --list --zookeeper zookeeper:2181
  - You should see the following topics: dbhistory.demo, dbserver1, dbserver1.demo.bus_status, my-connect-configs, my-connect-offsets, my_connect_statuses
  - To check if kafka consumer is receiving the changes in the mysql database, enter "bin/kafka-console-consumer.sh --topic dbserver1.demo.bus_status --bootstrap-server '{kafka container_id}':9092"
  - You should see json data come out
## 8. Execute Streaming Script in Pyspark
  - In the main folder, run "chmod +x *.sh" so that the shell scripts are executable
  - Run execute_pyspark.sh
## 9. Create Dashboards on Superset
  - Create a port forwarding connection for port 8088
  - Paste in [http://localhost:8088/login/](http://localhost:8088/login/) to login
  - Create a new database by entering the following to connect Superset to Athena:
awsathena+rest://{aws access key}:{aws secret access key}@athena.{aws region}.amazonaws.com/?s3_staging_dir=s3://{s3 bucket}/superset_metadata&work_group=primary
  - Add the necessary datasets in Superset
  - In Superset to deduplicate the athena dataset, do the following:
    - Run the following sql query found in dedup_bus_status_table.sql file
    - Save the results as a virtual dataset
  - Build dashboards to your heart's content based on the deduplicated virtual dataset we just created
## 10. Stop Streaming Project
  - For the execute_pyspark.sh script you were running in the terminal, press Ctrl+c to stop the script from running
  - For the kafka consumer you were running, also press Ctrl+c to stop the consumer from listening
  - Stop the running processes in the Nifi UI
  - Stop the running containers by running "docker stop $(docker ps -a -q)"
## 11. (Optional) Remove Docker Containers and AWS Artifacts
  - Go to Remove_Containers_and_AWS_Artifacts folder and run "chmod +x *.sh" so that all shell script files are executable
  - Run remove_all_artifacts.sh script
