#!/bin/bash

rm -rf build/
mkdir build
cd build

curl -O https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
java -jar BuildTools.jar --rev 1.10

cd ..

