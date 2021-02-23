#!/bin/bash
if [ $(arch | grep arm) ]; then
bottle="https://autobrew.github.io/archive/arm64_big_sur/gdal-3.2.0-arm64_big_sur.tar.xz"
elif [[ ${OSTYPE:6} -ge 20 ]]; then
bottle="https://autobrew.github.io/archive/big_sur/gdal-3.2.0-big_sur.tar.xz"
else
bottle="https://autobrew.github.io/archive/high_sierra/gdal-3.2.0-high_sierra.tar.xz"
fi

# Extract and add to PATH
mkdir -p "/tmp/gdal"
curl -SL --progress-bar $bottle -o gdal.tar.xz
tar -xf gdal.tar.xz --strip 1 -C "/tmp/gdal"
rm -f gdal.tar.xz

# Setup for R
export PATH="/tmp/gdal/bin:$PATH"
export PROJ_LIB="/tmp/gdal/share/proj"
export PROJ_GDAL_DATA_COPY="TRUE"
export PKG_CONFIG_PATH="/tmp/gdal/lib/pkgconfig"
