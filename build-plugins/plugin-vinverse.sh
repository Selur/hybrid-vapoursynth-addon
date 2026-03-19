##################################################################################
#                                                                                #
#                               Plugin-grayworld V1.0.2                          #
#                                                                                #
#                                                                                #
#                  https://github.com/Asd-g/vinverse                             #
##################################################################################

retry_git_clone https://github.com/Asd-g/vinverse vinverse
cd vinverse
mkdir build
cd build
cmake .. -DBUILD_VS_LIB=ON -DBUILD_AVS_LIB=OFF
make -j$(nproc)
mv libvinverse*.so libvinverse.so
strip_copy libvinverse.so
cd ../..
rm -rf vinverse
