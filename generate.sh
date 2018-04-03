#!/usr/bin/env bash

# IMPORTANT
# Protect against mispelling a var and rm -rf /
set -u
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DIST=${DIR}/dist
SYSROOT=${SRC}/sysroot

mkdir -p ${DIST}/
rsync -a deb-src/ ${DIR}/src/

find ${DIR}/src/ -type d -exec chmod 0755 {} \;
find ${DIR}/src/ -type f -exec chmod go-w {} \;

let SIZE=`du -s ${SYSROOT} | sed s'/\s\+.*//'`+8

pushd ${SYSROOT}/
tar czf ${DIST}/data.tar.gz [a-z]*
popd

sed s"/SIZE/${SIZE}/" -i ${DEBIAN}/control

pushd ${DEBIAN}
tar czf ${DIST}/control.tar.gz *
popd

pushd ${DIST}/
echo 2.0 > ./debian-binary

find ${DIST}/ -type d -exec chmod 0755 {} \;
find ${DIST}/ -type f -exec chmod go-w {} \;

ar r ${DIST}/package.deb debian-binary control.tar.gz data.tar.gz
popd
rsync -a ${DIST}/package.deb ./

rm -r ${DIST}
rm -r ${DIR}/src
