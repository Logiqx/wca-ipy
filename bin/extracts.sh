. $(dirname $0)/env.sh

time docker run -it --rm \
         --mount type=bind,src=$PROJ_DIR/data,dst=$WORK_DIR/data \
         --mount type=bind,src=$PROJ_DIR/docker/mysql/.my.cnf,dst=/home/jovyan/.my.cnf \
         --network=wca_default -w $WORK_DIR/python wca-ipy-private ./Format_Extracts.py
