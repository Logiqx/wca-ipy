# Project Env
. $(dirname $0)/env.sh

# Explanation at https://www.peterbe.com/plog/set-ex
set -ex

# Refresh Rankings
run_py_script Senior_Rankings.py
run_py_script Partial_Rankings.py
run_py_script Indicative_Rankings.py
run_py_script Representative_Rankings.py
run_py_script Percentile_Rankings.py
