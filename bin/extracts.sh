time docker run -it --rm \
         --mount type=bind,src=/c/Projects/WCA/wca-ipy/data,dst=/home/jovyan/work/wca-ipy/data \
         --mount type=bind,src=/c/Projects/WCA/wca-db/docker/mysql/.my.cnf,dst=/home/jovyan/.my.cnf \
         --network=wca_default -w /home/jovyan/work/wca-ipy/python wca-ipy ./Format_Extracts.py
