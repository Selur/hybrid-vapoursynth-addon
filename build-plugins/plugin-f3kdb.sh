##################################################################################
#                                                                                #
#                                Plugin-f3kdb V2.0.0-1                           #
#                                                                                #
#                                                                                #
#                       https://github.com/SAPikachu/flash3kyuu_deband           #
##################################################################################

touch f3kfb.info
ghdl SAPikachu/flash3kyuu_deband

FILE=../f3kfb.info
if [ -f "$FILE" ]; then
   echo "$FILE exists."
   set +e
   python3 ./waf configure
   set -e
   cd ..
   cp ../patch/f3kdb-ConfigSet.py.patch ../build/build/.waf3-2.0.10-195b3fea150563357014bcceb6844e0e/waflib/
   cp ../patch/f3kdb-Context.py.patch ../build/build/.waf3-2.0.10-195b3fea150563357014bcceb6844e0e/waflib/
   cd build
   cd .waf3-2.0.10-195b3fea150563357014bcceb6844e0e/waflib
   patch -p0 < f3kdb-Context.py.patch
   echo "f3kdb-Context.py patched"
   patch -p0 < f3kdb-ConfigSet.py.patch
   echo "f3kdb-ConfigSet.py patched"
   cd ../../../
   rm f3kfb.info
   cd build
   python3 ./waf configure
else
   echo "$FILE does not exist."
fi

build libf3kdb
