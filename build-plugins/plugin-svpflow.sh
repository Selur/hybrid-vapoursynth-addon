##################################################################################
#                                                                                #
#                                 Plugin-svpflow                                 #
#                                                                                #
#                  https://www.svp-team.com/files/svp4-latest.php?linux          #
#                            https://www.svp-team.com/                           #
##################################################################################

mkdir build
cd build
wget -O svpflow.zip https://www.svp-team.com/files/gpl/svpflow-4.3.0.168.zip
unzip -j svpflow.zip
mv libsvpflow1_vs64.so libsvpflow1.so
mv libsvpflow2_vs64.so libsvpflow2.so
strip_copy libsvpflow1.so
finish libsvpflow2.so
