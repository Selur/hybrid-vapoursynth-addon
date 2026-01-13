##################################################################################
#                                                                                #
#                        Plugin-neo_Vague_Denoiser R2                            #
#                                                                                #
#                                                                                #
#      https://github.com/HomeOfAviSynthPlusEvolution/neo_Vague_Denoiser         #
##################################################################################

git clone https://github.com/HomeOfAviSynthPlusEvolution/neo_Vague_Denoiser
cd neo_Vague_Denoiser
cmake . -DCMAKE_POLICY_VERSION_MINIMUM=3.5
make
strip_copy libneo-vague-denoiser.so
cd ..
rm -rf neo_Vague_Denoiser
