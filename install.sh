#!/bin/bash
# This script is supposed to install phantomjs on Jenkins slaves.

_ARCH=x86 # for BuildHive's slaves.
_DIR=`dirname $0`

[ -e $_DIR/.phantomjs ] || (
    wget http://phantomjs.googlecode.com/files/phantomjs-1.5.0-linux-${_ARCH}-dynamic.tar.gz
    tar -zxf phantomjs-*.tar.gz && rm phantomjs-*.tar.gz
    mv phantomjs .phantomjs
)