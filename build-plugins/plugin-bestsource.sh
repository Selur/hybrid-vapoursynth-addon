##################################################################################
#                                                                                #
#                            Plugin-bestsource R16                               #
#                                                                                #
#                                                                                #
#                   github.com/vapoursynth/bestsource.git                        #
##################################################################################

# Library Type direkt hier setzen (static oder shared) / Set library type directly here (static or shared)
LIBRARY_TYPE="static"  # Aendern Sie zu "shared" für shared object .so Bibliothek / Change to “shared” for shared object .so library.

# Automatische Erkennung von default_library Parameter / Automatic detection of default_library parameter
LIB_TYPE="$LIBRARY_TYPE"
if [ "$LIBRARY_TYPE" = "static" ]; then
    MESON_ARGS="-Ddefault_library=static"
else
    MESON_ARGS="-Ddefault_library=shared"
fi

git clone https://github.com/vapoursynth/bestsource.git --depth=1 --recurse-submodules --shallow-submodules --remote-submodules build
cd build
git submodule update --init --recursive --depth=1
meson setup build $MESON_ARGS
ninja -C build
cd build
if [ "$LIB_TYPE" = "shared" ]; then
    finish libbestsource.so
else
    finish libbestsource.a
fi
cd ..
rm -rf build
