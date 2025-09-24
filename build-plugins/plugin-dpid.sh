##################################################################################
#                                                                                #
#                                Plugin-dpid                                     #
#                                                                                #
#                                                                                #
#           https://github.com/WolframRhodium/VapourSynth-dpid                   #
##################################################################################

ghdl WolframRhodium/VapourSynth-dpid
cd Source
meson setup build
ninja -C build -j4
finish build/libdpid.so
cd ..
rm -rf build

