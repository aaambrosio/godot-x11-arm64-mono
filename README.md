# Godot build for Linux arm64 with Mono

This repository contains scripts for building Godot for Linux arm64 with Mono and optional lld.

## Versions

- OS: Ubuntu20 arm64
- Mono: 6.12.0.182
- Godot: 3.5-stable
- godot-mono-builds: release/mono-6.12.0.182

## Install dependencies

```bash
sudo apt-get install build-essential clang lld scons pkg-config yasm python3.8-distutils libx11-dev libxcursor-dev libxinerama-dev libgl1-mesa-dev libglu-dev libasound2-dev libpulse-dev libudev-dev libxi-dev libxrandr-dev -y
sudo apt install gnupg git autoconf automake -y
sudo snap install curl
sudo snap install cmake --classic

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb https://download.mono-project.com/repo/ubuntu stable-focal main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
sudo apt update -y
sudo apt install mono-devel -y
```

## Options
Edit build.sh:
```bash
AUTOMAKE_VERSION="1.16"
...
BUILD_NAME="aaambrosio-x11-arm64-mono-lld"
```

## Run Script
```bash
git clone https://github.com/aaambrosio/godot-x11-arm64-mono
cd godot-x11-arm64-mono
chmod +x build.sh
./build.sh
```