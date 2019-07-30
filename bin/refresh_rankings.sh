# Determine the container ID in a way that works with Docker Compose and Docker Swarm
CONTAINER=$(docker ps -q -f name=wca_notebook)

# Location of Jupyter Notebooks
PYTHON_DIR=work/wca-ipy/python

# Run all of the scripts back-to-back
time docker exec $CONTAINER sh -c "cd $PYTHON_DIR; jupyter nbconvert --to notebook --execute --inplace Partial_Rankings.ipynb"
echo
time docker exec $CONTAINER sh -c "cd $PYTHON_DIR; jupyter nbconvert --to notebook --execute --inplace Indicative_Rankings.ipynb"
echo
time docker exec $CONTAINER sh -c "cd $PYTHON_DIR; jupyter nbconvert --to notebook --execute --inplace Senior_Rankings.ipynb"
echo
time docker exec $CONTAINER sh -c "cd $PYTHON_DIR; jupyter nbconvert --to notebook --execute --inplace Percentile_Rankings.ipynb"
echo
time docker exec $CONTAINER sh -c "cd $PYTHON_DIR; jupyter nbconvert --to notebook --execute --inplace Future_Competitions.ipynb"
