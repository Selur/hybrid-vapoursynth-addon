#requires imagemagick at leat 7.0.0, provided is 6.9.11
#we let imagemagik c6.9.11 installed because inkscape and gscan2pdf depend on
ghdl ImageMagick/ImageMagick imagmgck
./configure
make
sudo make install
sudo ldconfig
sudo mv /usr/bin/convert /usr/bin/convert.old
sudo mv /usr/bin/conjure /usr/bin/conjure.old
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
