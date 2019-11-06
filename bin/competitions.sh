time docker run -it --rm \
         --mount type=bind,src=/c/Projects/WCA/wca-ipy/data,dst=/home/jovyan/work/wca-ipy/data \
         --mount type=bind,src=/c/Projects/WCA/wca-ipy/docs,dst=/home/jovyan/work/wca-ipy/docs \
         --network=wca_default -w /home/jovyan/work/wca-ipy/python wca-ipy ./Future_Competitions.py
