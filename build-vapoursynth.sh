#!/bin/bash
# -----------------------------------------------------------------------------
# Scriptname: build-vapoursynth.sh
# Datum: $(date "+%Y-%m-%d")          # Date: $(date "+%Y-%m-%d")
# Uhrzeit: $(date "+%H:%M:%S")        # Time: $(date "+%H:%M:%S")
# Beschreibung: Dieses Skript installiert die erforderlichen Pakete und
#               baut Vapoursynth. Es ist für Ubuntu 24.04 LTS oder
#               neuer konzipiert und überprüft die Abhängigkeiten, bevor
#               es mit dem Build-Prozess fortfährt.
# -----------------------------------------------------------------------------

set -euo pipefail

# Funktion zur Ausgabe von Meldungen in der richtigen Sprache
print_message() {
  local message_de="$1"
  local message_en="$2"
  case "$LANG" in
    de_* ) printf "%b\n" "$message_de" ;;
    * ) printf "%b\n" "$message_en" ;;
  esac
}

# Funktion zur Fehlerbehandlung
handle_error() {
  print_message "$1" "$2"
  exit 1
}

# Funktion zum Klonen von Git-Repositories mit Wiederholungsversuchen
retry_git_clone() {
  local repo_url="$1"
  local target_dir="${2:-$(basename "$repo_url" .git)}"  # Standardwert für target_dir
  local attempts=0
  local max_attempts=3
  local wait_time=5

  while (( attempts < max_attempts )); do
    if git clone --depth 1 "$repo_url" "$target_dir"; then
      return 0
    else
      attempts=$((attempts + 1))
      print_message "Klonversuch $attempts fehlgeschlagen. Erneuter Versuch in $wait_time Sekunden..." "Clone attempt $attempts failed. Retrying in $wait_time seconds..."
      sleep "$wait_time"
    fi
  done
  handle_error "Maximale Anzahl an Klonversuchen erreicht." "Maximum number of clone attempts reached."
}

# Funktion zur Installation der benötigten Pakete
install_packages() {
  print_message "Installiere benötigte Pakete..." "Installing required packages..."
  sudo apt update && sudo apt upgrade -y
  sudo apt install --no-install-recommends -y \
    build-essential git python3-pip autoconf automake libtool \
    libtool-bin libltdl-dev libva-dev libvdpau-dev libass-dev \
    libtesseract-dev libleptonica-dev zlib1g-dev libbz2-dev \
    libjpeg-dev libpng-dev libtiff-dev liblzma-dev libfontconfig-dev \
    libfreetype6-dev libfftw3-dev libpango1.0-dev libopenjp2-7-dev \
    libxml2-dev nasm cython3 || handle_error "Fehler bei der Installation der Pakete." "Error installing packages."
}

# Funktion zum Bauen von nv-codec-headers
build_nv_codec_headers() {
  local repo_url="$1"

  if [[ -f "$my_pkg_config_path/ffnvcodec.pc" ]]; then
    print_message "nv-codec-headers ist bereits installiert." "nv-codec-headers is already installed."
    return
  fi

  print_message "Baue nv-codec-headers..." "Building nv-codec-headers..."

  # Klonen des Repositories mit Wiederholungsversuchen
  retry_git_clone "$repo_url"

  # Installiere nv-codec-headers
  make -C nv-codec-headers install PREFIX="$VSPREFIX" || handle_error "Fehler beim Installieren von 'nv-codec-headers'." "Error installing 'nv-codec-headers'."

  # Lösche das Verzeichnis nach der Installation
  rm -rf nv-codec-headers || handle_error "Fehler beim Löschen des Verzeichnisses 'nv-codec-headers'." "Error deleting 'nv-codec-headers' directory."
}

