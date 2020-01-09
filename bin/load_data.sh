# Project Env
. $(dirname $0)/env.sh

# Load Seniors
run_py_script Create_Lookup_Tables.py
run_py_script Load_Seniors.py

# Load Stats
run_py_script Load_Senior_Stats.py
