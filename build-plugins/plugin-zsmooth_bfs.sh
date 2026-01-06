##################################################################################
#                                                                                #
#                              Plugin-Zsmooth V0.16                              #
#                                                                                #
#                                                                                #
#                       https://github.com/adworacz/zsmooth                      #
##################################################################################

mkdir -p build && cd build
git clone https://github.com/adworacz/zsmooth.git
cd zsmooth
zig build -j$(nproc) -Doptimize=ReleaseFast -Dtarget=x86_64-linux-gnu.2.17 -Dcpu=x86_64_v3
strip zig-out/lib/libzsmooth.so
mv zig-out/lib/libzsmooth.so $VSPREFIX/vsplugins/
chmod u=rw,g=rw,o=r $VSPREFIX/vsplugins/libzsmooth.so
cd ../..
rm -rf build
