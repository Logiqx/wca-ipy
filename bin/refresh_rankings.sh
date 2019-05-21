# Determine the container ID in a way that works with Docker Compose and Docker Swarm
CONTAINER=$(docker ps -q -f name=wca_notebook)

# Location of Jupyter Notebooks
PYTHON_DIR=work/wca-ipy/python

# Run all of the scripts back-to-back
docker exec $CONTAINER sh -c "cd $PYTHON_DIR; jupyter nbconvert --to notebook --execute --inplace Partial_Rankings.ipynb"
docker exec $CONTAINER sh -c "cd $PYTHON_DIR; jupyter nbconvert --to notebook --execute --inplace Senior_Rankings.ipynb"
docker exec $CONTAINER sh -c "cd $PYTHON_DIR; jupyter nbconvert --to notebook --execute --inplace Percentile_Rankings.ipynb"
