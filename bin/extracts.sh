# Determine the container ID in a way that works with Docker Compose and Docker Swarm
CONTAINER=$(docker ps -q -f name=wca_notebook)

# Location of Jupyter Notebooks
PYTHON_DIR=work/wca-ipy/python

# Run all of the scripts back-to-back
time docker exec $CONTAINER sh -c "cd $PYTHON_DIR; jupyter nbconvert --ExecutePreprocessor.timeout=120 --to notebook --execute --inplace Format_Extracts.ipynb"
