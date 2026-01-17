#################################################################################
#                                                                                #
#                              Plugin-vs-vcmod                                   #
#                                                                                #
#                                                                                #
#                  http://www.avisynth.nl/users/vcmohan/                         #
##################################################################################

mkdir build
cd build
wget -q --show-progress=off http://www.avisynth.nl/users/vcmohan/vcm/vcm_src.7z
7z e vcm_src.7z >/dev/null
( shopt -s nullglob; for f in *.cpp *.h; do [[ "$f" != *.7z ]] && dos2unix -q "$f"; done )
patch -p1 -s -i  "../../patch/vcm-crossplatform-complete.patch"
g++ -std=c++11 $CXXFLAGS $LDFLAGS -shared vcm.cpp -o libvcm.so
finish libvcm.so
