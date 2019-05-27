DIRS="data docs"

git diff --stat $DIRS
git commit -m "Refresh reports" $DIRS
git push