# Funktion zum Bauen eines Pakets
build_package() {
  local repo_url="$1"
  local package_name=$(basename "$repo_url" .git)

    # Überprüfen, ob das Paket bereits installiert ist
  if [[ "$package_name" == "FFmpeg" ]]; then
    if [[ -f "$my_pkg_config_path/libavcodec.pc" ]]; then
      print_message "$package_name ist bereits installiert." "$package_name is already installed."
      return
    fi
  else
    if [[ -f "$my_pkg_config_path/$package_name.pc" ]]; then
      print_message "$package_name ist bereits installiert." "$package_name is already installed."
      return
    fi
  fi

  print_message "Baue $package_name..." "Building $package_name..."

    # Klonen des Repositories mit dem spezifischen Branch für FFmpeg
    if [[ "$package_name" == "FFmpeg" ]]; then
      git clone --branch release/6.1 --single-branch "$repo_url" || handle_error "Fehler beim Klonen des Repositories '$repo_url'." "Error cloning repository '$repo_url'."
    else
      retry_git_clone "$repo_url"
    fi

    cd "$package_name" || handle_error "Fehler beim Wechseln in das Verzeichnis '$package_name'." "Error changing to '$package_name' directory."

    # Submodule aktualisieren
    git submodule update --init --recursive || handle_error "Fehler beim Aktualisieren der Submodule in '$package_name'." "Error updating submodules in '$package_name'."

    # Konfiguration und Build
    # Konfigurationsoptionen festlegen
    local configure_options=""

    case "$package_name" in
      "zimg")
        configure_options="--prefix="$VSPREFIX" --disable-static"
        autoreconf -if || handle_error "Fehler beim Ausführen von autoreconf in '$package_name'." "Error running autoreconf in '$package_name'."
        ;;
      "ImageMagick")
        configure_options="--prefix="$VSPREFIX" --disable-static --disable-docs --without-utilities --enable-hdri --with-quantum-depth=16"
        autoreconf -if || handle_error "Fehler beim Ausführen von autoreconf in '$package_name'." "Error running autoreconf in '$package_name'."
        ;;
      "FFmpeg")
        configure_options="--prefix="$VSPREFIX" --disable-static --enable-shared --disable-programs --disable-doc --disable-debug --enable-ffnvcodec --enable-nvdec --enable-nvenc --enable-cuvid --enable-vaapi --enable-vdpau"
        ;;
      "vapoursynth")
        configure_options="--prefix="$VSPREFIX" --disable-static"
        autoreconf -if || handle_error "Fehler beim Ausführen von autoreconf in '$package_name'." "Error running autoreconf in '$package_name'."
        ;;
      *)
        handle_error "Unbekanntes Paket: $package_name" "Unknown package: $package_name"
        ;;
    esac

    # Führe das configure-Skript aus
    ./configure $configure_options || handle_error "Fehler bei der Konfiguration von '$package_name'." "Error configuring '$package_name'."

    # Kompilieren und Installieren
    make -j"$JOBS" || handle_error "Fehler beim Kompilieren von '$package_name'." "Error building '$package_name'."

    # Installiere das Paket
    if [[ "$package_name" == "FFmpeg" ]]; then
      make install || handle_error "Fehler beim Installieren von '$package_name'." "Error installing '$package_name'."
    else
      make install-strip || handle_error "Fehler beim Installieren von '$package_name'." "Error installing '$package_name'."
    fi

    cd "$build_pwd" || handle_error "Fehler beim Wechseln in das ursprüngliche Verzeichnis." "Error changing back to original directory."
    rm -rf "$package_name" || handle_error "Fehler beim Löschen des Verzeichnisses '$package_name'." "Error deleting '$package_name' directory."
}

