#!/bin/bash -e

# remove old releases
find . ! -path . | grep -vE ".git|release.sh|.travis.yml" | xargs rm

# get released file names
curl -kLs https://github.com/phuslu/promvps/releases > promci.txt
RELEASE_TAG=promvps
RELEASE_FILE_I386=$(cat promci.txt | grep -oE "promvps_linux_386-r[0-9]+.[0-9a-z\.]+" | head -1)
RELEASE_FILE_AMD64=$(cat promci.txt | grep -oE "promvps_linux_amd64-r[0-9]+.[0-9a-z\.]+" | head -1)
rm -f promci.txt

# download releases
curl -kLs https://github.com/phuslu/promvps/releases/download/$RELEASE_TAG/$RELEASE_FILE_I386 -o $RELEASE_FILE_I386
curl -kLs https://github.com/phuslu/promvps/releases/download/$RELEASE_TAG/$RELEASE_FILE_AMD64 -o $RELEASE_FILE_AMD64

# push release
git add --all
git commit -m "[RELEASE] `date +'%Y-%m-%d %T'`" || echo "[SKIP] No changed."
git push --quiet "https://$GITHUB_TOKEN@github.com/pexcn/goproxy.git" HEAD:release
