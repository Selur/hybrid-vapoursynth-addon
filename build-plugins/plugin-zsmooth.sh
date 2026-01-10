##################################################################################
#                                                                                #
#                          Plugin-Zsmooth v0.8                                   #
#                                                                                #
#                  https://github.com/adworacz/zsmooth/                          #
#                                                                                #
##################################################################################

wget https://github.com/adworacz/zsmooth/releases/download/0.8/zsmooth-x86_64-linux-gnu.zip
unzip zsmooth-x86_64-linux-gnu.zip
mkdir -p $VSPREFIX/vsplugins/
strip zig-out/lib/libzsmooth.so
mv zig-out/lib/libzsmooth.so $VSPREFIX/vsplugins/
chmod u=rw,g=rw,o=r $VSPREFIX/vsplugins/libzsmooth.so
rm -rf zig-out
rm -f zsmooth-x86_64-linux-gnu.zip
