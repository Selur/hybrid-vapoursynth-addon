#!/bin/bash
# should be a shell that provides $SECONDS

# build script for Ubuntu 18.04 and hopefully newer

JOBS=4

set -euxo pipefail
export LD_LIBRARY_PATH=/usr/local/lib
export PYTHONPATH=/usr/local/lib/python3.6/site-packages
export CFLAGS="-pipe -O3 -fno-strict-aliasing -Wno-deprecated-declarations"
export CXXFLAGS="$CFLAGS"

sudo apt update
sudo apt upgrade
sudo apt install --no-install-recommends \
    build-essential \
    git \
    python3-pip \
    python3-dev \
    autoconf \
    automake \
    libtool \
    libtool-bin \
    libltdl-dev \
    libva-dev \
    libvdpau-dev \
    libass-dev \
    libtesseract-dev \
    libleptonica-dev \
    zlib1g-dev \
    libbz2-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    liblzma-dev \
    libfontconfig-dev \
    libfreetype6-dev \
    libfftw3-dev \
    libpango1.0-dev \
    libopenjp2-?-dev \
    libxml2-dev \
    cython3


#newer nasm than ships with Ubuntu 18.04
ver="2.14.02"
rm -rf nasm-${ver}
wget -c https://www.nasm.us/pub/nasm/releasebuilds/$ver/nasm-${ver}.tar.xz
tar xf nasm-${ver}.tar.xz
cd nasm-$ver
./configure
make -j$JOBS
sudo make install
cd ..
rm -rf nasm-$ver nasm-${ver}.tar.xz

# build zimg, needed by Vapoursynth
rm -rf zimg
git clone https://github.com/sekrit-twc/zimg
cd zimg
git checkout $(git tag | sort -V | tail -1)
autoreconf -if
./configure
make -j$JOBS
sudo make install
cd ..

# build ImageMagick 7, needed by imwri plugin
rm -rf ImageMagick
git clone https://github.com/ImageMagick/ImageMagick
cd ImageMagick
git checkout $(git tag | grep '^7\.' | sort -V | tail -1)
autoreconf -if
./configure \
  --disable-static \
  --disable-docs \
  --without-utilities \
  --enable-hdri \
  --with-quantum-depth=16
make -j$JOBS
sudo make install
cd ..

# for nvidia support in ffmpeg
rm -rf nv-codec-headers
git clone --depth 1 https://github.com/FFmpeg/nv-codec-headers
sudo make -C nv-codec-headers install

# ffmpeg libraries for gpu support
rm -rf FFmpeg
git clone --depth 1 https://github.com/FFmpeg/FFmpeg
cd FFmpeg
./configure \
  --disable-static \
  --enable-shared \
  --disable-programs \
  --disable-doc \
  --disable-debug \
  --enable-avresample \
  --enable-ffnvcodec \
  --enable-nvdec \
  --enable-nvenc \
  --enable-cuvid \
  --enable-vaapi \
  --enable-vdpau
make -j$JOBS
sudo make install

# install a newer Cython
pip3 install Cython

# VapourSynth
rm -rf vapoursynth
git clone https://github.com/vapoursynth/vapoursynth
cd vapoursynth
./autogen.sh
./configure
make -j$JOBS
sudo make install

s=$SECONDS
printf "\nfinished after %d min %d sec\n" $(($s / 60)) $(($s % 60))
