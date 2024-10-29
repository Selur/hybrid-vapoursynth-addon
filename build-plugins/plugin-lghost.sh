##################################################################################
#                                                                                #
#                                   Plugin-vs-LGhost R1                          #
#                                                                                #
#                                                                                #
#      https://github.com/HomeOfVapourSynthEvolution/VapourSynth-LGhost          #
##################################################################################

ghdl HomeOfVapourSynthEvolution/VapourSynth-LGhost

CFLAGS="$CFLAGS -Wno-deprecated-declarations" meson build --prefix="$vsprefix"
ninja -C build -j $JOBS
ninja -C build install -j $JOBS
