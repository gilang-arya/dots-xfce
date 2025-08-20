#!/usr/bin/env bash
set -euo pipefail

DOTFILES_REPO="$HOME/.dotfiles/dots-xfce"
PKG_FILE="$DOTFILES_REPO/packages.txt"

echo "==> Installing required packages..."

if [[ -f "$PKG_FILE" ]]; then
    echo -e "\n📦 Installing packages from 'packages.txt'..."
    while IFS= read -r pkg; do
        [[ -z "$pkg" || "$pkg" == \#* ]] && continue
        if ! pacman -Q "$pkg" &>/dev/null; then
            echo "  ➜ Installing $pkg..."
            sudo pacman -S --needed --noconfirm "$pkg"
        else
            echo "  ✓ $pkg already installed"
        fi
    done < "$PKG_FILE"
else
    echo "⚠️  No 'packages.txt' found, skipped."
fi

# cek apakah stow terinstall
if ! command -v stow >/dev/null 2>&1; then
    echo "==> stow not found, installing..."
    sudo pacman -S --needed --noconfirm stow
fi

echo "==> Creating symlinks with stow..."
cd "$HOME/.dotfiles"
stow --target="$HOME" dots-xfce

# aktifkan lightdm jika ada
if pacman -Q lightdm &>/dev/null; then
    echo "==> Enabling LightDM..."
    sudo systemctl enable lightdm.service
else
    echo "⚠️  LightDM not installed, skipping enable step."
fi

echo "==> Done! 🎉"
