retry_git_clone https://github.com/HomeOfAviSynthPlusEvolution/neo_f3kdb
cd neo_f3kdb
cmake .
make
cd ../Release_*
strip_copy libneo-f3kdb.so
cd ..
rm -rf Release_*
rm -rf neo_f3kdb