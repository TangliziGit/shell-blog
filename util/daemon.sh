echo "[$(date)] start sync"
cd "$(dirname "$0")"/.. 
git pull --rebase
bash util/ci/rename.sh
bash util/ci/rss.sh
