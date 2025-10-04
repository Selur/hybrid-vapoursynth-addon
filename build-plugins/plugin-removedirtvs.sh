##################################################################################
#                                                                                #
#                                Plugin-dpid                                     #
#                                                                                #
#                                                                                #
#           https://github.com/yuygfgg/removedirt                                #
##################################################################################

ghdl yuygfgg/removedirtvs
meson setup build
ninja -C build -j4
finish build/libremovedirtvs.so
cd ..
rm -rf build

