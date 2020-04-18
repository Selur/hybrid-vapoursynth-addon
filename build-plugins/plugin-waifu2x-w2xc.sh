ghdl DeadSix27/waifu2x-converter-cpp
mkdir build
cd build

cmake_flags="-DCMAKE_INSTALL_PREFIX=$vsprefix -DCMAKE_BUILD_TYPE=Release -DENABLE_GUI=OFF -DENABLE_CUDA=ON"
cmake .. $cmake_flags -DENABLE_OPENCV=ON || cmake .. $cmake_flags -DENABLE_OPENCV=OFF
make -j$JOBS
sudo cp -f ../src/w2xconv.h /usr/local/lib/vapoursynth/
sudo cp -f libw2xc.so /usr/local/lib/vapoursynth/
cd ../..
rm -rf build

ghdl HomeOfVapourSynthEvolution/VapourSynth-Waifu2x-w2xc
sudo rm -rf /usr/local/lib/vapoursynth/models
sudo cp -r Waifu2x-w2xc/models /usr/local/lib/vapoursynth
build libwaifu2x-w2xc
