#!/bin/bash
# Caution: this script is for ubuntu 16.04 or newer
# This script does nothing; it's the header of all others build-plugins scripts.
# on the form plugin-*.sh
set -e

. ../config.txt

export CFLAGS="-pipe -O3 -Wno-attributes -fPIC -fvisibility=hidden -fno-strict-aliasing $(pkg-config --cflags vapoursynth) -I/usr/include/compute"
export CXXFLAGS="$CFLAGS -Wno-reorder"
export LDFLAGS="-L$VSPREFIX/lib"

install_nnedi3_weights ()
{
  p="$VSPREFIX/lib/vapoursynth"
  f="$p/nnedi3_weights.bin"
  sum="27f382430435bb7613deb1c52f3c79c300c9869812cfe29079432a9c82251d42"
  if [ ! -f $f ] || [ "$(sha256sum -b $f | head -c64)" != "$sum" ]; then
    mkdir -p $p
    rm -f $f
    wget -O $f https://github.com/dubhater/vapoursynth-nnedi3/raw/master/src/nnedi3_weights.bin
  fi
}

ghdl ()
{
  git clone --depth 1 --recursive https://github.com/$1 build
  cd build
}

strip_copy ()
{
  chmod a-x $1
  strip $1
  nm -D --extern-only $1 | grep -q 'T VapourSynthPluginInit'

  mkdir -p "$VSPREFIX/lib/vapoursynth"
  cp -f $1 $VSPREFIX/lib/vapoursynth/
}

finish ()
{
  strip_copy $1
  cd ..
  rm -rf _build
}

build ()
{
  if [ -f meson.build ]; then
    meson build
    ninja -C build -j$JOBS
  elif [ -f waf ]; then
    python3 ./waf configure
    python3 ./waf build -j$JOBS
  else
    if [ ! -e configure -a -f configure.ac ]; then
      autoreconf -if
    fi

    if [ -e configure ]; then
      chmod a+x configure
      if grep -q -- '--extra-cflags' configure && grep -q -- '--extra-cxxflags' configure ; then
        ./configure --extra-cflags="$CFLAGS" --extra-cxxflags="$CXXFLAGS" --extra-ldflags="$LDFLAGS" || cat config.log
      elif grep -q -- '--extra-cflags' configure ; then
        ./configure --extra-cflags="$CFLAGS" --extra-ldflags="$LDFLAGS" || cat config.log
      elif grep -q -- '--extra-cxxflags' configure ; then
        ./configure --extra-cxxflags="$CXXFLAGS" --extra-ldflags="$LDFLAGS" || cat config.log
      else
        ./configure || cat config.log
      fi
    fi

    make -j$JOBS X86=1
  fi

  if [ -e .libs/${1}.so ]; then
    finish .libs/${1}.so
  elif [ -e build/${1}.so ]; then
    finish build/${1}.so
  else
    finish ${1}.so
  fi
}

mkgh ()
{
  ghdl $1
  build $2
}

ghc ()
{
  git clone https://github.com/$1 build
  cd build
  git checkout $2
  git reset --hard
}

mkghc ()
{
  ghc $1 $3
  build $2
}

