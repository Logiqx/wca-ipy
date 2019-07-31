# Determine the container ID in a way that works with Docker Compose and Docker Swarm
CONTAINER=$(docker ps -q -f name=wca_notebook)

# Location of Jupyter Notebooks
PYTHON_DIR=work/wca-ipy/python

# Run the script
time docker exec $CONTAINER sh -c "cd $PYTHON_DIR; jupyter nbconvert --ExecutePreprocessor.timeout=600 --to notebook --execute --inplace Future_Competitions.ipynb"
