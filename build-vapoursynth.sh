#!/bin/sh
# Caution: this script is for ubuntu 16.04 or newer
set -e
s_begin=$( date "+%s")

. ./config.txt

export CFLAGS="-pipe -O3 -fno-strict-aliasing -Wno-deprecated-declarations"
export CXXFLAGS="$CFLAGS"

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
    libopenjp2-7-dev \
    libxml2-dev \
    lib$python3dotx \
    lib$python3dotx-dev \
    cython3
  #touch $stamp
#fi

TOP="$PWD"
  
rm -rf build
mkdir build
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
  rm -fr nasm-$ver nasm-${ver}.tar.xz
fi

# build zimg, needed by Vapoursynth
if [ ! -f "$my_pkg_config_path/zimg.pc" ]; then
  git clone https://github.com/sekrit-twc/zimg
  cd zimg
  git checkout $(git tag | sort -V | tail -1)
  autoreconf -if
  ./configure --prefix="$VSPREFIX" --disable-static
  make -j$JOBS
  make install-strip
  cd $build_pwd
  rm -rf zimg
fi

# build ImageMagick 7, needed by imwri plugin
if [ ! -f "$my_pkg_config_path/Magick++.pc" ]; then
  git clone https://github.com/ImageMagick/ImageMagick
  old_pwd=$PWD  
  cd ImageMagick
  git checkout $(git tag | grep '^7\.' | sort -V | tail -1)
  PATH="$PWD:$PATH" autoreconf -if
  ./configure --prefix="$VSPREFIX" \
    --disable-static \
    --disable-docs \
    --without-utilities \
    --enable-hdri \
    --with-quantum-depth=16
  make -j$JOBS
  make install-strip
  cd $build_pwd
  rm -rf ImageMagick
fi

# for nvidia support in ffmpeg
if [ ! -f "$my_pkg_config_path/ffnvcodec.pc" ]; then
  git clone --depth 1 https://github.com/FFmpeg/nv-codec-headers
  make -C nv-codec-headers install PREFIX="$VSPREFIX"
  rm -fr nv-codec-headers
fi

# ffmpeg
if [ ! -f "$my_pkg_config_path/libavcodec.pc" ]; then
  git clone --depth 1 https://github.com/FFmpeg/FFmpeg --branch release/4.4 
  cd FFmpeg
  ./configure --prefix="$VSPREFIX" \
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
  cd $build_pwd
  rm -rf FFmpeg
fi

# VapourSynth, with an temp up-to-date cython install for security
if [ ! -x "$VSPREFIX/bin/vspipe" ]; then
  old_pythonuserbase="$PYTHONUSERBASE"
  export PYTHONUSERBASE="$PWD/temp"
  pip3 install -q -I --user cython

  git clone https://github.com/vapoursynth/vapoursynth
  cd vapoursynth
  #git checkout $(git tag | grep '^R' | sort -V | tail -1)
  autoreconf -if
  ./configure --prefix="$VSPREFIX" --disable-static 
  make -j$JOBS
  make install-strip

  pip3 uninstall -y -q cython
  export PYTHONUSERBASE="$old_pythonuserbase"

  mkdir -p "${vs_site_packages}" "$VSPREFIX/include/vapoursynth" "$VSPREFIX/vsplugins"
  cp include/*.h "$VSPREFIX/include/vapoursynth"

  cd $build_pwd
  rm -rf vapoursynth 
fi

cd $build_pwd/..
rm -rf build

echo "Create \`$VSPREFIX/env.sh' and \`$VSPREFIX/env.csh'"
cat <<EOF >"$VSPREFIX/env.sh"
# source this file with
# . "$VSPREFIX/env.sh"
# in order to use vspipe from your local installation of vapoursynth,
# which is in the read only \$VSPREFIX variable.
#
export VSPREFIX="$VSPREFIX"
vs_site_packages="${vs_site_packages}"
#
if [ \$( echo "\$PATH" | egrep -Ec "(^|:)\$VSPREFIX/bin(:|\$)" ) = "0" ]; then
  export PATH="\$VSPREFIX/bin:\$PATH"
fi
if [ -z "\$LD_LIBRARY_PATH" ]; then
  export LD_LIBRARY_PATH="\$VSPREFIX/lib"
elif [ \$( echo "\$LD_LIBRARY_PATH" | egrep -Ec "(^|:)\$VSPREFIX/lib(:|\$)" ) = "0" ]; then
    export LD_LIBRARY_PATH="\$VSPREFIX/lib:\$LD_LIBRARY_PATH"
fi
if [ -z "\$PYTHONPATH" ]; then
  export PYTHONPATH="\${vs_site_packages}"
elif [ \$( echo "\$PYTHONPATH" | grep -Ec "(^|:)\${vs_site_packages}(:|\$)" ) = "0" ]; then
  export PYTHONPATH="\${vs_site_packages}:\$PYTHONPATH"
fi
EOF
cat <<EOF >"$VSPREFIX/env.csh"
# source this file with
# source "$VSPREFIX/env.csh"
# in order to use vspipe from your local installation of vapoursynth,
# which is in the read only \$VSPREFIX variable.
#
setenv VSPREFIX "$VSPREFIX"
set vs_site_packages="${vs_site_packages}"
#
if ( \`echo "\$PATH" | grep -Ec "(^|:)\$VSPREFIX/bin(:|"'$'")"\` == "0" ) then
  setenv PATH "\$VSPREFIX/bin:\$PATH"
endif
if ( ! \${?LD_LIBRARY_PATH} ) then
  setenv LD_LIBRARY_PATH "$VSPREFIX/lib"
else if ( \`echo "\$LD_LIBRARY_PATH" | grep -Ec "(^|:)\$VSPREFIX/lib(:|"'$'")"\` == "0" ) then
    setenv LD_LIBRARY_PATH "\$VSPREFIX/lib:\$LD_LIBRARY_PATH"
endif
if ( ! \${?PYTHONPATH} ) then
  setenv PYTHONPATH "\${vs_site_packages}"
else if ( \`echo "\$PYTHONPATH" | grep -Ec "(^|:)\${vs_site_packages}(:|"'$'")"\` == "0" ) then
  setenv PYTHONPATH "\${vs_site_packages}:\$PYTHONPATH"
endif
EOF

# http://www.vapoursynth.com/doc/autoloading.html#linux
conf="$HOME/.config/vapoursynth/vapoursynth.conf"
echo "Create \`$conf'"
mkdir -p "$HOME/.config/vapoursynth"
echo "SystemPluginDir=$VSPREFIX/vsplugins" > "$conf"

s_end=$( date "+%s")
s=$(($s_end - $s_begin))
printf "\nFinished after %d min %d sec\n" $(($s / 60)) $(($s % 60))
