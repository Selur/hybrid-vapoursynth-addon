wget https://github.com/adworacz/zsmooth/releases/download/0.8/zsmooth-x86_64-linux-gnu.zip
unzip zsmooth-x86_64-linux-gnu.zip
mkdir -p $VSPREFIX/vsplugins/
mv zig-out/lib/libzsmooth.so $VSPREFIX/vsplugins/
#rm -f zsmooth-x86_64-linux-gnu.zip
