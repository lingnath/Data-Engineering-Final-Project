#!/bin/bash

# Install the mysql to java connector jar file inside of the nifi container
mkdir custom-jars
cd custom-jars
wget http://java2s.com/Code/JarDownload/mysql/mysql-connector-java-5.1.17-bin.jar.zip
unzip mysql-connector-java-5.1.17-bin.jar.zip
