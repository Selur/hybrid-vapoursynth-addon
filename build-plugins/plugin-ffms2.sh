git clone https://codeberg.org/StvG/ffms2.git build
cd build
./autogen.sh || cat config.log
make -j$JOBS
finish src/core/.libs/libffms2.so
