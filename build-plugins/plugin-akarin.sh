
#############################################################################
##     vsakarin Plugin (Jaded-Encoding-Thaumaturgy fork) "1.1.0"           ##
## https://github.com/Jaded-Encoding-Thaumaturgy/akarin-vapoursynth-plugin ##
##                    LLVM 19-21 | Bevorzugt: 20                           ##
#############################################################################

# vsakarin unterstützt LLVM 19-21. LLVM 20 bevorzugt (Zig-kompatibel)
# vsakarin supports LLVM 19-21. LLVM 20 preferred (Zig compatible)

print_message() {
  case "$LANG" in
    de_* ) echo "$1" ;;  # Deutsch
    * )    echo "$2" ;;  # Englisch
  esac
}

# Prüft llvm-config auf vsakarin-kompatible Version (19-21)
check_llvm_vsakarin() {
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

  # vsakarin LLVM-Anforderung: 19, 20 oder 21
  if [ "$version" != "19" ] && [ "$version" != "20" ] && [ "$version" != "21" ]; then
    print_message \
      "vsakarin erfordert LLVM 19/20/21. Gefunden: $full_version" \
      "vsakarin requires LLVM 19/20/21. Found: $full_version"
    return 1
  fi

  print_message \
    "✓ LLVM $full_version (vsakarin-kompatibel 19-21)" \
    "✓ LLVM $full_version (vsakarin compatible 19-21)"
  return 0
}

# Installiert LLVM 20 (Zig-kompatibel) oder Fallback 19/21
install_llvm_vsakarin() {
  local distro codename llvm_version
  distro=$(lsb_release -is 2>/dev/null || echo "unknown")
  codename=$(lsb_release -cs 2>/dev/null || echo "unknown")

  if [[ "$distro" != "Ubuntu" && "$distro" != "Debian" ]]; then
    print_message \
      "Nur Ubuntu/Debian unterstützt." \
      "Only Ubuntu/Debian supported."
    return 1
  fi

  # Bevorzugt LLVM 20 (Zig-kompatibel)
  llvm_version="20"
  print_message \
    "Installiere LLVM $llvm_version (Zig-kompatibel für vsakarin)..." \
    "Installing LLVM $llvm_version (Zig-compatible for vsakarin)..."

  sudo apt update
  if sudo apt install -y llvm-"$llvm_version" llvm-"$llvm_version"-dev; then
    print_message "✓ LLVM $llvm_version erfolgreich installiert." "✓ LLVM $llvm_version installed."
  else
    print_message \
      "LLVM $llvm_version nicht verfügbar. Versuche Fallbacks..." \
      "LLVM $llvm_version unavailable. Trying fallbacks..."
    
    # Fallback: 21 → 19
    for fallback in 21 19; do
      if sudo apt install -y llvm-"$fallback" llvm-"$fallback"-dev; then
        llvm_version="$fallback"
        print_message "✓ LLVM $llvm_version (Fallback) installiert." "✓ LLVM $fallback (fallback) installed."
        break
      fi
    done
    
    if [ "$llvm_version" = "20" ]; then  # Kein Fallback erfolgreich
      print_message "❌ Keine vsakarin-kompatible LLVM-Version verfügbar!" "❌ No vsakarin-compatible LLVM available!"
      return 1
    fi
  fi
}

# llvm-config auf LLVM 20 setzen (höchste Priorität)
setup_llvm_config_vsakarin() {
  local llvm_version="20"
  print_message \
    "llvm-config → LLVM $llvm_version (Priorität 300)..." \
    "llvm-config → LLVM $llvm_version (priority 300)..."

  # LLVM 20 mit höchster Priorität (300)
  sudo update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-20 300 \
    || print_message "Warnung: llvm-config-20 nicht gefunden" "Warning: llvm-config-20 not found"

  # LLVM 21 (Priorität 200)
  sudo update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-21 200 2>/dev/null || true

  # LLVM 19 (Priorität 100)
  sudo update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-19 100 2>/dev/null || true

  # Explizit LLVM 20 als Standard
  sudo update-alternatives --set llvm-config /usr/bin/llvm-config-20

  # Verifikation
  if command -v llvm-config >/dev/null 2>&1; then
    local version=$(llvm-config --version)
    if [[ "$version" == 20* ]]; then
      print_message "✓ llvm-config → LLVM $version (Zig-kompatibel)" "✓ llvm-config → LLVM $version (Zig-compatible)"
    else
      print_message \
        "⚠️  llvm-config zeigt $version statt 20. Exportiere manuell:" \
        "⚠️  llvm-config shows $version not 20. Export manually:"
      print_message "export LLVM_CONFIG=/usr/bin/llvm-config-20" "export LLVM_CONFIG=/usr/bin/llvm-config-20"
    fi
  fi
}

# Umgebungsvariable setzen
export_llvm_config() {
  if [ -f /usr/bin/llvm-config-20 ]; then
    export LLVM_CONFIG=/usr/bin/llvm-config-20
  else
    export LLVM_CONFIG=$(command -v llvm-config)
  fi
  print_message "LLVM_CONFIG='$LLVM_CONFIG' ✓" "LLVM_CONFIG='$LLVM_CONFIG' ✓"
}

# HAUPTLOGIK für vsakarin
main() {
  echo
  echo "=== vsakarin Plugin LLVM Setup (Jaded-Encoding-Thaumaturgy fork) ==="
  echo "Repo: https://github.com/Jaded-Encoding-Thaumaturgy/akarin-vapoursynth-plugin"
  echo

  if check_llvm_vsakarin; then
    print_message "LLVM bereits vsakarin-kompatibel." "LLVM already vsakarin-compatible."
  else
    if ! install_llvm_vsakarin; then
      print_message "❌ LLVM-Installation fehlgeschlagen." "❌ LLVM installation failed."
      exit 1
    fi
    setup_llvm_config_vsakarin
  fi

  export_llvm_config

  print_message \
    "✓ FERTIG! Starte jetzt: Klonen des Repositories und Kompilieren des Plugins/" \
    "✓ DONE! Now run: Cloning the repository and compiling the plugin/"
}

# Ausführen
main

# Beispielaufruf für mkgh
mkgh Jaded-Encoding-Thaumaturgy/akarin-vapoursynth-plugin libakarin
