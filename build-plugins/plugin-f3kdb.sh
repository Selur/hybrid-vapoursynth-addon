#mkgh SAPikachu/flash3kyuu_deband libf3kdb
touch f3kfb.info
ghdl SAPikachu/flash3kyuu_deband
FILE=../f3kfb.info
if [ -f "$FILE" ]; then
   echo "$FILE exists."
   set +e
   python3 ./waf configure
   set -e
   cd ..
   cp ../patch/f3kdb-waf.patch build
   cp ../patch/f3kdb-Context.py.patch ../build/build/.waf3-2.0.10-195b3fea150563357014bcceb6844e0e/waflib/
   cp ../patch/f3kdb-ConfigSet.py.patch ../build/build/.waf3-2.0.10-195b3fea150563357014bcceb6844e0e/waflib/
   cd build
   patch -p0 < f3kdb-waf.patch
   echo "WAF patched"
   cd .waf3-2.0.10-195b3fea150563357014bcceb6844e0e/waflib/
   patch -p0 < "f3kdb-Context.py.patch"
   echo "Context.py patched"
   patch -p0 < "f3kdb-ConfigSet.py.patch"
   echo "ConfigSet.pz patched"
   cd ../../../
   rm f3kfb.info
   cd build
   python3 waf configure
else
   echo "$FILE does not exist."
fi
build libf3kdb

