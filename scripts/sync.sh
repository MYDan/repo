#!/bin/bash

DIR=$( dirname $0 )

cd "$DIR/.." || exit 1

if [ ! -d "data" ]; then
    mkdir data
fi


# sync perl

if [ -d "data/perl" ]; then
    echo "pull perl"

    cd data/perl && git pull && cd ../.. 
else
    echo "clone perl"
    cd data && git clone https://github.com/MYDan/perl.git && cd ..
fi


# sync mayi

if [ ! -d "data/mayi" ]; then
    mkdir data/mayi
fi

VERSIONURL='https://raw.githubusercontent.com/MYDan/openapi/master/scripts/mayi/version'
VVVV=$(curl -k -s $VERSIONURL)
version=$(echo $VVVV|awk -F: '{print $1}')
md5=$(echo $VVVV|awk -F: '{print $2}')

if [[ $version =~ ^[0-9]{14}$ ]];then
    echo "mayi version: $version"
else
    echo "get version fail"
    exit 1
fi

MAYIPATH="data/mayi/mayi.$version.tar.gz"
if [ -f "$MAYIPATH" ];then
    fmd5=$(md5sum $MAYIPATH|awk '{print $1}')
    if [ "X$md5" != "X$fmd5" ];then
        rm -f "data/mayi/mayi.$version.tar.gz"
    else
        exit 0;
    fi
fi

TEMPNAME=$(mktemp mayi.XXXXXX )
wget --no-check-certificate -O "/tmp/$TEMPNAME" "https://github.com/MYDan/mayi/archive/mayi.$version.tar.gz" || exit 1

if [ -f "/tmp/$TEMPNAME" ];then
    mv /tmp/$TEMPNAME $MAYIPATH
else
    exit 1
fi

exit 0
