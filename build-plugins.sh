#!/bin/sh
# Caution: this script is for ubuntu 16.04 or newer
set -e
s_begin=$( date "+%s")

. ./config.txt
export CFLAGS="-pipe -O3 -fno-strict-aliasing -Wno-deprecated-declarations"
export CXXFLAGS="$CFLAGS"

if [ ! -e "$my_pkg_config_path/vapoursynth.pc" -a\
     ! -e "$my_pkg_config_path/libavcodec.pc" ]; then
  echo "error: missing a local installation of FFmpeg libraries and Vapoursynth in \`$VSPREFIX'"
  echo "Have you forgotten to run \`build-vapoursynth.sh' before ?"
  exit 1
fi

# gcc++-11 is required for rife
sudo add-apt-repository ppa:ubuntu-toolchain-r/test

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
    meson \
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
    libpng-dev \
    libjansson-dev \
    python3-testresources \
    libxxhash-dev \
    libturbojpeg0-dev \
    python3-setuptools \
    python3-wheel \
    python-is-python3 \
    libxxhash-dev \
    llvm-14 \
    llvm

rm -rf build
mkdir -p build/logs
cd build
build_pwd=$PWD

# newer nasm
if [ ! -x "$VSPREFIX/bin/nasm" ]; then
  ver="2.14.02"
  wget -c https://www.nasm.us/pub/nasm/releasebuilds/$ver/nasm-${ver}.tar.xz
  tar xf nasm-${ver}.tar.xz
  cd nasm-$ver
  ./configure --prefix="$VSPREFIX"
  make -j$JOBS
  make install
  cd $build_pwd
  rm -rf nasm-$ver nasm-${ver}.tar.xz
fi

echo $PWD
plugins=$(ls -1 ../build-plugins/plugin-*.sh | sed 's|^\.\./build-plugins/plugin-||g; s|\.sh$||g')
#plugins="vslsmashsource"
#plugins="akarin"

count=$(echo $plugins | wc -w)
n=0

echo ""
echo "Build plugins:"

# To avoid errors of inattention... but the correct VSPREFIX is in uppercase!
export vsprefix="$VSPREFIX"

for p in $plugins ; do
  echo "building $p"
  cat ../build-plugins/header.sh ../build-plugins/plugin-${p}.sh > build.sh # copy current build script
  n=$(($n + 1)) # increace counter
  printf " %s (%d/%d) ... " $p $n $count  # show progress
  bash ./build.sh >logs/${p}.log 2>&1 && echo "done" || echo "failed" # execute build script and send output to log file
  rm -rf build build.sh # remove build folder and build script
done

unset vsprefix

#pip3 uninstall -y -q setuptools wheel meson ninja

cd $build_pwd/..
rm -rf build

s_end=$( date "+%s")
s=$(($s_end - $s_begin))
printf "\nFinished after %d min %d sec\n" $(($s / 60)) $(($s % 60))


