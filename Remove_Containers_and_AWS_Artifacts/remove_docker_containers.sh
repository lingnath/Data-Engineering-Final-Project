#!/bin/bash

# Stopping all the containers for this project in the specific order (due to link dependencies)
docker stop superset
docker stop connect
docker stop kafka
docker stop zookeeper
docker stop nifi
docker stop mysql
# Removing all the containers for this project
docker rm superset connect kafka zookeeper nifi mysql