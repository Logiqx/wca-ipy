# Project Env
. $(dirname $0)/env.sh

# Explanation at https://www.peterbe.com/plog/set-ex
set -ex

# Refresh Comps
run_py_script Future_Competitions.py
