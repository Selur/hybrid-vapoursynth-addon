ghc myrsloik/VapourSynth-FFT3DFilter 5095c9a7a15e4eeb00ccb5c1a8b5e643287febf2
meson build
if ! ninja -C build -j4 ; then
  sed -i 's|fftwf_make_planner_thread_safe();||g; s|constexpr||g' FFT3DFilter.cpp  # hack
  ninja -C build -j4
fi
finish build/libfft3dfilter.so
