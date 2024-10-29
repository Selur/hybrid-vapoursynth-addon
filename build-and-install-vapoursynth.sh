#!/bin/bash

################################
# Old script. Not updated yet! #
################################

# should be a shell that provides $SECONDS

# build script for Ubuntu 16.04 or newer

JOBS=4
#stamp="dependencies_for_vapoursynth_installed.stamp"

set -e
set -x

#if [ ! -e $stamp -a -x "/usr/bin/apt" ]; then
  sudo apt update
  sudo apt upgrade
  sudo apt install --no-install-recommends \
    build-essential \
    git \
    python3-pip \
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
    libxml2-dev \
    python3-dev \
    cython3 \
    build-essential

  #touch $stamp
#fi

vsprefix="$HOME/opt/vapoursynth"

export PATH="$vsprefix/bin:$PATH"
export PKG_CONFIG_PATH="$vsprefix/lib/pkgconfig"
export CFLAGS="-pipe -O3 -fno-strict-aliasing -Wno-deprecated-declarations"
export CXXFLAGS="$CFLAGS"

TOP="$PWD"

mkdir build
cd build

# newer nasm
if [ ! -x "$vsprefix/bin/nasm" ]; then
  ver="2.14.02"
  wget -c https://www.nasm.us/pub/nasm/releasebuilds/$ver/nasm-${ver}.tar.xz
  tar xf nasm-${ver}.tar.xz
  cd nasm-$ver
  ./configure --prefix="$vsprefix"
  make -j$JOBS
  make install
  cd ..
fi

#cat <<EOL >/dev/null

# build zimg, needed by Vapoursynth
git clone https://github.com/sekrit-twc/zimg
cd zimg
git checkout $(git tag | sort -V | tail -1)
autoreconf -if
./configure --prefix="$vsprefix"
make -j$JOBS
make install-strip
cd ..

# build ImageMagick 7, needed by imwri plugin
git clone https://github.com/ImageMagick/ImageMagick
cd ImageMagick
git checkout $(git tag | grep '^7\.' | sort -V | tail -1)
PATH="$PWD:$PATH" autoreconf -if
./configure --prefix="$vsprefix" \
  --disable-static \
  --disable-docs \
  --without-utilities \
  --enable-hdri \
  --with-quantum-depth=16
make -j$JOBS
make install-strip
cd ..

# for nvidia support in ffmpeg
git clone --depth 1 https://github.com/FFmpeg/nv-codec-headers
make -C nv-codec-headers install PREFIX="$vsprefix"

# ffmpeg
git clone --depth 1 https://github.com/FFmpeg/FFmpeg
cd FFmpeg
./configure --prefix="$vsprefix" \
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
make install

#EOL

# VapourSynth
git clone https://github.com/vapoursynth/vapoursynth
cd vapoursynth
git checkout $(git tag | grep '^R' | sort -V | tail -1)
autoreconf -if
./configure --prefix="$vsprefix"
make -j$JOBS
make install-strip
#rm -f "$vsprefix"/lib/libvapoursynth-script.*
make maintainer-clean

export PYTHONUSERBASE="$PWD/temp"
pip3 install -q -I --user cython
./temp/bin/cython --3str src/cython/vapoursynth.pyx


echo "$PWD"
rm -rf .git
cp -rf "$PWD" "$vsprefix/src"

cd "$vsprefix"

# copy
sitepackages="$vsprefix/lib/python3/site-packages"
mkdir -p "$sitepackages"

# cython
g++ -std=c++11 -shared -fPIC -O3 -Isrc  $(pkg-config --cflags python3) \
  src/src/cython/vapoursynth.c  -o "$sitepackages/vapoursynth.so" \
  -Llib -lvapoursynth  -s -Wl,-rpath,"$vsprefix/lib" &
echo "Build Python module"

# vsscript
g++ -std=c++11 -shared -fPIC -O3 -Isrc/include  $(pkg-config --cflags python3) \
  src/src/vsscript/vsscript.cpp  -o "$vsprefix/lib/libvapoursynth-script.so.0" \
  $(pkg-config --libs python3)  -s -Wl,-rpath,"$vsprefix/lib"  -Wl,-soname,libvapoursynth-script.so.0 &
echo "Build VSScript library"

ln -sf libvapoursynth-script.so.0 "$vsprefix/lib/libvapoursynth-script.so"

# vspipe
g++ -std=c++11 -O3 -Isrc/include  src/src/vspipe/vspipe.cpp  -o "$vsprefix/vspipe" \
  -L"$vsprefix/lib" -lvapoursynth-script  -s -Wl,-rpath,"$vsprefix/lib" &
echo "Build VSPipe"

echo "Create \`$vsprefix/env.sh'"
cat <<EOF >"$vsprefix/env.sh"
# source this file with
# . "$vsprefix/env.sh"
export LD_LIBRARY_PATH="$vsprefix/lib:\$LD_LIBRARY_PATH"
export PYTHONPATH="$vsprefix/lib/python3/site-packages:\$PYTHONPATH"
EOF

# http://www.vapoursynth.com/doc/autoloading.html#linux
conf="$HOME/.config/vapoursynth/vapoursynth.conf"
echo "Create \`$conf'"
mkdir -p "$HOME/.config/vapoursynth"
echo "SystemPluginDir=$vsprefix/vsplugins" > "$conf"

pip3 uninstall -y -q cython

s=$SECONDS
printf "\nfinished after %d min %d sec\n" $(($s / 60)) $(($s % 60))

