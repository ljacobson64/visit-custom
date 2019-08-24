#!/bin/bash

docker run --net host \
           -v /tmp/.X11-unix:/tmp/.X11-unix \
           -e DISPLAY=$DISPLAY \
           -e XAUTHORITY=/.Xauthority \
           -v ~/.Xauthority:/.Xauthority:ro \
           visit-3.0.1-fc30 \
           /root/visit-3.0.1-fc30/visit-3.0.1-fc30/bin/visit
