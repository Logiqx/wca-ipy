# Project Env
. $(dirname $0)/env.sh

# Create Fakes
run_py_script Create_Senior_Fakes.py

# Extract Counts
run_py_script Extract_Senior_Counts.py
