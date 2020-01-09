# Project Env
. $(dirname $0)/env.sh

# Determine Tag
IMAGE_NAME=$PROJ_NAME
IMAGE_TAG=$(git rev-parse --short=12 HEAD)

# Docker Build
DOCKER_BUILDKIT=1 docker build . --build-arg LOGIQX_DEBUG -t $IMAGE_NAME:$IMAGE_TAG

# Test database
MYSQL_DATABASE=wca_ipy_tst
MYSQL_USER=wca_ipy_tst

# Create Fakes
run_py_script Create_Senior_Fakes.py

# Format Extracts
run_py_script Create_Extracts.py
run_py_script Format_Extracts.py

# Refresh Rankings
run_py_script Senior_Rankings.py
run_py_script Indicative_Rankings.py
run_py_script Partial_Rankings.py
run_py_script Percentile_Rankings.py
run_py_script Representative_Rankings.py

# Docker Tag
docker tag $IMAGE_NAME:$IMAGE_TAG $IMAGE_NAME:latest
