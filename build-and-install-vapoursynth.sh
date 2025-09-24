#!/bin/bash
# -----------------------------------------------------------------------------
# Scriptname: build-vapoursynth.sh
# Beschreibung: Build-Skript für Ubuntu 24.04 oder neuer
# -----------------------------------------------------------------------------

set -euo pipefail
set -x  # optional: Debug-Ausgabe

JOBS=${JOBS:-4}
s_begin=$(date "+%s")

vsprefix="$HOME/opt/vapoursynth"
export PATH="$vsprefix/bin:$PATH"
export PKG_CONFIG_PATH="$vsprefix/lib/pkgconfig"
export CFLAGS="-pipe -O3 -fno-strict-aliasing -Wno-deprecated-declarations"
export CXXFLAGS="$CFLAGS"

TOP="$PWD"

# -------------------------------
# Paketinstallation
# -------------------------------
sudo apt update
sudo apt upgrade -y
sudo apt install --no-install-recommends -y \
  build-essential git python3-pip autoconf automake libtool libtool-bin \
  libltdl-dev libva-dev libvdpau-dev libass-dev libtesseract-dev libleptonica-dev \
  zlib1g-dev libbz2-dev libjpeg-dev libpng-dev libtiff-dev liblzma-dev \
  libfontconfig-dev libfreetype6-dev libfftw3-dev libpango1.0-dev libxml2-dev \
  python3-dev cython3 nasm cmake meson ninja-build libopencv-dev \
  libboost-dev libboost-system-dev libboost-filesystem-dev \
  libvulkan1 vulkan-validationlayers

mkdir -p build && cd build

# -------------------------------
# NASM
# -------------------------------
if [ ! -x "$vsprefix/bin/nasm" ]; then
  ver="2.14.02"
  wget -c https://www.nasm.us/pub/nasm/releasebuilds/$ver/nasm-${ver}.tar.xz
  tar xf nasm-${ver}.tar.xz
  cd "nasm-$ver"
  ./configure --prefix="$vsprefix"
  make -j$JOBS
  make install
  cd ..
  rm -rf "nasm-$ver" "nasm-${ver}.tar.xz"
fi

# -------------------------------
# Zimg
# -------------------------------
git clone https://github.com/sekrit-twc/zimg
cd zimg
git checkout $(git tag | sort -V | tail -1)
autoreconf -if
./configure --prefix="$vsprefix"
make -j$JOBS
make install-strip
cd ..

# -------------------------------
# ImageMagick 7
# -------------------------------
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

# -------------------------------
# NV Codec Headers
# -------------------------------
git clone --depth 1 https://github.com/FFmpeg/nv-codec-headers
make -C nv-codec-headers install PREFIX="$vsprefix"

# -------------------------------
# FFmpeg release/7.1
# -------------------------------
git clone --branch release/7.1 --depth 1 https://github.com/FFmpeg/FFmpeg
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
cd ..

# -------------------------------
# VapourSynth
# -------------------------------
git clone https://github.com/vapoursynth/vapoursynth
cd vapoursynth
git checkout $(git tag | grep '^R' | sort -V | tail -1)
autoreconf -if
./configure --prefix="$vsprefix"
make -j$JOBS
make install-strip
make maintainer-clean
cd ..

# -------------------------------
# Optional: Python-Modul
# -------------------------------
export PYTHONUSERBASE="$PWD/temp"
pip3 install --user -q --upgrade cython setuptools wheel
./temp/bin/cython --3str vapoursynth/src/cython/vapoursynth.pyx

# -------------------------------
# Environment-Datei
# -------------------------------
cat <<EOF >"$vsprefix/env.sh"
export LD_LIBRARY_PATH="$vsprefix/lib:\$LD_LIBRARY_PATH"
export PYTHONPATH="$vsprefix/lib/python3/site-packages:\$PYTHONPATH"
EOF

# -------------------------------
# Vapoursynth Konfiguration
# -------------------------------
conf="$HOME/.config/vapoursynth/vapoursynth.conf"
mkdir -p "$(dirname "$conf")"
echo "SystemPluginDir=$vsprefix/vsplugins" > "$conf"

# -------------------------------
# Fertig
# -------------------------------
s_end=$(date "+%s")
s=$((s_end - s_begin))
printf "\nFinished after %d min %d sec\n" $(($s / 60)) $(($s % 60))

