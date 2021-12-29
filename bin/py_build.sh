# Project Env
. $(dirname $0)/env.sh

# Determine Tag
IMAGE_NAME=$PROJ_NAME
IMAGE_TAG=tmp

# Docker Build
DOCKER_BUILDKIT=1 docker build . -f Dockerfile -t $IMAGE_NAME:$IMAGE_TAG

# Copy the library scripts
docker run --rm --entrypoint cat $IMAGE_NAME:$IMAGE_TAG $WORK_DIR/python/Force_IPv4.py >$PROJ_DIR/python/Force_IPv4.py

# Clear pycache
rm -f $PROJ_DIR/python/__pycache__/*.*.pyc
