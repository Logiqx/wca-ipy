. $(dirname $0)/env.sh

set -e

time run_py_script Partial_Rankings.py; echo
time run_py_script Indicative_Rankings.py; echo
time run_py_script Representative_Rankings.py; echo
time run_py_script Percentile_Rankings.py
