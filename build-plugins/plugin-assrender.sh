git clone https://github.com/AmusementClub/assrender
cd assrender
cmake -B build -S .
cmake --build build --clean-first
cd build/src
echo "PING 1"
ls
echo "PING 2"
chmod a-x libassrender.so
echo "PING 3"
strip libassrender.so
echo "PING 4"
nm -D --extern-only libassrender.so
echo "PING 5"
mkdir -p "$VSPREFIX/vsplugins"
echo "PING 6"
cp -f libassrender.so "$VSPREFIX/vsplugins/"
echo "PING 7"
cd ..
echo "PING 8"
cd ..
echo "PING 9"
rm -rf assrender
echo "PING 10"
