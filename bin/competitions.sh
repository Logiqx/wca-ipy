. $(dirname $0)/env.sh

time docker run -it --rm \
         --mount type=bind,src=$PROJ_DIR/data,dst=$WORK_DIR/data \
         --mount type=bind,src=$PROJ_DIR/docs,dst=$WORK_DIR/docs \
         --network=wca_default -w $WORK_DIR/python wca-ipy-private ./Future_Competitions.py
