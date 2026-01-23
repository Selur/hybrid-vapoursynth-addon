#!/bin/bash
# -----------------------------------------------------------------------------
# Scriptname: build-vapoursynth.sh
# Beschreibung: Build-Skript für Ubuntu 24.04 oder neuer
# -----------------------------------------------------------------------------

set -euo pipefail
#set -x  # optional: für Debug

JOBS=${JOBS:-4}
s_begin=$(date "+%s")

if [ -f ./config.txt ]; then
    . ./config.txt > /dev/null 2>&1
else
    echo "Error: config.txt not found." >&2
    exit 1
fi

if [ -z "${VSPREFIX}" ]; then
    echo "Error: VSPREFIX is not set."
    exit 1
fi
echo "VSPREFIX is set to: $VSPREFIX"

export PATH="$VSPREFIX/bin:$PATH"
export PKG_CONFIG_PATH="$VSPREFIX/lib/pkgconfig"
export CFLAGS="-pipe -O3 -fno-strict-aliasing -Wno-deprecated-declarations"
export CXXFLAGS="$CFLAGS"

TOP="$PWD"

# Paketinstallation
sudo apt update
sudo apt upgrade -y
sudo apt install --no-install-recommends -y \
  build-essential git python3-pip autoconf automake libtool libtool-bin \
  libltdl-dev libva-dev libvdpau-dev libass-dev libtesseract-dev libleptonica-dev \
  zlib1g-dev libbz2-dev libjpeg-dev libpng-dev libtiff-dev liblzma-dev \
  libfontconfig-dev libfreetype6-dev libfftw3-dev libpango1.0-dev libxml2-dev \
  python3-dev nasm cmake meson ninja-build libopencv-dev \
  libboost-dev libboost-system-dev libboost-filesystem-dev \
  libvulkan1 vulkan-validationlayers cython3

mkdir -p build && cd build

# NASM
if [ ! -x "$VSPREFIX/bin/nasm" ]; then
  wget -c "https://www.nasm.us/pub/nasm/releasebuilds/${NASM_VERSION}/nasm-${NASM_VERSION}.tar.xz"
  tar fvx "nasm-${NASM_VERSION}.tar.xz"
  cd "nasm-${NASM_VERSION}"
  ./configure --prefix="$VSPREFIX"
  make -j"${JOBS}"
  make install
  cd ..
  rm -rf "nasm-${NASM_VERSION}" "nasm-${NASM_VERSION}.tar.xz"
fi

# Zimg
git clone https://github.com/sekrit-twc/zimg
cd zimg
git checkout $(git tag | sort -V | tail -1)
autoreconf -if
./configure --prefix="$VSPREFIX"
make -j"${JOBS}"
make install-strip
cd ..

# ImageMagick 7
git clone https://github.com/ImageMagick/ImageMagick
cd ImageMagick
git checkout $(git tag | grep '^7\.' | sort -V | tail -1)
PATH="$PWD:$PATH" autoreconf -if
./configure --prefix="$VSPREFIX" \
  --disable-static \
  --disable-docs \
  --without-utilities \
  --enable-hdri \
  --with-quantum-depth=16
make -j"${JOBS}"
make install-strip
cd ..

# NV Codec Headers
git clone --depth 1 https://github.com/FFmpeg/nv-codec-headers
make -C nv-codec-headers install PREFIX="$VSPREFIX"

# FFmpeg
wget -c "https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.xz"
tar fvx "ffmpeg-${FFMPEG_VERSION}.tar.xz"
cd "ffmpeg-${FFMPEG_VERSION}"
./configure --prefix="$VSPREFIX" \
  --disable-static \
  --enable-shared \
  --disable-programs \
  --disable-doc \
  --disable-debug \
  --enable-ffnvcodec \
  --enable-nvdec \
  --enable-nvenc \
  --enable-cuvid \
  --enable-vaapi \
  --enable-vdpau
make -j"${JOBS}"
make install
cd ..

# VapourSynth
git clone https://github.com/vapoursynth/vapoursynth
cd vapoursynth
git checkout $(git tag | grep '^R' | sort -V | tail -1)
autoreconf -if
./configure --prefix="$VSPREFIX"
make -j"${JOBS}"
make install-strip
make maintainer-clean
cd ..

# Optional: Python module
export PYTHONUSERBASE="$PWD/temp"
#pip3 install --user -q --upgrade cython setuptools wheel
#./temp/bin/cython --3str vapoursynth/src/cython/vapoursynth.pyx

# Environment file
cat <<EOF >"$VSPREFIX/env.sh"
export LD_LIBRARY_PATH="$VSPREFIX/lib:\$LD_LIBRARY_PATH"
export PYTHONPATH="$VSPREFIX/lib/python3/site-packages:\$PYTHONPATH"
EOF

# Vapoursynth config
conf="$HOME/.config/vapoursynth/vapoursynth.conf"
mkdir -p "$(dirname "$conf")"
echo "SystemPluginDir=$VSPREFIX/vsplugins" > "$conf"

s_end=$(date "+%s")
s=$((s_end - s_begin))
printf "\nFinished after %d min %d sec\n" $(($s / 60)) $(($s % 60))
