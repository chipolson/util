#!/bin/bash

WD=`echo $PWD | sed 's/\/Users/\/home/'`

docker run -it --mount type=bind,source=$HOME/dev,target=/home/colson/dev \
-w $WD \
--volumes-from=ssh-agent \
-e SSH_AUTH_SOCK=/.ssh-agent/socket \
-e TZ=America/New_York \
colson/dev:latest "$@"
