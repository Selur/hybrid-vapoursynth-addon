##################################################################################
#                                                                                #
#                                Plugin-FFT3DFilter R2.AC3                       #
#                                                                                #
#                                                                                #
#         https://github.com/AmusementClub/VapourSynth-FFT3DFilter               #
##################################################################################

ghc AmusementClub/VapourSynth-FFT3DFilter .
meson setup build
if ! ninja -C build -j4 ; then
  sed -i 's|fftwf_make_planner_thread_safe();||g; s|constexpr||g' FFT3DFilter.cpp  # hack
  ninja -C build -j4
fi
finish build/libfft3dfilter.so
