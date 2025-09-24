##################################################################################
#                                                                                #
#                                   Plugin-vs-imwri R2                           #
#                                                                                #
#                                                                                #
#                  https://github.com/vapoursynth/vs-imwri                       #
##################################################################################

#requires imagemagick at leat 700, provided is 6911\
#we let imagemagik v6911 installed because inkscape and gscan2pdf depend on

ghdl ImageMagick/ImageMagick imagmgck
./configure
make
sudo make install
sudo ldconfig
if [ -e "/usr/bin/convert"]; then
  sudo mv /usr/bin/convert /usr/bin/convert.old
fi
if [ -e "/usr/bin/conjure"]; then
  sudo mv /usr/bin/conjure /usr/bin/conjure.old
fi
sudo apt remove libmagick++-6-headers \
libmagick++-6.q16-dev \
libmagick++-6.q16hdri-dev \
libmagick++-dev \
libmagickcore-6.q16-dev \
libmagickcore-6.q16hdri-dev \
libmagickcore-dev \
libmagickwand-6-headers \
libmagickwand-6.q16-dev \
libmagickwand-6.q16hdri-dev \
libmagickwand-dev
mkgh vapoursynth/vs-imwri libimwri
cd ..
rm -rf build
