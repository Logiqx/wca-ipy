# Determine the container ID in a way that works with Docker Compose and Docker Swarm
CONTAINER=$(docker ps -q -f name=wca_notebook)

# Location of Jupyter Notebooks
PYTHON_DIR=work/wca-ipy/python

# Run the download script
docker exec $CONTAINER sh -c "cd $PYTHON_DIR; jupyter nbconvert --ExecutePreprocessor.timeout=300 --to notebook --execute --inplace Download_Database.ipynb"
