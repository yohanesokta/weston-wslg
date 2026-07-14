#!/usr/bin/env bash
set -euo pipefail

########################################
# Weston RDP Builder
# Ubuntu/Debian
########################################

VERSION="14.0.0"
OUTPUT="weston-rdp-${VERSION}.tar.gz"

########################################
# Dependency
########################################

echo "[1/5] Installing dependencies..."

sudo apt-get update

# Core build dependencies
sudo apt-get install -y \
    build-essential \
    meson \
    ninja-build \
    pkg-config \
    cmake \
    git \
    tar \
    gzip \
    libwayland-dev \
    wayland-protocols \
    libxkbcommon-dev \
    libpixman-1-dev \
    libegl-dev \
    libgles-dev \
    libinput-dev \
    libevdev-dev \
    libdrm-dev \
    libgbm-dev \
    libjpeg-dev \
    libwebp-dev \
    libpng-dev \
    libpam0g-dev \
    libexpat1-dev \
    python3 || true

# Try installing freerdp3-dev, if not available fallback to freerdp2-dev
if apt-cache show freerdp3-dev >/dev/null 2>&1; then
    echo "Installing freerdp3-dev..."
    sudo apt-get install -y freerdp3-dev || true
else
    echo "freerdp3-dev not found, falling back to freerdp2-dev..."
    sudo apt-get install -y freerdp2-dev || true
fi

# Additional RDP codec libraries
sudo apt-get install -y \
    libswscale-dev \
    libavcodec-dev \
    libavutil-dev \
    libswresample-dev \
    liburiparser-dev \
    libjson-c-dev \
    libssl-dev \
    libzstd-dev \
    libdav1d-dev \
    librsvg2-dev \
    libcairo2-dev \
    libopus-dev \
    libspeex-dev \
    libx264-dev \
    libx265-dev \
    libva-dev \
    libvdpau-dev \
    libxml2-dev \
    libharfbuzz-dev || true



########################################
# Check source
########################################

if [ ! -f meson.build ]; then
    echo "ERROR: Jalankan script ini dari folder source Weston"
    exit 1
fi


########################################
# Clean
########################################

echo "[2/5] Cleaning build..."

rm -rf build
rm -rf staging
rm -f "$OUTPUT"


########################################
# Configure
########################################

echo "[3/5] Configuring Weston..."

meson setup build \
    --prefix=/usr \
    --buildtype=release \
    --strip \
    \
    -Dbackend-default=rdp \
    \
    -Dbackend-rdp=true \
    -Dbackend-vnc=false \
    -Dbackend-drm=false \
    -Dbackend-headless=false \
    -Dbackend-wayland=false \
    -Dbackend-x11=false \
    -Dbackend-pipewire=false \
    \
    -Drenderer-gl=true \
    \
    -Dxwayland=false \
    \
    -Dshell-desktop=true \
    -Dshell-ivi=false \
    -Dshell-kiosk=false \
    \
    -Dpipewire=false \
    -Dremoting=false \
    \
    -Dsystemd=false \
    \
    -Dtests=false \
    -Ddoc=false \
    \
    -Ddemo-clients=false \
    -Dsimple-clients=[] \
    -Dtools=[] \
    -Dcolor-management-lcms=false

########################################
# Build
########################################

echo "[4/5] Building..."

meson compile \
    -C build \
    -j"$(nproc)"


########################################
# Archive
########################################

echo "[5/5] Creating archive..."

mkdir -p staging

cp -a build staging/


echo "[+] Install staging"

rm -rf staging
mkdir staging

DESTDIR="$(pwd)/staging" meson install -C build


echo "[+] Remove unused"

rm -f staging/usr/lib/*/libweston-14/vnc-backend.so || true
rm -f staging/usr/lib/*/weston/screen-share.so || true


echo "[+] Create archive"

tar -czf weston-rdp-14.0.0.tar.gz staging install.sh

echo "[+] Creating Debian package (.deb)..."

rm -rf debian/octaweston/usr
cp -a staging/usr debian/octaweston/usr
dpkg-deb --build debian/octaweston
mv debian/octaweston.deb ./octaweston_14.0.0-1_amd64.deb

echo
echo "=================================="
echo " DONE"
echo "=================================="
echo
echo "Tarball Archive:"
echo "  weston-rdp-14.0.0.tar.gz"
echo
echo "Debian Package (.deb):"
echo "  octaweston_14.0.0-1_amd64.deb"
echo
echo "Build Directory:"
echo "  build/"
