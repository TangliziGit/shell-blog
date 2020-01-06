echo "[$(date)] start sync"
cd "$(dirname "$0")"/.. 
git pull --rebase
util/ci/rename.sh
