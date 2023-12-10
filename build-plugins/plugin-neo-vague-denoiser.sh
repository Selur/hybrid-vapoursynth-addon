git clone https://github.com/HomeOfAviSynthPlusEvolution/neo_Vague_Denoiser
cd neo_Vague_Denoiser
cmake .
make
strip_copy libneo-vague-denoiser.so
cd ..
rm -rf neo_Vague_Denoiser
