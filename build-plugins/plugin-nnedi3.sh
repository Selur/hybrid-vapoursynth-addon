##################################################################################
#                                                                                #
#                                   Plugin-vs-nnedi3 V12                         #
#                                                                                #
#                                                                                #
#                  https://github.com/dubhater/vapoursynth-nnedi3                #
##################################################################################

install_nnedi3_weights() {
  local p="$VSPREFIX/vsplugins"
  local f="$p/nnedi3_weights.bin"
  local sum="27f382430435bb7613deb1c52f3c79c300c9869812cfe29079432a9c82251d42"

  if [ ! -f "$f" ] || [ "$(sha256sum -b "$f" | head -c64)" != "$sum" ]; then
    mkdir -p "$p"
    rm -f "$f"
    wget -O "$f" https://github.com/dubhater/vapoursynth-nnedi3/raw/master/src/nnedi3_weights.bin || handle_error "Fehler beim Herunterladen des nnedi3-deinterlacer." "Error downloading nnedi3-deinterlacer."
  fi
}

mkgh dubhater/vapoursynth-nnedi3 libnnedi3
install_nnedi3_weights
