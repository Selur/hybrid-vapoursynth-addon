# -----------------------------------------------------------------------------------------
# Scriptname: plugin-rife.sh https://github.com/styler00dollar/VapourSynth-RIFE-ncnn-Vulkan
# Datum: $(date "+%Y-%m-%d")          # Date: $(date "+%Y-%m-%d")
# Uhrzeit: $(date "+%H:%M:%S")        # Time: $(date "+%H:%M:%S")
# Beschreibung: Dieses Skript installiert das "plugin-rife" und überprüft, ob
#               die  erforderlichen Versionen von GCC und G++ installiert
#               sind und setzt die entsprechenden Umgebungsvariablen.
#
# Description:  This script installs the "plugin-rife" and checks if the required
#               versions of GCC and G++ are installed and sets the corresponding
#               environment variables.
# ------------------------------------------------------------------------------------------

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

# Überprüfen, welche Versionen von gcc und g++ installiert sind
if command -v gcc &> /dev/null; then
    GCC_VERSION=$(gcc --version | grep -oP '\d+\.\d+' | head -n 1)
    if (( $(echo "$GCC_VERSION >= 11" | bc -l) )); then
        export CC=$(command -v gcc)
    else
        print_message "GCC-Version ist kleiner als 11: $GCC_VERSION" "GCC version is less than 11: $GCC_VERSION"
        return 1
    fi
else
    print_message "Kein geeigneter GCC-Compiler gefunden." "No suitable GCC compiler found."
    return 1
fi

if command -v g++ &> /dev/null; then
    GPP_VERSION=$(g++ --version | grep -oP '\d+\.\d+' | head -n 1)
    if (( $(echo "$GPP_VERSION >= 11" | bc -l) )); then
        export CXX=$(command -v g++)
    else
        print_message "G++-Version ist kleiner als 11: $GPP_VERSION" "G++ version is less than 11: $GPP_VERSION"
        return 1
    fi
else
    print_message "Kein geeigneter G++-Compiler gefunden." "No suitable G++ compiler found."
    return 1
fi

# Ausgabe der gesetzten Compiler-Variablen durch print_message
print_message "CC gesetzt auf: $CC" "CC set to: $CC"
print_message "CXX gesetzt auf: $CXX" "CXX set to: $CXX"

# Download von VapourSynth-RIFE-ncnn-Vulkan
mkgh styler00dollar/VapourSynth-RIFE-ncnn-Vulkan librife

