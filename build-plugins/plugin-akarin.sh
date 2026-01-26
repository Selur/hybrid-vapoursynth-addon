####################################################################
##                     Plugin-Akarin v0.95                        ##
##              Outdated! Last commit: Mar 26, 2023               ##
##                                                                ##
##      https://github.com/AkarinVS/vapoursynth-plugin            ##
####################################################################

# Ubuntu 24.04 Noble: LLVM 14, 15 | Debian Trixie: LLVM 14, 15, 16
# Akarin-Plugin erfordert LLVM < 16 (meson.build)

print_message() {
  case "$LANG" in
    de_* ) echo "$1" ;;  # Deutsch
    * )    echo "$2" ;;  # Englisch
  esac
}

# Prüft llvm-config auf kompatible Version pro Distribution
check_llvm_compatible() {
  if ! command -v llvm-config >/dev/null 2>&1; then
    print_message \
      "llvm-config nicht gefunden." \
      "llvm-config not found."
    return 1
  fi

  local full_version version distro codename
  full_version=$(llvm-config --version)
  version=${full_version%%.*}

  distro=$(lsb_release -is 2>/dev/null || echo "unknown")
  codename=$(lsb_release -cs 2>/dev/null || echo "unknown")

  # Ubuntu Noble: 14 oder 15 (<16)
  if [[ "$distro" == "Ubuntu" && "$codename" == "noble" ]]; then
    if [ "$version" != "14" ] && [ "$version" != "15" ]; then
      print_message \
        "Ubuntu Noble: Falsche LLVM-Version $full_version (erwartet 14/15)" \
        "Ubuntu Noble: Wrong LLVM $full_version (need 14/15)"
      return 1
    fi
  # Debian Trixie: 14, 15 oder 16 
  elif [[ "$distro" == "Debian" && "$codename" == "trixie" ]]; then
    if [ "$version" != "14" ] && [ "$version" != "15" ] && [ "$version" != "16" ]; then
      print_message \
        "Debian Trixie: Falsche LLVM-Version $full_version (erwartet 14/15/16)" \
        "Debian Trixie: Wrong LLVM $full_version (need 14/15/16)"
      return 1
    fi
  else
    print_message \
      "Unterstützte Systeme: Ubuntu Noble | Debian Trixie (gefunden: $distro $codename)" \
      "Supported: Ubuntu Noble | Debian Trixie (found: $distro $codename)"
    return 1
  fi

  print_message \
    "$distro $codename: LLVM $full_version ✓ (Akarin-kompatibel)" \
    "$distro $codename: LLVM $full_version ✓ (Akarin compatible)"
  return 0
}

# Installiert optimale LLVM-Version pro Distribution
install_llvm_supported() {
  local distro codename llvm_version
  distro=$(lsb_release -is 2>/dev/null || echo "unknown")
  codename=$(lsb_release -cs 2>/dev/null || echo "unknown")

  if [[ "$distro" != "Ubuntu" && "$distro" != "Debian" ]]; then
    print_message \
      "Nur Ubuntu/Debian unterstützt." \
      "Only Ubuntu/Debian supported."
    return 1
  fi

  # Ubuntu Noble → LLVM 14 (stabilste)
  if [[ "$distro" == "Ubuntu" && "$codename" == "noble" ]]; then
    llvm_version="14"
    print_message \
      "Ubuntu Noble → Installiere LLVM $llvm_version..." \
      "Ubuntu Noble → Installing LLVM $llvm_version..."
    sudo apt update && sudo apt install -y llvm-"$llvm_version" llvm-"$llvm_version"-dev

  # Debian Trixie → LLVM 14 (stabilste, auch wenn 16 verfügbar)
  elif [[ "$distro" == "Debian" && "$codename" == "trixie" ]]; then
    llvm_version="14"
    print_message \
      "Debian Trixie → Installiere LLVM $llvm_version..." \
      "Debian Trixie → Installing LLVM $llvm_version..."
    sudo apt update && sudo apt install -y llvm-"$llvm_version" llvm-"$llvm_version"-dev
  else
    print_message \
      "Nur Ubuntu Noble | Debian Trixie (gefunden: $distro $codename)" \
      "Only Ubuntu Noble | Debian Trixie (found: $distro $codename)"
    return 1
  fi
}

# llvm-config auf LLVM 14 setzen (optimale Version für beide Dists)
setup_llvm_config() {
  local llvm_version="14"
  print_message \
    "llvm-config → Version $llvm_version (Priorität 200)..." \
    "llvm-config → version $llvm_version (priority 200)..."

  # LLVM 14 mit höchster Priorität
  sudo update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-14 200 \
    || print_message "Warnung: llvm-config-14 nicht gefunden" "Warning: llvm-config-14 not found"

  # LLVM 15 (Priorität 150) - Ubuntu Noble
  sudo update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-15 150 2>/dev/null || true

  # LLVM 16 (Priorität 100) - Debian Trixie Fallback
  sudo update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-16 100 2>/dev/null || true

  # LLVM 14 als Standard setzen
  sudo update-alternatives --set llvm-config /usr/bin/llvm-config-14

  # Verifikation
  if command -v llvm-config >/dev/null 2>&1; then
    local version=$(llvm-config --version)
    print_message "llvm-config → $version ✓" "llvm-config → $version ✓"
  fi
}

# Umgebungsvariable setzen
export_llvm_config() {
  export LLVM_CONFIG=$(command -v llvm-config)
  print_message "LLVM_CONFIG='$LLVM_CONFIG' ✓" "LLVM_CONFIG='$LLVM_CONFIG' ✓"
}

# HAUPTLOGIK
main() {
  echo
  echo "=== Akarin Plugin - Outdated! LLVM Setup ==="
  echo "Repo: https://github.com/AkarinVS/vapoursynth-plugin"
  echo

  if check_llvm_compatible; then
    print_message "LLVM bereits korrekt." "LLVM already correct."
  else
    if ! install_llvm_supported; then
      print_message "Installation fehlgeschlagen." "Installation failed."
      exit 1
    fi
    setup_llvm_config
  fi

  export_llvm_config
  print_message \
    "✓ FERTIG! Starte jetzt: Klonen des Repositories und Kompilieren des Plugins/" \
    "✓ DONE! Now run: Cloning the repository and compiling the plugin/"
}

# Ausführen
main

# Beispielaufruf für mkgh
mkgh AkarinVS/vapoursynth-plugin libakarin
