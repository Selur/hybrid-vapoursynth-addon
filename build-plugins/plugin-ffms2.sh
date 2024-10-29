##################################################################################
#                                                                                #
#                                Plugin-ffms V5.0                                #
#                                                                                #
#                                                                                #
#                          https://github.com/FFMS/ffms2                         #
##################################################################################

ghdl FFMS/ffms2
./autogen.sh || cat config.log
make -j$JOBS
finish src/core/.libs/libffms2.so
rm -rf build
