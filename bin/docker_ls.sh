# Project Env
. $(dirname $0)/env.sh

# Determine Tag
IMAGE_NAME=$PROJ_NAME

# List retained images
docker image ls $IMAGE_NAME
