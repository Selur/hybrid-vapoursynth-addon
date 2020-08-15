#!/bin/bash
# should be a shell that provides $SECONDS
set -e

JOBS=4
#stamp="dependencies_for_plugins_installed.stamp"

vsprefix="$HOME/opt/vapoursynth"

export PATH="$vsprefix/bin:$PATH"
export LD_LIBRARY_PATH="$vsprefix/lib"
export PKG_CONFIG_PATH="$vsprefix/lib/pkgconfig"

if [ ! -e "$vsprefix/lib/pkgconfig/vapoursynth.pc" -a ! -e "$vsprefix/lib/pkgconfig/libavcodec.pc" ]; then
  echo "error: missing a local installation of FFmpeg libraries and Vapoursynth in \`$vsprefix'"
  exit 1
fi

#if [ ! -e $stamp -x "/usr/bin/apt" ]; then
  set -x

  sudo apt update
  sudo apt upgrade
  sudo apt install --no-install-recommends \
    build-essential \
    cmake \
    yasm \
    git \
    wget \
    mercurial \
    unzip \
    p7zip-full \
    python3-pip \
    zlib1g-dev \
    libfftw3-dev \
    libopencv-dev \
    ocl-icd-opencl-dev \
    opencl-headers \
    libboost-dev \
    libboost-filesystem-dev \
    libboost-system-dev \
    libbluray-dev \
    libpng-dev

  # only on Ubuntu 16.04 ...
  #sudo apt install --no-install-recommends libcompute-dev || true

#  touch $stamp

  set +x
#fi

mkdir -p build/logs
cd build

# newer nasm
if [ ! -x "$vsprefix/bin/nasm" ]; then
  set -x
  ver="2.14.02"
  wget -c https://www.nasm.us/pub/nasm/releasebuilds/$ver/nasm-${ver}.tar.xz
  tar xf nasm-${ver}.tar.xz
  cd nasm-$ver
  ./configure --prefix="$vsprefix"
  make -j$JOBS
  make install
  cd ..
  rm -rf nasm-$ver nasm-${ver}.tar.xz
  set +x
fi

# newer cmake
if [ ! -x "$vsprefix/bin/cmake" ]; then
  set -x
  ver="3.14.6"
  dir="cmake-${ver}-Linux-x86_64"
  wget -c https://github.com/Kitware/CMake/releases/download/v$ver/${dir}.tar.gz
  tar xf ${dir}.tar.gz
  cp -rf $dir/bin $dir/share "$vsprefix"
  rm -rf $dir ${dir}.tar.gz
  set +x
fi

export PYTHONUSERBASE="$vsprefix"
pip3 install -q --upgrade --user setuptools wheel  # must be installed first
pip3 install -q --upgrade --user meson ninja

plugins=$(ls -1 ../build-plugins/plugin-*.sh | sed 's|^\.\./build-plugins/plugin-||g; s|\.sh$||g')
#plugins=( "fft3dfilter" )
count=$(echo $plugins | wc -w)
n=0

echo ""
echo "Build plugins:"

for p in $plugins ; do
  rm -rf build # remove old stuff
  cat ../build-plugins/header.sh ../build-plugins/plugin-${p}.sh > build.sh # copy current build script
  n=$(($n + 1)) # increace counter
  printf " %s (%d/%d) ... " $p $n $count  # show progress
  sh ./build.sh >logs/${p}.log 2>&1 && echo "done" || echo "failed" # execute build script and send output to log file
  rm -rf build build.sh # remove build folder and build script
done

echo ""

pip3 uninstall -y -q setuptools wheel meson ninja

s=$SECONDS
printf "\nfinished after %d min %d sec\n" $(($s / 60)) $(($s % 60))


