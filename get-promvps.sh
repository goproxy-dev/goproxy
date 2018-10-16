#!/bin/bash

set -e

read_p=$(test -n "$BASH_VERSION" && echo 'read -ep' || echo 'read -p')

linkpath=$(ls -l "$0" 2>/dev/null | sed "s/.*->\s*//")
cd "$(dirname "$0")" && test -f "$linkpath" && cd "$(dirname "$linkpath")" || true

if ! pidof promvps >/dev/null; then
    if ss -v >/dev/null 2>&1; then
        if ss -anptl | grep -q ':443 '; then
            echo -e "\e[1;31mtcp port 443 already used, please shutdown 443 port in webserver(nginx/apache) config.\e[0m"
            exit 1
        fi
    fi
fi

if [ "$(/bin/ls -ld promvps* 2>/dev/null | grep -c '^-')" = "0" ]; then
    mkdir -p promvps
    cd promvps
fi

FILENAME_PREFIX=
case $(uname -s)/$(uname -m) in
    Linux/x86_64 )
        FILENAME_PREFIX=promvps_linux_amd64
        ;;
    Linux/i686|Linux/i386 )
        FILENAME_PREFIX=promvps_linux_386
        ;;
    Linux/aarch64|Linux/arm64 )
        FILENAME_PREFIX=promvps_linux_arm64
        ;;
    Linux/arm* )
        FILENAME_PREFIX=promvps_linux_arm
        if grep -q ld-linux-armhf.so ./promvps 2>/dev/null; then
            FILENAME_PREFIX=promvps_linux_arm_cgo
        fi
        ;;
    Linux/mips64el )
        FILENAME_PREFIX=promvps_linux_mips64le
        ;;
    Linux/mips64 )
        FILENAME_PREFIX=promvps_linux_mips64
        ;;
    Linux/mipsel )
        FILENAME_PREFIX=promvps_linux_mipsle
        ;;
    Linux/mips )
        FILENAME_PREFIX=promvps_linux_mips
        ;;
    FreeBSD/x86_64 )
        FILENAME_PREFIX=promvps_freebsd_amd64
        ;;
    FreeBSD/i686|FreeBSD/i386 )
        FILENAME_PREFIX=promvps_freebsd_386
        ;;
    Darwin/x86_64 )
        FILENAME_PREFIX=promvps_darwin_amd64
        ;;
    Darwin/i686|Darwin/i386 )
        FILENAME_PREFIX=promvps_darwin_386
        ;;
    Windows_NT/x86_64 )
        FILENAME_PREFIX=promvps_windows_amd64
        ;;
    Windows_NT/i686 )
        if test -d "C:\\Program Files (x86)"; then
            FILENAME_PREFIX=promvps_windows_amd64
        else
            FILENAME_PREFIX=promvps_windows_386
        fi
        ;;
    * )
        echo "Unsupported platform: $(uname -a)"
        exit 1
        ;;
esac

trap 'rm -rf promci.txt *.tmp; exit' SIGINT SIGQUIT

LOCALVERSION=$(./promvps -version 2>/dev/null || :)
echo "0. Local Prom VPS version ${LOCALVERSION}"

echo "1. Checking Prom VPS Version"
# curl -kL https://bitbucket.org/phuslu/promvps/downloads/ >promci.txt
curl -kL https://github.com/phuslu/promvps/releases >promci.txt
# RELEASETAG=$(cat promci.txt | grep -m1 -oE 'promci/releases/tag/[0-9A-Za-z]+' | awk -F/ '{print $NF}')
RELEASETAG=promvps
FILENAME=$(cat promci.txt | grep -oE "${FILENAME_PREFIX}-r[0-9]+.[0-9a-z\.]+" | head -1)
REMOTEVERSION=$(echo ${FILENAME} | awk -F'.' '{print $1}' | awk -F'-' '{print $2}')
rm -rf promci.txt
if [ -z "${REMOTEVERSION}" ]; then
    echo "Cannot detect ${FILENAME_PREFIX} version"
    exit 1
fi

if [[ ${LOCALVERSION#r*} -ge ${REMOTEVERSION#r*} ]]; then
    echo "Your Prom already update to latest"
    exit 1
fi

echo "2. Downloading ${FILENAME}"
# curl -kL https://bitbucket.org/phuslu/promvps/downloads/${FILENAME} >${FILENAME}.tmp
curl -kL -# https://github.com/phuslu/promvps/releases/download/${RELEASETAG}/${FILENAME} >${FILENAME}.tmp
mv -f ${FILENAME}.tmp ${FILENAME}

echo "3. Extracting ${FILENAME}"
rm -rf ${FILENAME%.*}
case ${FILENAME##*.} in
    xz )
        xz -d ${FILENAME}
        ;;
    bz2 )
        bzip2 -d ${FILENAME}
        ;;
    gz )
        gzip -d ${FILENAME}
        ;;
    * )
        echo "Unsupported archive format: ${FILENAME}"
        exit 1
esac

tar -xvpf ${FILENAME%.*} --strip-components $(tar -tf ${FILENAME%.*} | head -1 | grep -c '/')
rm -f ${FILENAME%.*}

if [ "$(uname -s)" = "Windows_NT" ]; then
    exit 0
fi

sed -i -r "s#DIRECTORY=.+?#DIRECTORY=$(pwd)#" promvps.sh

if [ ! -f production.toml ]; then
    echo "4. Configure promvps"

    $read_p "Please input your domain: " server_name </dev/tty

    cat <<EOF >production.toml
[default]
dial_timeout = 30
dns_ttl = 900

[log]
level = 'info'
stderr = false
backups = 2
maxsize = 1073741824
localtime = true
rotate = 'daily'

[[http2]]
listen = ':443'
server_name = ['${server_name}']
proxy_pass = 'http://127.0.0.1:80'
#auth_command = './auth --servername {servername} --username {username} --password {password} --remote {remote}'
EOF
    echo 'ENV=production' | tee .env
fi

echo
action=$(pgrep promvps >/dev/null && echo restart || echo start)
echo "Please run \"sudo ./promvps.sh ${action}\""
