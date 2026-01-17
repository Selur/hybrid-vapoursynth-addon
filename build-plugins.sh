#!/bin/bash
# -----------------------------------------------------------------------------
# Scriptname: build-plugins.sh
# Datum: $(date "+%Y-%m-%d")
# Uhrzeit: $(date "+%H:%M:%S")
# Beschreibung: Dieses Skript installiert die erforderlichen Pakete und
#               baut die Vapoursynth-Plugins. Es ist für Ubuntu 24.04 LTS oder
#               neuer konzipiert und überprüft die Abhängigkeiten, bevor
#               es mit dem Build-Prozess fortfährt.
#
# Description: This script installs the required packages and builds the
#              Vapoursynth plugins. It is designed for Ubuntu 24.04 LTS or
#              newer and checks for dependencies before proceeding with the
#              build process.
# -----------------------------------------------------------------------------

set -euo pipefail

s_begin=$(date "+%s")

. ./config.txt
export CFLAGS="-pipe -O3 -fno-strict-aliasing -Wno-deprecated-declarations"
export CXXFLAGS="$CFLAGS"

# Funktion zur Ausgabe von Meldungen in der richtigen Sprache
print_message() {
  case "$LANG" in
    de_* )
      printf "%b\n" "$1"
      ;;
    * )
      printf "%b\n" "$2"
      ;;
  esac
}

# Funktion zur Fehlerbehandlung
handle_error() {
  print_message "$1" "$2"
  exit 1
}

# Funktion zur Aufräumarbeit
cleanup() {
  print_message "Aufräumarbeiten werden durchgeführt..." "Clean-up work is carried out..."
  if [ -d build ]; then
    rm -rf build
  fi
}

trap 'cleanup; exit' EXIT
trap 'cleanup; handle_error "Das Skript wurde mit einem Fehler beendet." "The script exited with an error."' ERR

# Funktion zur Überprüfung der erforderlichen Pakete
check_dependencies() {
  if [ ! -e "$my_pkg_config_path/vapoursynth.pc" ] && [ ! -e "$my_pkg_config_path/libavcodec.pc" ]; then
    handle_error "Fehler: Fehlende lokale Installation der FFmpeg-Bibliotheken und Vapoursynth in \`$VSPREFIX'" \
                 "error: missing a local installation of FFmpeg libraries and Vapoursynth in \`$VSPREFIX'"
    print_message "Haben Sie vergessen, \`build-vapoursynth.sh' vorher auszuführen?" \
                  "Have you forgotten to run \`build-vapoursynth.sh' before?"
  fi
}

# Funktion zur Installation der Systempakete
install_system_packages() {
  sudo apt update
  sudo apt upgrade -y

  # Sicherstellen, dass opencv zuerst installiert ist
  sudo apt-get install -y libopencv-dev

  # Installation der benötigten Pakete
  sudo apt install --no-install-recommends -y \
      build-essential cmake yasm git wget mercurial unzip meson p7zip-full \
      python3-pip zlib1g-dev libfftw3-dev libopencv-dev ocl-icd-opencl-dev \
      opencl-headers libboost-dev libboost-filesystem-dev libboost-system-dev \
      libbluray-dev libpng-dev libjansson-dev python3-testresources libxxhash-dev \
      libturbojpeg0-dev python3-setuptools python3-wheel python-is-python3 \
      libxxhash-dev vulkan-validationlayers libvulkan1 g++-11 llvm-14 \
      dos2unix \
      llvm-dev libgsl-dev libheif-dev \
      llvm-20-dev clang-20 libclang-20-dev lld-20 liblld-20 liblld-20-dev #zig Dependencies
}

# Funktion zum Erstellen des Build-Verzeichnisses
create_build_directory() {
  if [ -d build ]; then
    rm -rf build
  fi
  mkdir -p build/logs || handle_error "Fehler beim Erstellen des Build-Verzeichnisses." "Error creating build directory."
  cd build || handle_error "Fehler beim Wechseln in das Build-Verzeichnis." "Error changing to build directory."
}

# Funktion zum Installieren von NASM
install_nasm() {
# ------------------------------------------------
# NASM - The Netwide Assembler https://www.nasm.us
# ------------------------------------------------
  if [ ! -x "$VSPREFIX/bin/nasm" ]; then
    ver="2.16.03"
    wget -c "https://www.nasm.us/pub/nasm/releasebuilds/$ver/nasm-${ver}.tar.xz" || handle_error "Fehler beim Herunterladen von NASM." "Error downloading NASM."
    tar xf "nasm-${ver}.tar.xz"
    cd "nasm-$ver" || handle_error "Fehler beim Wechseln in das NASM-Verzeichnis." "Error changing to NASM directory."
    ./configure --prefix="$VSPREFIX"
    make -j"$JOBS"
    make install
    cd .. || handle_error "Fehler beim Zurückwechseln in das vorherige Verzeichnis." "Error changing back to the previous directory."
    rm -rf "nasm-$ver" "nasm-${ver}.tar.xz"
  fi
}

