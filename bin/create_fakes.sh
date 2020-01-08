# Project Env
. $(dirname $0)/env.sh

# Explanation at https://www.peterbe.com/plog/set-ex
set -ex

# Create Fakes
run_py_script Create_Senior_Fakes.py
