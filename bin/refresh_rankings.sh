docker exec wca_notebook_1 sh -c "cd work/wca-ipy/python; jupyter nbconvert --to notebook --execute --inplace ./Format_Extracts.ipynb"
docker exec wca_notebook_1 sh -c "cd work/wca-ipy/python; jupyter nbconvert --to notebook --execute --inplace ./Percentile_Rankings.ipynb"
docker exec wca_notebook_1 sh -c "cd work/wca-ipy/python; jupyter nbconvert --to notebook --execute --inplace ./Senior_Rankings.ipynb"
docker exec wca_notebook_1 sh -c "cd work/wca-ipy/python; jupyter nbconvert --to notebook --execute --inplace ./Partial_Rankings.ipynb"
