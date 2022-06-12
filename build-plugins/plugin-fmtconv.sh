ghdl EleonoreMizo/fmtconv
#ghc EleonoreMizo/fmtconv r28
cd build/unix
autoreconf -if
./configure || cat config.log
make -j$JOBS
cp .libs/libfmtconv.so ../..
cd ../..
finish libfmtconv.so
