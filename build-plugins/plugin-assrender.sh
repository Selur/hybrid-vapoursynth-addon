retry_git_clone https://github.com/AmusementClub/assrender
cd assrender
cmake -B build -S .
cmake --build build --clean-first
cd build/src
ls
chmod a-x libassrender.so
strip libassrender.so
nm -D --extern-only libassrender.so
mkdir -p "$VSPREFIX/vsplugins"
cp -f libassrender.so "$VSPREFIX/vsplugins/"
cd ..
cd ..
rm -rf assrender
