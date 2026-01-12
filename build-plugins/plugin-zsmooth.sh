
##################################################################################
#                                                                                #
#                          Plugin-Zsmooth v0.8                                   #
#                                                                                #
#                  https://github.com/adworacz/zsmooth/                          #
#                                                                                #
##################################################################################

# Umgebungsvariable hat Vorrang (Standard: ZIP)
CHOICE="${ZS_BUILD_METHOD:-1}"

print_message "libzsmooth.so (Methode $CHOICE)..." "libzsmooth.so (method $CHOICE)..."

mkdir -p "$VSPREFIX/vsplugins/"

if [[ "$CHOICE" == "2" ]]; then
    # Zig Build
    print_message "🔧 Kompiliere libzsmooth.so mit Zig..." \
                  "🔧 Compiling libzsmooth.so with Zig..."
    mkdir -p build && cd build
    git clone https://github.com/adworacz/zsmooth.git
    cd zsmooth
    zig build -j"$(nproc)" -Doptimize=ReleaseFast \
        -Dtarget=x86_64-linux-gnu.2.17 -Dcpu=x86_64_v3
    strip zig-out/lib/libzsmooth.so
    mv zig-out/lib/libzsmooth.so "$VSPREFIX/vsplugins/"
    cd ../..
    rm -rf build
else
    # ZIP Download
    print_message "⬇️ Lade libzsmooth.so aus ZIP..." \
                  "⬇️ Downloading libzsmooth.so from ZIP..."
    wget -q https://github.com/adworacz/zsmooth/releases/download/0.8/zsmooth-x86_64-linux-gnu.zip
    unzip -q zsmooth-x86_64-linux-gnu.zip
    strip zig-out/lib/libzsmooth.so
    mv zig-out/lib/libzsmooth.so "$VSPREFIX/vsplugins/"
    rm -rf zig-out zsmooth-x86_64-linux-gnu.zip
fi

chmod u=rw,g=rw,o=r "$VSPREFIX/vsplugins/libzsmooth.so"
print_message "✅ libzsmooth.so erfolgreich installiert!" \
              "✅ libzsmooth.so successfully installed!"
