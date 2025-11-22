##################################################################################
#                                                                                #
#                         Plugin-vs-placebo v3.3.1                               #
#                                                                                #
#                                                                                #
#                 https://github.com/sgt0/vs-placebo.git                         #
##################################################################################

# install dependencies

wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main' | sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null

wget -qO- https://packages.lunarg.com/lunarg-signing-key-pub.asc | sudo tee /etc/apt/trusted.gpg.d/lunarg.asc
sudo wget -qO /etc/apt/sources.list.d/lunarg-vulkan-jammy.list https://packages.lunarg.com/vulkan/lunarg-vulkan-jammy.list

sudo apt update
sudo apt install -y cmake glslang-dev shaderc vulkan-headers

# install spriv-cross

git clone https://github.com/KhronosGroup/SPIRV-Cross.git temp/SPIRV-Cross
cd temp/SPIRV-Cross

cmake -H. -Bbuild -GNinja -DCMAKE_BUILD_TYPE=RelWithDebInfo -DSPIRV_CROSS_SHARED=ON -DSPIRV_CROSS_CLI=OFF -DSPIRV_CROSS_ENABLE_TESTS=OFF ..
ninja -Cbuild
sudo ninja -Cbuild install

cd ../..
rm -rf temp

# build libplacebo

git clone https://github.com/sgt0/vs-placebo.git --depth=1 --recurse-submodules --shallow-submodules --remote-submodules build
cd build

# create a virtualenv and install meson (the plugin requires at least 1.4.0)
virtualenv .venv
. .venv/bin/activate
pip install meson

meson setup build --buildtype release -Ddefault_library=static -Dlibplacebo:demos=false -Dlibplacebo:glslang=enabled
meson compile -vC build

ninja -C build
cd build
finish libvs_placebo.so
cd ..
rm -rf build

rm -rf .venv
