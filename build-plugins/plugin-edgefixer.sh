##################################################################################
#                                                                                #
#                                Plugin-EdgeFixer R2                             #
#                                                                                #
#                                                                                #
#                       https://github.com/sekrit-twc/EdgeFixer                  #
##################################################################################

ghdl sekrit-twc/EdgeFixer
gcc $CFLAGS $LDFLAGS EdgeFixer/*.c -o libedgefixer.so -lm -shared
finish libedgefixer.so


