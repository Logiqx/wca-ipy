export PROJ_DIR=$(realpath $(dirname $0)/..)

export CONTAINER=$(basename $PROJ_DIR)

export WORK_DIR=/home/jovyan/work/$CONTAINER
