export PROJ_DIR=$(realpath $(dirname $0)/..)
export PROJ_NAME=$(basename $PROJ_DIR)
export WORK_DIR=/home/jovyan/work/$PROJ_NAME

run_py_script()
{
  IMAGE_NAME=${PROJ_NAME}
  IMAGE_TAG=${IMAGE_TAG:-latest}

  docker run -it --rm \
         --mount type=bind,src=$PROJ_DIR/data,dst=$WORK_DIR/data \
         --mount type=bind,src=$PROJ_DIR/docs,dst=$WORK_DIR/docs \
         --mount type=bind,src=$(realpath $PROJ_DIR/.my.cnf),dst=/home/jovyan/.my.cnf \
         --network=wca_default -w $WORK_DIR/python $IMAGE_NAME:$IMAGE_TAG ./$1
}

# Explanation at https://www.peterbe.com/plog/set-ex
set -ex

cd $PROJ_DIR
