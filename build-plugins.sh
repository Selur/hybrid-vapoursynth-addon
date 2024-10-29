#!/bin/bash
# -----------------------------------------------------------------------------
# Scriptname: build-plugins.sh
# Datum: $(date "+%Y-%m-%d")          # Date: $(date "+%Y-%m-%d")
# Uhrzeit: $(date "+%H:%M:%S")        # Time: $(date "+%H:%M:%S")
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
      printf "%b\n" "$1"  # Deutsch
      ;;
    * )
      printf "%b\n" "$2"  # Englisch
      ;;
  esac
}

# Funktion zur Fehlerbehandlung
handle_error() {
  print_message "$1" "$2"
  exit 1
}

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
  # Update der Paketlisten
  sudo apt update

  # Upgrade der installierten Pakete
  sudo apt upgrade -y

  # Installation der benötigten Pakete
  sudo apt install --no-install-recommends -y \
      build-essential cmake yasm git wget mercurial unzip meson p7zip-full \
      python3-pip zlib1g-dev libfftw3-dev libopencv-dev ocl-icd-opencl-dev \
      opencl-headers libboost-dev libboost-filesystem-dev libboost-system-dev \
      libbluray-dev libpng-dev libjansson-dev python3-testresources libxxhash-dev \
      libturbojpeg0-dev python3-setuptools python3-wheel python-is-python3 \
      libxxhash-dev vulkan-validationlayers libvulkan1 g++ llvm \
      libgsl-dev libheif-dev libjxl-dev

  # Überprüfen, ob g++-11 und llvm-14 verfügbar sind und installieren, falls nötig
  if command -v lsb_release &> /dev/null && [[ $(lsb_release -is) == "Ubuntu" ]]; then
    sudo apt install -y g++-11 llvm-14
  else
    # Für Debian Sid, die neuesten Versionen von g++ und llvm installieren
    sudo apt install -y g++ llvm
  fi
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
  if [ ! -x "$VSPREFIX/bin/nasm" ]; then
    ver="2.14.02"
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

# Globale Variable für das spezifische Plugin
specific_plugin=""  # Setze hier den Namen des spezifischen Plugins oder lasse es leer für alle

# Funktion zum Bauen der Plugins
build_plugins() {
  # Überprüfen, ob ein spezifisches Plugin über die Umgebungsvariable gesetzt wurde
  readarray -t plugins < <(find ../build-plugins -name 'plugin-*.sh' -exec basename {} .sh \; | sort)
  local count=${#plugins[@]}
  local n=0
  local success=true  # Variable zur Überwachung des Erfolgs
  local failed_plugin=""  # Variable zur Speicherung des fehlgeschlagenen Plugins

  # Angepasste Meldung für den Bauprozess
  if [ -n "$specific_plugin" ]; then
    print_message "\nDas Plugin '$specific_plugin' wird gebaut:\n" "\nBuilding the plugin '$specific_plugin':\n"
  else
    print_message "\nPlugins werden gebaut:\n" "\nBuilding plugins:\n"
  fi

  export vsprefix="$VSPREFIX"

  # Wenn ein spezifisches Plugin angegeben ist, Prefix hinzufügen, falls nötig
  if [ -n "$specific_plugin" ]; then
    if [[ "$specific_plugin" != plugin-* ]]; then
      specific_plugin="plugin-$specific_plugin"
    fi
  fi

  for p in "${plugins[@]}"; do
    # Wenn ein spezifisches Plugin angegeben ist, überspringe andere
    if [ -n "$specific_plugin" ] && [ "$p" != "$specific_plugin" ]; then
      continue
    fi

    n=$((n + 1))

    # Wenn ein spezifisches Plugin gebaut wird, setze die Zählung auf 1/1
    if [ -n "$specific_plugin" ]; then
      printf " %s (1/1) ... " "$p"
    else
      printf " %s (%d/%d) ... " "$p" "$n" "$count"
    fi

    # Erstellen des Build-Skripts
    cat "../build-plugins/header.sh" "../build-plugins/${p}.sh" > build.sh

    # Ausführen des Build-Skripts und Protokollierung
    if bash ./build.sh > "logs/${p}.log" 2>&1; then
      print_message "fertig" "done"
    else
      print_message "fehlgeschlagen bei $p" "failed for $p"
      success=false  # Setze den Erfolg auf false, wenn ein Fehler auftritt
      failed_plugin="$p"  # Speichere den Namen des fehlgeschlagenen Plugins
    fi

    # Sicherstellen, dass das Verzeichnis existiert, bevor es gelöscht wird
    if [ -d build ]; then
      rm -rf build
    fi
    rm -f build.sh
  done

  unset vsprefix
  # Abschlussmeldung basierend auf dem Erfolg
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


# Optional: Überprüfen, ob ein spezifisches Plugin als Argument übergeben wurde
if [ $# -gt 0 ]; then
  specific_plugin="$1"
fi

# Hauptfunktion
main() {
  check_dependencies
  install_system_packages
  create_build_directory
  install_nasm
  build_plugins

# Zurückwechseln in das vorherige Verzeichnis und das Build-Verzeichnis löschen
  if cd ..; then
    if [ -d build ]; then
      rm -rf build
    fi
  else
    handle_error "Fehler beim Zurückwechseln in das vorherige Verzeichnis." "Error changing back to the previous directory."
  fi

  # Berechnung der verstrichenen Zeit
  s_end=$(date "+%s")
  s=$((s_end - s_begin))
  print_message "Fertig nach $((s / 60)) min $((s % 60)) sec" "Finished after $((s / 60)) min $((s % 60)) sec"
  exit 0  # Erfolgreich beenden
}

main
