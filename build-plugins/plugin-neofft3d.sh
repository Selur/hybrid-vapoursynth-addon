retry_git_clone https://github.com/HomeOfAviSynthPlusEvolution/neo_FFT3D
cd neo_FFT3D
cmake .
make
cd ../Release_*
strip_copy libneo-fft3d.so
cd ..
rm -rf Release_*
rm -rf neo_FFT3D
