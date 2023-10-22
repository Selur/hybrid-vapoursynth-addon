retry_git_clone https://github.com/Asd-g/AviSynthPlus-grayworld
cd AviSynthPlus-grayworld
mkdir build
cd build
cmake .. -DBUILD_VS_LIB=ON -DBUILD_AVS_LIB=OFF
make -j$(nproc)
#ls -d $PWD/*
mv libgrayworld*.so libgrayworld.so
strip_copy libgrayworld.so
#rm -rf build
