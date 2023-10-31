ghdl HolyWu/L-SMASH-Works
ghdl l-smash/l-smash

./configure --prefix="$vsprefix" --extra-cflags="$CFLAGS" || cat config.log
make -j$JOBS lib
cp liblsmash.a ..

cd ../VapourSynth

mv meson.build meson.build.ORIGINAL
sed < meson.build.ORIGINAL > meson.build \
-e "/vapoursynth_dep *=/i\
liblsmash_dep = declare_dependency(link_args : ['-L../../build', '-llsmash'],\\
                                   include_directories : ['../../build'])\n" \
-e "s/dependency('liblsmash')/liblsmash_dep/g"

if [ -z "$vsprefix" ]; then
    vsprefix="/usr/local"
fi

CFLAGS="$CFLAGS -Wno-deprecated-declarations" meson build --prefix="$vsprefix"
ninja -C build -j $JOBS

cp build/libvslsmashsource.so ../libvslsmashsource.so
cd ..
finish libvslsmashsource.so