# Funktion zum Installieren von ZIG
install_zig() {
# ------------------------------------
# ZIG https://codeberg.org/ziglang/zig
# ------------------------------------
  if [ ! -x "$VSPREFIX/bin/zig" ]; then
    ZIG_VERSION="0.15.2"
    git clone --branch $ZIG_VERSION --depth 1 https://codeberg.org/ziglang/zig.git zig-$ZIG_VERSION || handle_error "Fehler beim Klonen des ZIG-Repos." "Error cloning ZIG-Repo."
    cd zig-$ZIG_VERSION || handle_error "Fehler beim Wechseln in das ZIG-Verzeichnis." "Error changing to ZIG directory."
    mkdir build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX="$VSPREFIX" \
     -DCMAKE_PREFIX_PATH="$VSPREFIX" \
     -DCMAKE_BUILD_TYPE=Release \
     -DZIG_VERSION="$ZIG_VERSION"
    cmake --build . --parallel "$(nproc)" --target install
    strip "$VSPREFIX/bin/zig" || true
    cd .. || handle_error "Fehler beim Zurückwechseln in das vorherige Verzeichnis." "Error changing back to the previous directory."
    rm -rf build
    cd ../
    rm -rf build
  fi
}

# Globale Variable für spezifisches Plugin
specific_plugin=""

# Funktion zum Bauen der Plugins
build_plugins() {
  readarray -t plugins < <(find ../build-plugins -name 'plugin-*.sh' -exec basename {} .sh \; | sort)
  local count=${#plugins[@]}
  local n=0
  local success=true
  local failed_plugin=""

  if [ -n "$specific_plugin" ]; then
    print_message "\nDas Plugin '$specific_plugin' wird gebaut:\n" "\nBuilding the plugin '$specific_plugin':\n"
  else
    print_message "\nPlugins werden gebaut:\n" "\nBuilding plugins:\n"
  fi

  export vsprefix="$VSPREFIX"

  if [ -n "$specific_plugin" ]; then
    if [[ "$specific_plugin" != plugin-* ]]; then
      specific_plugin="plugin-$specific_plugin"
    fi
  fi

  for p in "${plugins[@]}"; do
    if [ -n "$specific_plugin" ] && [ "$p" != "$specific_plugin" ]; then
      continue
    fi

    n=$((n + 1))
    if [ -n "$specific_plugin" ]; then
      printf " %s (1/1) ... " "$p"
    else
      printf " %s (%d/%d) ... " "$p" "$n" "$count"
    fi

    cat "../build-plugins/header.sh" "../build-plugins/${p}.sh" > build.sh
    if bash ./build.sh > "logs/${p}.log" 2>&1; then
      print_message "fertig" "done"
    else
      print_message "fehlgeschlagen bei $p" "failed for $p"
      success=false
      failed_plugin="$p"
    fi

    if [ -d build ]; then
      rm -rf build
    fi
    if [ -f build.sh ]; then
      rm -f build.sh
    fi
  done

  unset vsprefix

  if $success; then
    if [ -n "$specific_plugin" ]; then
      print_message "\nDas Plugin '$specific_plugin' wurde erfolgreich erstellt." "The plugin '$specific_plugin' was built successfully."
    else
      print_message "\nAlle Plugins wurden erfolgreich erstellt." "All plugins were built successfully."
    fi
  else
    print_message "\nDas Plugin '$failed_plugin' konnte nicht erstellt werden." "The plugin '$failed_plugin' failed to build."
  fi
}

if [ $# -gt 0 ]; then
  specific_plugin="$1"
fi

main() {
  check_dependencies
  install_system_packages
  create_build_directory
  install_nasm
  install_zig
  build_plugins

  if cd ..; then
    if [ -d build ]; then
      rm -rf build
    fi
  else
    handle_error "Fehler beim Zurückwechseln in das vorherige Verzeichnis." "Error changing back to the previous directory."
  fi

  s_end=$(date "+%s")
  s=$((s_end - s_begin))
  print_message "Fertig nach $((s / 60)) min $((s % 60)) sec" "Finished after $((s / 60)) min $((s % 60)) sec"
  exit 0
}

main
