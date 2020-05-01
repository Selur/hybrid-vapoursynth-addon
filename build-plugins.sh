#!/bin/bash
# should be a shell that provides $SECONDS
set -e

JOBS=4

vsprefix="$HOME/opt/vapoursynth"


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
set +x

mkdir -p build/logs
cd build

pip3 install -q --upgrade --user setuptools wheel  # must be installed first
pip3 install -q --upgrade --user meson ninja

plugins=$(ls -1 ../build-plugins/plugin-*.sh | sed 's|^\.\./build-plugins/plugin-||g; s|\.sh$||g')
#plugins="mvtoolssf"
count=$(echo $plugins | wc -w)
n=0

echo ""
echo "Build plugins:"

for p in $plugins ; do
  rm -rf build
  cat ../build-plugins/header.sh ../build-plugins/plugin-${p}.sh > build.sh
  n=$(($n + 1))
  printf " %s (%d/%d) ... " $p $n $count
  sh ./build.sh >logs/${p}.log 2>&1 && echo "done" || echo "failed"
  rm -rf build build.sh
done

echo ""

sudo pip3 uninstall -y -q setuptools wheel meson ninja

s=$SECONDS
printf "\nfinished after %d min %d sec\n" $(($s / 60)) $(($s % 60))
