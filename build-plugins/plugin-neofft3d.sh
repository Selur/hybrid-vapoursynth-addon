##################################################################################
#                                                                                #
#                            Plugin-neo_FFT3D  R11                               #
#                                                                                #
#                                                                                #
#          https://github.com/HomeOfAviSynthPlusEvolution/neo_FFT3D              #
##################################################################################

retry_git_clone https://github.com/HomeOfAviSynthPlusEvolution/neo_FFT3D neo_FFT3D
cd neo_FFT3D

# Fix Git version string in CMakeLists.txt
# Replace the 'string(APPEND ...)' line with a safe version
sed -i 's/string(APPEND GIT_REPO_VERSION "r0")/set(GIT_REPO_VERSION "r0")/' CMakeLists.txt

# Disable parallel execution for GCC to avoid std::execution errors
sed -i 's/option(ENABLE_PAR .*ON)/option(ENABLE_PAR "Enable C++17 Parallel Execution" OFF)/' CMakeLists.txt

# Create clean build dir
mkdir -p build
cd build

# Configure with Ninja
cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Release

# Build
ninja -j$(nproc)

# Determine Git version manually for the Release folder
VERSION=$(git describe --tags --always --first-parent | tr -d '\n')r0
RELEASE_DIR=../Release_$VERSION
mkdir -p "$RELEASE_DIR"

# Copy the compiled library
LIB=$(find . -name "libneo-fft3d.so" -type f | head -n1)
cp "$LIB" "$RELEASE_DIR/"
strip "$RELEASE_DIR/libneo-fft3d.so"

# Cleanup
cd ../..
rm -rf neo_FFT3D
