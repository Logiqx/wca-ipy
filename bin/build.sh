. $(dirname $0)/env.sh

DOCKER_BUILDKIT=1 docker build . -t $CONTAINER:$(git rev-parse --short=12 HEAD)
docker tag $CONTAINER:$(git rev-parse --short=12 HEAD) $CONTAINER:latest
