export PROJ_DIR=$(realpath $(dirname $0)/..)
export CONTAINER=$(basename $PROJ_DIR)
export WORK_DIR=/home/jovyan/work/$CONTAINER

run_py_script()
{
  echo "Running $1..."
  docker run -it --rm \
         --mount type=bind,src=$PROJ_DIR/data,dst=$WORK_DIR/data \
         --mount type=bind,src=$PROJ_DIR/docs,dst=$WORK_DIR/docs \
         --mount type=bind,src=$(realpath $PROJ_DIR/../wca-db/docker/mysql/.my.cnf),dst=/home/jovyan/.my.cnf \
         --network=wca_default -w $WORK_DIR/python $CONTAINER ./$1
}
