#!/usr/bin/env bash
set -o errexit
set -x

NPROC=$(grep processor /proc/cpuinfo | wc -l)

# Wireshark
sudo apt-get install build-essential -y
sudo apt-get install autoconf -y
sudo apt-get install libglib2.0-dev -y
sudo apt-get install libpcap-dev -y
sudo apt-get install libgcrypt20-dev -y
sudo apt-get install libtool -y
# See https://installfights.blogspot.com/2016/10/install-wireshark-23-on-ubuntu-1604.html
sudo ln -s /usr/bin/libtoolize /usr/bin/libtool
sudo apt-get install pkg-config -y

# Lua
# To use the default lua from yum:
#sudo yum install lua-devel -y
# To use the same with the Wireshark releases:
#LUA_VERSION=5.2.4
#sudo yum install readline-devel -y
#curl -R -O -s http://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz
#tar -xf lua-${LUA_VERSION}.tar.gz
#cd lua-${LUA_VERSION}
#make linux test MYCFLAGS='-fPIC'
#sudo make install
#cd
# To use Lua JIT:
LUA_JIT_VERSION=2.0.5
curl -R -O -s https://luajit.org/download/LuaJIT-${LUA_JIT_VERSION}.tar.gz
tar -xf LuaJIT-${LUA_JIT_VERSION}.tar.gz
cd LuaJIT-${LUA_JIT_VERSION}
make -j $NPROC
sudo make install
cd
WIRESHARK_VERSION=2.6.5
curl -R -O -s https://2.na.dl.wireshark.org/src/all-versions/wireshark-${WIRESHARK_VERSION}.tar.xz
tar -xf wireshark-${WIRESHARK_VERSION}.tar.xz
cd wireshark-${WIRESHARK_VERSION}
# Add luajit to supported lua implementations
sed -i 's/\(lua5.2\)/luajit \1/' acinclude.m4
# See "Embedding LuaJIT" in https://luajit.org/install.html
sed -i 's/lua_newstate([^;]*)/luaL_newstate()/' epan/wslua/init_wslua.c
./autogen.sh
PKG_CONFIG_PATH=/usr/local/lib/pkgconfig ./configure --disable-wireshark --disable-androiddump --disable-packet-editor --disable-sshdump --disable-ciscodump --disable-udpdump --without-plugins --without-kerberos --with-lua
make -j $NPROC
sudo make install

# Allow current user to access the network interfaces.
sudo groupadd wireshark
sudo usermod -a -G wireshark $(whoami)
sudo setcap cap_net_raw,cap_net_admin=eip $(which dumpcap)
