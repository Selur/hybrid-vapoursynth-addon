##################################################################################
#                                                                                #
#                            Plugin-vs-wwxd V1.0                                 #
#                                                                                #
#                                                                                #
#     https://github.com/Jaded-Encoding-Thaumaturgy/vapoursynth-SNEEDIF          #
##################################################################################

ghc Jaded-Encoding-Thaumaturgy/vapoursynth-SNEEDIF .
sed -i 's/static *: *true/static: false/' meson.build
build libsneedif


