#!/bin/bash
_ARCH=`uname -i`
wget http://phantomjs.googlecode.com/files/phantomjs-1.5.0-linux-${_ARCH}-dynamic.tar.gz
tar -zxf phantomjs-*.tar.gz && rm phantomjs-*.tar.gz
mv phantomjs .phantomjs