docker exec wca_notebook_1 sh -c "cd work/wca-ipy/python; jupyter nbconvert --ExecutePreprocessor.timeout=300 --to notebook --execute --inplace Download_Database.ipynb"
