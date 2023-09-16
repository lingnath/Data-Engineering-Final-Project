#!/bin/bash

# ONLY run this once. The next time you want to start these containers, please insert "docker start <container name>" instead

# Create mysql container
docker run -dit --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=debezium -e MYSQL_USER=mysqluser -e MYSQL_PASSWORD=mysqlpw debezium/example-mysql:1.6
# I decided to stop and start the container again so that the error 
# Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock' can be minimized
echo "Rebooting and giving mysql container time to run to minimize chances of connection errors. Please wait for 30-35 seconds."
sleep 10
docker stop mysql
sleep 10
docker start mysql
sleep 10
# Set up mysql container with the database and table creation
chmod +x set_up_mysql.sh
docker cp set_up_mysql.sh mysql:/set_up_mysql.sh
docker exec mysql ./set_up_mysql.sh
# Create nifi container
docker run --name nifi -p 8080:8080 -p 8443:8443 --link mysql:mysql -d apache/nifi:1.12.0
# Give the nifi container a few seconds to run so that we can avoid errors
echo "Giving 10 seconds for nifi container to boot up"
sleep 10
# Set up nifi container
chmod +x set_up_nifi.sh
docker cp set_up_nifi.sh nifi:/opt/nifi/nifi-current/set_up_nifi.sh
docker exec nifi ./set_up_nifi.sh
# Create zookeeper container
docker run -dit --name zookeeper -p 2181:2181 -p 2888:2888 -p 3888:3888 debezium/zookeeper:1.6
# Create kafka container
docker run -dit --name kafka -p 9092:9092 --link zookeeper:zookeeper debezium/kafka:1.6
# Create debezium connect container
docker run -dit --name connect -p 8083:8083 -e GROUP_ID=1 -e CONFIG_STORAGE_TOPIC=my-connect-configs -e OFFSET_STORAGE_TOPIC=my-connect-offsets -e STATUS_STORAGE_TOPIC=my_connect_statuses --link zookeeper:zookeeper --link kafka:kafka --link mysql:mysql debezium/connect:1.6
# Give the debezium connect container a few seconds to run so that we can avoid errors
echo "Giving 10 seconds for debezium connect container to boot up"
sleep 10
# Create mysql debezium connector for Kafka
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{ "name": "inventory-connector", "config": { "connector.class": "io.debezium.connector.mysql.MySqlConnector", "tasks.max": "1", "database.hostname": "mysql", "database.port": "3306", "database.user": "debezium", "database.password": "dbz", "database.server.id": "184054", "database.server.name": "dbserver1", "database.include.list": "demo", "database.history.kafka.bootstrap.servers": "kafka:9092", "database.history.kafka.topic": "dbhistory.demo" } }'
# Create superset container
docker pull stantaov/superset-athena:0.0.1
# Setting the port to be 8088 so that it doesn't conflict with port 8080 that Nifi runs on
docker run -d -e MAPBOX_API_KEY="" -p 8088:8088 --name superset stantaov/superset-athena:0.0.1
docker exec -it superset superset fab create-admin \
               --username admin \
               --firstname Superset \
               --lastname Admin \
               --email admin@superset.com \
               --password admin
docker exec -it superset superset db upgrade
docker exec -it superset superset init
