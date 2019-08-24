#!/bin/bash

set -e

image_name=visit-3.0.1-fc30
container_name=temp-container
tarball=visit3_0_1.linux-x86_64.tar.gz
tarball_path=/root/visit-3.0.1-fc30/build/visit3.0.1/build/${tarball}

docker build .
docker tag `docker images -q | head -n1` ${image_name}
docker run --name ${container_name} ${image_name} /bin/true
docker cp ${container_name}:${tarball_path} ${tarball}
docker rm ${container_name}
