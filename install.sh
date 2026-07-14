#!/usr/bin/env bash
set -euo pipefail

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Please run this script as root or with sudo:"
    echo "  sudo ./install.sh"
    exit 1
fi

echo "=========================================="
# 1. Install dependencies
echo "[1/2] Installing required dependencies..."
echo "=========================================="
apt-get update
apt-get install -y \
    libwayland-client0 \
    libwayland-server0 \
    libxkbcommon0 \
    libpixman-1-0 \
    libinput10 \
    libevdev2 \
    libdrm2 \
    libjpeg8 \
    libwebp7 \
    libpng16-16 \
    libpam0g \
    libexpat1 \
    freerdp3-x11 \
    libfreerdp3-3 \
    libwinpr3-3 || true

# Also try to install dev packages as fallback/safety if any runtime dependencies are named differently on this OS version
apt-get install -y \
    libwayland-dev \
    libxkbcommon-dev \
    libpixman-1-dev \
    libinput-dev \
    libevdev-dev \
    libdrm-dev \
    libjpeg-dev \
    libwebp-dev \
    libpng-dev \
    libpam0g-dev \
    libexpat1-dev \
    freerdp3-dev || true

echo "=========================================="
# 2. Install Weston files
echo "[2/2] Copying Weston files to /usr..."
echo "=========================================="
if [ -d "staging/usr" ]; then
    cp -av staging/usr/* /usr/
    echo "=========================================="
    echo " SUCCESS: Weston has been installed to /usr"
    echo "=========================================="
else
    echo "ERROR: 'staging/usr' directory not found. Make sure you run this script from the extracted archive folder."
    exit 1
fi
