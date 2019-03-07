#!/bin/bash

cp -r ../cosbench cos

docker build -f Dockerfile-driver -t cosbench:driver .
docker save cosbench:driver > cosbench-driver.tar

docker build -f Dockerfile-controller -t cosbench:controller .
docker save cosbench:controller > cosbench-controller.tar

rm -rf cos
