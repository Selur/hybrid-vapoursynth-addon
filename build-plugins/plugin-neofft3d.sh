ghdl HomeOfAviSynthPlusEvolution/neo_FFT3D
sed '/"COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:neo-fft3d> \"../Release_${VERSION}/${_DIR}/$<TARGET_FILE_NAME:neo-fft3d>\"' CMakeLists.txt
cmake -DCMAKE_C_FLAGS="$CFLAGS" -DENABLE_SHARED=OFF -DENABLE_STATIC=ON

build libneo-fft3d

