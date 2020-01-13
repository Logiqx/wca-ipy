# Project Env
. $(dirname $0)/env.sh

# Refresh Rankings
run_py_script Senior_Rankings.py

# Refresh Competitions
run_py_script Recent_Competitions.py
