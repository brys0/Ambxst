#!/usr/bin/env bash
set -e

FLAKE_URI="${1:-github:Axenide/Ambxst}"

echo "🚀 Initiating Ambxst installation..."

if [ ! -f /etc/NIXOS ]; then
  if ! command -v ddcutil >/dev/null 2>&1; then
    echo "📦 Installing ddcutil..."
    if command -v pacman >/dev/null 2>&1; then
      sudo pacman -S --noconfirm ddcutil
    elif command -v apt >/dev/null 2>&1; then
      sudo apt update && sudo apt install -y ddcutil
    elif command -v dnf >/dev/null 2>&1; then
      sudo dnf install -y ddcutil
    elif command -v zypper >/dev/null 2>&1; then
      sudo zypper install -y ddcutil
    elif command -v xbps-install >/dev/null 2>&1; then
      sudo xbps-install -y ddcutil
    elif command -v apk >/dev/null 2>&1; then
      sudo apk add ddcutil
    else
      echo "❌ Your package manager is not supported. Please install ddcutil manually."
      exit 1
    fi
    echo "✅ ddcutil installed"
  else
    echo "✅ ddcutil already installed"
  fi

  if ! command -v powerprofilesctl >/dev/null 2>&1; then
    echo "📦 Installing power-profiles-daemon..."
    if command -v pacman >/dev/null 2>&1; then
      sudo pacman -S --noconfirm power-profiles-daemon
    elif command -v apt >/dev/null 2>&1; then
      sudo apt update && sudo apt install -y power-profiles-daemon
    elif command -v dnf >/dev/null 2>&1; then
      sudo dnf install -y power-profiles-daemon
    elif command -v zypper >/dev/null 2>&1; then
      sudo zypper install -y power-profiles-daemon
    elif command -v xbps-install >/dev/null 2>&1; then
      sudo xbps-install -y power-profiles-daemon
    elif command -v apk >/dev/null 2>&1; then
      sudo apk add power-profiles-daemon
    else
      echo "❌ Your package manager is not supported. Please install power-profiles-daemon manually."
      exit 1
    fi
    echo "✅ power-profiles-daemon installed"
  else
    echo "✅ power-profiles-daemon already installed"
  fi
else
  echo "🟦 NixOS detected: Skipping ddcutil and power-profiles-daemon installation"
fi

# Install Nix
if ! command -v nix >/dev/null 2>&1; then
  echo "📥 Installing Nix..."
  curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
else
  echo "✅ Nix already installed"
fi

# Config allowUnfree
echo "🔑 Enable unfree packages in Nix..."
mkdir -p ~/.config/nixpkgs

if [ ! -f ~/.config/nixpkgs/config.nix ]; then
  cat >~/.config/nixpkgs/config.nix <<'EOF'
{
  allowUnfree = true;
}
EOF
  echo "✅ ~/.config/nixpkgs/config.nix created with allowUnfree = true"
else
  echo "ℹ️ ~/.config/nixpkgs/config.nix already exists. Please ensure allowUnfree = true is set."
fi

# === Install Ambxst ===
echo "📦 Now... The moment you've been waiting for: Installing Ambxst..."
nix profile add "$FLAKE_URI" --impure

echo "✅ Ambxst installed successfully!"
echo "🎉 You can now run 'ambxst' to begin your experience."
