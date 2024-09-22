git clone https://github.com/vapoursynth/bestsource.git --depth=1 --recurse-submodules --shallow-submodules --remote-submodules build
cd build
meson setup build -Ddefault_library=static
ninja -C build
cd build
finish bestsource.so
cd ../..
