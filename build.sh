#!/bin/bash -e
# build script for SQlite
. /etc/profile.d/modules.sh
module add ci
module add readline
# SQLite doesn't use dots for their versioning, because they are apparently too damn cool.
# so versin 3.9.2 translates to 3090200
SOURCE_FILE=sqlite-autoconf-${VERSION}.tar.gz

mkdir -p $WORKSPACE
mkdir -p $SRC_DIR
mkdir -p $SOFT_DIR

#  Download the source file

if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  echo "seems like this is the first build - let's get the source"
  wget https://www.sqlite.org/2015/${SOURCE_FILE} -O $SRC_DIR/$SOURCE_FILE
  echo "releasing lock"
  rm -v ${SRC_DIR}/${SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
  echo "continuing from previous builds, using source at " ${SRC_DIR}/${SOURCE_FILE}
fi
tar xzf  ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE} --skip-old-files
# no out of source builds for Lua - doesn't use autotools either.
mkdir -p ${WORKSPACE}/${NAME}-autoconf-${VERSION}/build-${BUILD_NUMBER}
export LDFLAGS="-L${READLINE_DIR}/lib"
export CFLAGS="-I${READLINE_DIR}/include"
cd ${WORKSPACE}/${NAME}-autoconf-${VERSION}/build-${BUILD_NUMBER}
../configure \
--enable-shared \
--enable-static \
--enable-readline \
--enable-fts5 \
--enable-json1 \
--prefix=${SOFT_DIR}
make -j2