##################################################################################
#                                                                                #
#                              Plugin-vs-vcmod                                   #
#                                                                                #
#                                                                                #
#                  http://www.avisynth.nl/users/vcmohan/                         #
##################################################################################

mkdir build
cd build
wget http://www.avisynth.nl/users/vcmohan/vcmod/vcmod_src.7z
7z e vcmod_src.7z
  rm -fr VSHelper.h VapourSynth.h

  sed -e 's|vapoursynth.h|VapourSynth.h|g' \
      -e 's|vshelper.h|VSHelper.h|g' \
      -e 's|"VapourSynth.h"|<VapourSynth.h>|g' \
      -e 's|"VSHelper.h"|<VSHelper.h>|g' \
      -i *

      # quick fix for strcpy_s. idea taked from https://github.com/opencv/opencv/pull/13032/files
      patch --binary -p1 -i "../../patch/vcm_esee"

sed -i 's|vapoursynth\.h|VapourSynth.h|g; s|vshelper.h|VSHelper.h|g' vcmod.cpp  # Linux is case-sensitive
g++ -std=c++11 $CXXFLAGS $LDFLAGS -shared vcmod.cpp -o libvcmod.so
finish libvcmod.so
