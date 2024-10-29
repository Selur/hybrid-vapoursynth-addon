##################################################################################
#                                                                                #
#                            Plugin-neo_FFT3D  R9                                #
#                                                                                #
#                                                                                #
#          https://github.com/HomeOfAviSynthPlusEvolution/neo_FFT3D              #
##################################################################################

retry_git_clone https://github.com/HomeOfAviSynthPlusEvolution/neo_FFT3D neo_FFT3D
cd neo_FFT3D
cmake .
make
cd $(ls -d ../Release_*/)
strip_copy libneo-fft3d.so
cd ..
rm -rf Release_*
rm -rf neo_FFT3D
