. $(dirname $0)/env.sh

set -e

cd $PROJ_DIR

DOCKER_BUILDKIT=1 docker build . -t $PROJ_NAME:$(git rev-parse --short=12 HEAD)
docker tag $PROJ_NAME:$(git rev-parse --short=12 HEAD) $PROJ_NAME:latest
