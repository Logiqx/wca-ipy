export PROJ_DIR=$(realpath $(dirname $0)/..)
export PROJ_NAME=$(basename $PROJ_DIR)
export WORK_DIR=/home/jovyan/work/$PROJ_NAME

run_py_script()
{
  docker run -it --rm \
         --mount type=bind,src=$PROJ_DIR/data,dst=$WORK_DIR/data \
         --mount type=bind,src=$PROJ_DIR/docs,dst=$WORK_DIR/docs \
         --mount type=bind,src=$(realpath $PROJ_DIR/.my.cnf),dst=/home/jovyan/.my.cnf \
         -e MYSQL_DATABASE=${MYSQL_DATABASE:-wca_ipy} \
         -e MYSQL_USER=${MYSQL_USER:-wca_ipy} \
         --network=wca_default -w $WORK_DIR/python ${PROJ_NAME}:${IMAGE_TAG:-latest} ./$1
}

# Explanation at https://www.peterbe.com/plog/set-ex
set -ex

cd $PROJ_DIR
