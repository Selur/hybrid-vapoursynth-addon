##################################################################################
#                                                                                #
#                          Plugin-bestsource R7                                  #
#                                                                                #
#                                                                                #
#             https://github.com/vapoursynth/bestsource.git                      #
##################################################################################

git clone https://github.com/vapoursynth/bestsource.git --depth=1 --recurse-submodules --shallow-submodules --remote-submodules build
cd build
git fetch --tags
git checkout R8
git submodule update --init --recursive --depth=1
meson setup build -Ddefault_library=static
ninja -C build
cd build
finish bestsource.so
cd ..
rm -rf build
