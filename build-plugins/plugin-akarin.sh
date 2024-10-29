###################################################################
#                                                                 #
#                     Plugin-Akarin v0.95                         #
#                                                                 #
#     https://github.com/AkarinVS/vapoursynth-plugin              #
###################################################################

# Funktion zur Ausgabe von Meldungen in Deutsch und Englisch
print_message() {
  case "$LANG" in
    de_* )
      echo "$1"  # Deutsch
      ;;
    * )
      echo "$2"  # Englisch
      ;;
  esac
}

# Überprüfen der LLVM-Versionen
check_llvm_version() {
  local version
  version=$(llvm-config --version)

# Vergleiche die Versionen
  if ! printf "%s\n10.0" "$version" | sort -C || printf "%s\n16" "$version" | sort -C; then
    print_message "Die installierte LLVM-Version ($version) entspricht nicht den Anforderungen." "The installed LLVM version ($version) does not meet the requirements."
    return 1
  fi

  print_message "Die installierte LLVM-Version ($version) entspricht den Anforderungen." "The installed LLVM version ($version) meets the requirements."
  return 0
}

# Installieren der höchsten zulässigen Version von LLVM
install_llvm() {
  if [[ -f /etc/debian_version ]]; then
    # Debian oder Ubuntu
    if [[ $(lsb_release -is) == "Debian" && $(lsb_release -cs) == "trixie" ]] || [[ $(lsb_release -is) == "Ubuntu" && $(lsb_release -cs) == "noble" ]]; then
      print_message "Überprüfe und installiere die zulässigen LLVM-Pakete..." "Checking and installing the allowed LLVM packages..."
      # Update der Paketliste
      sudo apt update

      # Installieren der spezifischen Version 14
      local llvm_version="14"
      print_message "Installiere LLVM Version $llvm_version..." "Installing LLVM version $llvm_version..."
      sudo apt install -y llvm-"$llvm_version" llvm-"$llvm_version"-dev 

      print_message "LLVM-Pakete wurden installiert." "LLVM packages have been installed."
    else
      print_message "Dieses Skript unterstützt nur Debian Trixie oder Ubuntu 24.04 LTS (Noble)." "This script only supports Debian Trixie or Ubuntu 24.04 LTS (Noble)."
    fi
  else
    print_message "Dieses Skript kann nur auf Debian-basierten Systemen ausgeführt werden." "This script can only be run on Debian-based systems."
  fi
}

# Setzen von llvm-config auf Version 14
set_llvm_config_version() {
  print_message "Setze llvm-config auf Version 14..." "Setting llvm-config to version 14..."

  # Füge die llvm-config Versionen zu update-alternatives hinzu
  sudo update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-14 100

  # Setze die Standardversion auf 14
  sudo update-alternatives --set llvm-config /usr/bin/llvm-config-14

  print_message "Die llvm-config-Version wurde auf 14 gesetzt." "The llvm-config version has been set to 14."
}

# Setzen der LLVM_CONFIG-Variable
set_llvm_config_variable() {
  export LLVM_CONFIG=$(which llvm-config)
  print_message "Die LLVM_CONFIG-Variable wurde auf $LLVM_CONFIG gesetzt." "The LLVM_CONFIG variable has been set to $LLVM_CONFIG."
}

# Hauptlogik
if check_llvm_version; then
  print_message "Die erforderlichen LLVM-Pakete sind bereits installiert." "The required LLVM packages are already installed."
else
  install_llvm
fi

# Setzen von llvm-config auf Version 14
set_llvm_config_version

# Setzen der LLVM_CONFIG-Variable
set_llvm_config_variable

# Beispielaufruf für mkgh
mkgh AkarinVS/vapoursynth-plugin libakarin
