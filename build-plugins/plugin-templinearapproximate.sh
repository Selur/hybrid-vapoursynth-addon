######################################################################################
#                                                                                    #
#                           Plugin-vs-TempLinearApproximate                          #
#                                                                                    #
#                                                                                    #
# https://bitbucket.org/mystery_keeper/templinearapproximate-vapoursynth/src/master/ #
######################################################################################

retry_git_clone https://bitbucket.org/mystery_keeper/templinearapproximate-vapoursynth build
cd build
gcc $CFLAGS -Isrc -c src/main.c -o main.o
gcc $CFLAGS -Isrc -c src/processplane.c -o processplane.o
gcc $LDFLAGS -shared -o libtemplinearapproximate.so main.o processplane.o -lm
finish libtemplinearapproximate.so
