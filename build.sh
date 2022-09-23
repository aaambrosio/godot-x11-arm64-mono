#!/bin/sh

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
AUTOMAKE_VERSION="1.16"
BUILD_NAME="aaambrosio-x11-arm64-mono-lld"

curl -LO https://curl.haxx.se/ca/cacert.pem
cert-sync --user cacert.pem

rm -rf mono
rm -rf mono-installs
rm -rf mono-config
rm -rf godot

wget https://download.mono-project.com/sources/mono/mono-6.12.0.182.tar.xz
tar xvJf mono-6.12.0.182.tar.xz
mv mono-6.12.0.182 mono

sed -i -e "s/am__api_version='1.15'/am__api_version='$AUTOMAKE_VERSION'/g" $SCRIPT_DIR/mono/configure

git clone https://github.com/godotengine/godot-mono-builds -b release/mono-6.12.0.182
cp files/desktop.py godot-mono-builds/desktop.py
cp files/patch_mono.py godot-mono-builds/patch_mono.py
cp files/bcl-profile-platform-override.diff godot-mono-builds/files/patches/bcl-profile-platform-override.diff
cp files/btls-cmake-args-linux-mingw.diff godot-mono-builds/files/patches/btls-cmake-args-linux-mingw.diff
cp files/fix-mono-android-tkill.diff godot-mono-builds/files/patches/fix-mono-android-tkill.diff
cp files/fix-mono-log-spam.diff godot-mono-builds/files/patches/fix-mono-log-spam.diff
cp files/mono_ios_asl_log_deprecated.diff godot-mono-builds/files/patches/mono_ios_asl_log_deprecated.diff
cp files/mono-dbg-agent-clear-tls-instead-of-abort.diff godot-mono-builds/files/patches/mono-dbg-agent-clear-tls-instead-of-abort.diff
cp files/wasm_m2n_trampolines_hook.diff godot-mono-builds/files/patches/wasm_m2n_trampolines_hook.diff

python3 godot-mono-builds/patch_mono.py --mono-sources=$SCRIPT_DIR/mono

mkdir mono-installs
mkdir mono-config

./godot-mono-builds/linux.py configure --target=arm64 --mono-sources=$SCRIPT_DIR/mono --configure-dir=$SCRIPT_DIR/mono-config --install-dir=$SCRIPT_DIR/mono-installs
./godot-mono-builds/linux.py make --target=arm64 --mono-sources=$SCRIPT_DIR/mono --configure-dir=$SCRIPT_DIR/mono-config --install-dir=$SCRIPT_DIR/mono-installs
./godot-mono-builds/bcl.py make --product=desktop --mono-sources=$SCRIPT_DIR/mono --configure-dir=$SCRIPT_DIR/mono-config --install-dir=$SCRIPT_DIR/mono-installs
./godot-mono-builds/linux.py copy-bcl --target=arm64 --mono-sources=$SCRIPT_DIR/mono --configure-dir=$SCRIPT_DIR/mono-config --install-dir=$SCRIPT_DIR/mono-installs

git clone https://github.com/godotengine/godot.git -b 3.5-stable

cd godot

sed -i -e "s/custom_build/$BUILD_NAME/g" $SCRIPT_DIR/godot/methods.py

scons platform=x11 arch=arm64 use_llvm=yes linker=lld mono_prefix=$SCRIPT_DIR/mono-installs/desktop-linux-arm64-release mono_static=yes tools=yes module_mono_enabled=yes mono_glue=no

bin/godot.x11.tools.arm64.llvm.mono --generate-mono-glue modules/mono/glue

scons platform=x11 arch=arm64 use_llvm=yes linker=lld mono_prefix=$SCRIPT_DIR/mono-installs/desktop-linux-arm64-release mono_static=yes module_mono_enabled=yes target=release_debug
strip bin/godot.x11.opt.tools.arm64.llvm.mono

cd ..

mkdir godot-arm64-mono-lld
cp $SCRIPT_DIR/godot/bin/godot.x11.opt.tools.arm64.llvm.mono $SCRIPT_DIR/godot-arm64-mono-lld/godot.x11.opt.tools.arm64.llvm.mono
cp -r $SCRIPT_DIR/godot/bin/GodotSharp $SCRIPT_DIR/godot-arm64-mono-lld/GodotSharp
chmod +x $SCRIPT_DIR/godot-arm64-mono-lld/godot.x11.opt.tools.arm64.llvm.mono

rm -rf godot-mono-builds
rm -rf mono
rm -rf mono-installs
rm -rf mono-config
rm -rf godot
rm mono-6.12.0.182.tar.xz