# Project Env
. $(dirname $0)/env.sh

# Determine Tag
IMAGE_NAME=$PROJ_NAME

# Remove all tagged images but retaining latest
docker image rm $(docker image ls | grep ^$IMAGE_NAME | grep -v latest | awk '{print $1":"$2}')
