##################################################################################
#                                                                                #
#               Plugin-vs-L-SMASH-Works 20240408 1194.0.0.0                      #
#                                                                                #
#                                                                                #
#        https://github.com/HomeOfAviSynthPlusEvolution/L-SMASH-Works            #
##################################################################################

ghdl HomeOfAviSynthPlusEvolution/L-SMASH-Works
ghdl l-smash/l-smash

./configure --prefix="$VSPREFIX" --extra-cflags="$CFLAGS" || cat config.log
make -j$JOBS lib
cp liblsmash.a ..

cd ../VapourSynth

mv meson.build meson.build.ORIGINAL
sed < meson.build.ORIGINAL > meson.build \
-e "/vapoursynth_dep *=/i\
liblsmash_dep = declare_dependency(link_args : ['-L../../build', '-llsmash'],\\
                                   include_directories : ['../../build'])\n" \
-e "s/dependency('liblsmash')/liblsmash_dep/g"

if [ -z "$VSPREFIX" ]; then
    vsprefix="/usr/local"
fi

CFLAGS="$CFLAGS -Wno-deprecated-declarations" meson setup build --prefix="$VSPREFIX"
ninja -C build -j $JOBS

cp build/libvslsmashsource.so ../libvslsmashsource.so
cd ..
finish libvslsmashsource.so
