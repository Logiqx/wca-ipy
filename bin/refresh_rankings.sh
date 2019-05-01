docker exec wca_notebook_1 sh -c "cd work/wca-ipy/python; ./Format_Extracts.py"
docker exec wca_notebook_1 sh -c "cd work/wca-ipy/python; ./Partial_Rankings.py"
docker exec wca_notebook_1 sh -c "cd work/wca-ipy/python; ./Percentile_Rankings.py"
docker exec wca_notebook_1 sh -c "cd work/wca-ipy/python; ./Senior_Rankings.py"
