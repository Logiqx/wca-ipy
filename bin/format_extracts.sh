# Project Env
. $(dirname $0)/env.sh

# Explanation at https://www.peterbe.com/plog/set-ex
set -ex

# Format Extracts
run_py_script Create_Extracts.py
run_py_script Format_Extracts.py
