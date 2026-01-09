##################################################################################
#                                                                                #
#                            Plugin-vs-sangnom R42                               #
#                                                                                #
#                                                                                #
#           https://github.com/dubhater/vapoursynth-sangnom                      #
##################################################################################

ghdl dubhater/vapoursynth-sangnom
CFLAGS="$CFLAGS -Wno-deprecated-declarations" meson setup build --prefix="$VSPREFIX"
ninja -C build -j $JOBS
ninja -C build install -j $JOBS
