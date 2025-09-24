##################################################################################
#                                                                                #
#                                Plugin-DotKill R2                               #
#                                                                                #
#                                                                                #
#                          https://github.com/myrsloik/DotKill                   #
##################################################################################

ghc myrsloik/DotKill .
g++ -std=c++17 $CXXFLAGS $LDFLAGS -shared dotkill1.cpp -o libdotkill.so
finish libdotkill.so