# Hauptfunktion
main() {
  s_begin=$(date "+%s")
  . ./config.txt

  export CFLAGS="-pipe -O3 -fno-strict-aliasing -Wno-deprecated-declarations"
  export CXXFLAGS="$CFLAGS"

  install_packages

  TOP="$PWD"
  rm -rf build || handle_error "Fehler beim Löschen des Verzeichnisses 'build'." "Error deleting 'build' directory."
  mkdir build || handle_error "Fehler beim Erstellen des Verzeichnisses 'build'." "Error creating 'build' directory."
  cd build || handle_error "Fehler beim Wechseln in das Verzeichnis 'build'." "Error changing to 'build' directory."
  build_pwd="$PWD"

  # Build zimg
  build_package "https://github.com/sekrit-twc/zimg.git"

  # Build ImageMagick
  build_package "https://github.com/ImageMagick/ImageMagick.git"

  # Build nv-codec-headers für NVIDIA Unterstützung in FFmpeg
  build_nv_codec_headers "https://github.com/FFmpeg/nv-codec-headers.git"

  # Build FFmpeg
  build_package "https://github.com/FFmpeg/FFmpeg.git"

  # Build VapourSynth
  build_package "https://github.com/vapoursynth/vapoursynth.git"

  # Erstellen der Umgebungsvariablen-Skripte
  print_message "Erstelle \`$VSPREFIX/env.sh' und \`$VSPREFIX/env.csh'..." "Creating \`$VSPREFIX/env.sh' and \`$VSPREFIX/env.csh'..."
  cat <<EOF >"$VSPREFIX/env.sh"
# source this file with
# . "$VSPREFIX/env.sh"
# in order to use vspipe from your local installation of vapoursynth,
# which is in the read only \$VSPREFIX variable.
#
export VSPREFIX="$VSPREFIX"
export vs_site_packages="${vs_site_packages}"
#
if [[ \$( echo "\$PATH" | egrep -Ec "(^|:)\$VSPREFIX/bin(:|\$)" ) -eq 0 ]]; then
  export PATH="\$VSPREFIX/bin:\$PATH"
fi
if [[ -z "\$LD_LIBRARY_PATH" ]]; then
  export LD_LIBRARY_PATH="\$VSPREFIX/lib"
elif [[ \$( echo "\$LD_LIBRARY_PATH" | egrep -Ec "(^|:)\$VSPREFIX/lib(:|\$)" ) -eq 0 ]]; then
  export LD_LIBRARY_PATH="\$VSPREFIX/lib:\$LD_LIBRARY_PATH"
fi
if [[ -z "\$PYTHONPATH" ]]; then
  export PYTHONPATH="\${vs_site_packages}"
elif [[ \$( echo "\$PYTHONPATH" | grep -Ec "(^|:)\${vs_site_packages}(:|\$)" ) -eq 0 ]]; then
  export PYTHONPATH="\${vs_site_packages}:\$PYTHONPATH"
fi
EOF

cat <<EOF >"$VSPREFIX/env.csh"
# source this file with
# source "$VSPREFIX/env.csh"
# in order to use vspipe from your local installation of vapoursynth,
# which is in the read only \$VSPREFIX variable.
#
setenv VSPREFIX "$VSPREFIX"
set vs_site_packages="${vs_site_packages}"
#
if ( \`echo "\$PATH" | grep -Ec "(^|:)\$VSPREFIX/bin(:|"'$'")"\` == "0" ) then
  setenv PATH "\$VSPREFIX/bin:\$PATH"
endif
if ( ! \${?LD_LIBRARY_PATH} ) then
  setenv LD_LIBRARY_PATH "$VSPREFIX/lib"
else if ( \`echo "\$LD_LIBRARY_PATH" | grep -Ec "(^|:)\$VSPREFIX/lib(:|"'$'")"\
  \` == "0" ) then
    setenv LD_LIBRARY_PATH "\$VSPREFIX/lib:\$LD_LIBRARY_PATH"
endif
if ( ! \${?PYTHONPATH} ) then
  setenv PYTHONPATH "\${vs_site_packages}"
else if ( \`echo "\$PYTHONPATH" | grep -Ec "(^|:)\${vs_site_packages}(:|"'$'")"\` == "0" ) then
  setenv PYTHONPATH "\${vs_site_packages}:\$PYTHONPATH"
endif
EOF

# Erstellen der Konfigurationsdatei für VapourSynth
conf="$HOME/.config/vapoursynth/vapoursynth.conf"
print_message "Erstelle \`$conf'..." "Creating \`$conf'..."
mkdir -p "$HOME/.config/vapoursynth" || handle_error "Fehler beim Erstellen des Verzeichnisses für die Konfigurationsdatei." "Error creating directory for configuration file."
echo "SystemPluginDir=$VSPREFIX/vsplugins" > "$conf" || handle_error "Fehler beim Schreiben in die Konfigurationsdatei." "Error writing to configuration file."

# Zeitmessung beenden und ausgeben
s_end=$(date "+%s")
s=$((s_end - s_begin))
print_message "\nFertig nach $((s / 60)) min $((s % 60)) sec" "\nFinished after $((s / 60)) min $((s % 60)) sec"
}

# Aufruf der Hauptfunktion
main
