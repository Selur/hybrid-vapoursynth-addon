#mkghc IFeelBloated/vapoursynth-mvtools-sf libmvtoolssf 5dfa8756092daa7dcc635eef799c6964bd40c259
ghdl IFeelBloated/vapoursynth-mvtools-sf
#ghc IFeelBloated/vsFilterScript d9695569b5d96064f54dffc62c4624d9fa711d20
ghc IFeelBloated/vsFilterScript dc7efc9a58a388dee45147e1b44bace9118acb36
CFLAGS="$CFLAGS -Wno-deprecated-declarations" meson build --prefix="$vsprefix"
ninja -C build -j $JOBS
ninja -C build install -j $JOBS
