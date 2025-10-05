#!/bin/bash
# -----------------------------------------------------------------------------
# Scriptname: header.sh
# Datum: $(date "+%Y-%m-%d")          # Date: $(date "+%Y-%m-%d")
# Uhrzeit: $(date "+%H:%M:%S")        # Time: $(date "+%H:%M:%S")
# Beschreibung: Dieses Skript tut nichts; Es ist der Kopf aller anderen
#               Build-Plugin-Skripte als Vorlage wie plugin-*.sh
#               Es ist für Ubuntu 24.04 LTS oder neuer konzipiert.
#
# Description: This script does nothing; It's the header of all other
#              build-plugins scripts as a template like plugin-*.sh
#              It is designed for Ubuntu 24.04 LTS or newer.
# -----------------------------------------------------------------------------

set -euo pipefail

. ../config.txt

export CFLAGS="-pipe -O3 -Wno-attributes -fPIC -fvisibility=hidden -fno-strict-aliasing $(pkg-config --cflags vapoursynth) -I/usr/include/compute"
export CXXFLAGS="$CFLAGS -Wno-reorder"
export LDFLAGS="-L$VSPREFIX/lib"

max_attempts=3

# Funktion zur Ausgabe von Meldungen in der richtigen Sprache
print_message() {
  local message_de="$1"
  local message_en="$2"
  case "$LANG" in
    de_* ) printf "%b\n" "$message_de" ;;
    * ) printf "%b\n" "$message_en" ;;
  esac
}

handle_error() {
  local lang="$1"
  local error_message="$2"
  print_message "$lang" "$error_message"
  exit 1
}

retry_git_clone() {
  local repo_url="$1"
  local target_dir="$2"
  local attempts=0

  while true; do
    if [ "$attempts" -ge "$max_attempts" ]; then
      handle_error "Maximale Anzahl an Klonversuchen erreicht. Beende das Skript." "Maximum number of clone attempts reached. Exiting."
    fi

    if [ -n "$target_dir" ]; then
      if git clone --depth 1 --recursive "$repo_url.git" "$target_dir"; then
        break
      else
        attempts=$((attempts + 1))
        print_message "Klonversuch $attempts fehlgeschlagen. Erneuter Versuch in 5 Sekunden..." "Clone attempt $attempts failed. Retrying in 5 seconds..."
        sleep 5
      fi
    else
      if git clone --depth 1 --recursive "$repo_url.git"; then
        break
      else
        attempts=$((attempts + 1))
        print_message "Klonversuch $attempts fehlgeschlagen. Erneuter Versuch in 5 Sekunden..." "Clone attempt $attempts failed. Retrying in 5 seconds..."
        sleep 5
      fi
    fi
  done
}

ghdl() {
  retry_git_clone "https://github.com/$1" build
  cd build
}

strip_copy() {
  chmod a-x "$1"
  strip "$1"
  # Überprüfe, ob das Symbol vorhanden ist
  symbol_found=false
 if nm -D --extern-only "$1" | grep -q 'T VapourSynthPluginInit'; then
     symbol_found=true
 fi

 # Status von symbol_found
 if $symbol_found; then
     # Symbol gefunden, aber keine Ausgabe
     :
 else
     # Symbol nicht gefunden, aber keine Ausgabe
     :
 fi
 mkdir -p "$VSPREFIX/vsplugins"
 cp -f "$1" "$VSPREFIX/vsplugins/"
}

finish() {
  strip_copy "$1"
  rm -rf build
}

build() {
  if [ -f meson.build ]; then
    meson setup build
    ninja -C build -j"$JOBS"
  elif [ -f waf ]; then
    python3 ./waf configure
    python3 ./waf build -j"$JOBS"
  else
    if [ ! -e configure ] && [ -f configure.ac ]; then
      autoreconf -if
    fi

    if [ -e configure ]; then
      chmod a+x configure
      if grep -q -- '--extra-cflags' configure && grep -q -- '--extra-cxxflags' configure; then
        ./configure --extra-cflags="$CFLAGS" --extra-cxxflags="$CXXFLAGS" --extra-ldflags="$LDFLAGS" || cat config.log
      elif grep -q -- '--extra-cflags' configure; then
        ./configure --extra-cflags="$CFLAGS" --extra-ldflags="$LDFLAGS" || cat config.log
      elif grep -q -- '--extra-cxxflags' configure; then
        ./configure --extra-cxxflags="$CXXFLAGS" --extra-ldflags="$LDFLAGS" || cat config.log
      else
        ./configure || cat config.log
      fi
    fi
    make -j"$JOBS" X86=1
  fi

  if [ -e .libs/${1}.so ]; then
    finish .libs/${1}.so
  elif [ -e build/${1}.so ]; then
    finish build/${1}.so
  else
    finish ${1}.so
  fi
}

mkgh() {
  ghdl "$1"
  build "$2"
}

mkghv() {
  ghdl "$1"
  cd vapoursynth || handle_error "Fehler beim Wechseln in das Verzeichnis vapoursynth." "Error changing to the vapoursynth directory."
  build "$2"
}

ghc() {
  retry_git_clone "https://github.com/$1" build
  cd build || handle_error "Fehler beim Wechseln in das Verzeichnis build." "Error changing to the build directory."
  git -c advice.detachedHead=false checkout "$2"
  git reset --hard
}

mkghc() {
  ghc "$1" "$3"
  build "$2"
}
