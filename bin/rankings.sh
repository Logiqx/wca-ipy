time docker run -it --rm \
         --mount type=bind,src=/c/Projects/WCA/wca-ipy/data,dst=/home/jovyan/work/wca-ipy/data \
         --mount type=bind,src=/c/Projects/WCA/wca-ipy/docs,dst=/home/jovyan/work/wca-ipy/docs \
         --network=wca_default -w /home/jovyan/work/wca-ipy/python wca-ipy ./Partial_Rankings.py

echo; time docker run -it --rm \
         --mount type=bind,src=/c/Projects/WCA/wca-ipy/data,dst=/home/jovyan/work/wca-ipy/data \
         --mount type=bind,src=/c/Projects/WCA/wca-ipy/docs,dst=/home/jovyan/work/wca-ipy/docs \
         --network=wca_default -w /home/jovyan/work/wca-ipy/python wca-ipy ./Indicative_Rankings.py

echo; time docker run -it --rm \
         --mount type=bind,src=/c/Projects/WCA/wca-ipy/data,dst=/home/jovyan/work/wca-ipy/data \
         --mount type=bind,src=/c/Projects/WCA/wca-ipy/docs,dst=/home/jovyan/work/wca-ipy/docs \
         --network=wca_default -w /home/jovyan/work/wca-ipy/python wca-ipy ./Representative_Rankings.py

echo; time docker run -it --rm \
         --mount type=bind,src=/c/Projects/WCA/wca-ipy/data,dst=/home/jovyan/work/wca-ipy/data \
         --mount type=bind,src=/c/Projects/WCA/wca-ipy/docs,dst=/home/jovyan/work/wca-ipy/docs \
         --network=wca_default -w /home/jovyan/work/wca-ipy/python wca-ipy ./Percentile_Rankings.py
