##################################################################################
#                                                                                #
#                               Plugin-grayworld V1.0.2                          #
#                                                                                #
#                                                                                #
#                  https://github.com/Asd-g/AviSynthPlus-grayworld               #
##################################################################################

retry_git_clone https://github.com/Asd-g/AviSynthPlus-grayworld AviSynthPlus-grayworld
cd AviSynthPlus-grayworld
mkdir build
cd build
cmake .. -DBUILD_VS_LIB=ON -DBUILD_AVS_LIB=OFF
make -j$(nproc)
mv libgrayworld*.so libgrayworld.so
strip_copy libgrayworld.so
cd ../..
rm -rf AviSynthPlus-grayworld
