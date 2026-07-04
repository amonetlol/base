#!/bin/bash
# Script corrigido - Fedora 44 + Hyprland

echo "=== Adicionando repositórios necessários ==="

# Repositório COPR para Hyprland
sudo dnf copr enable -y ashbuk/Hyprland-Fedora

# Repositórios extras úteis
sudo dnf install -y fedora-release-nonfree

echo "=== Atualizando sistema ==="
sudo dnf update -y

echo "=== Instalando pacotes ==="

sudo dnf install -y --skip-unavailable \
    hyprland \
    hyprlock \
    hypridle \
    hyprsunset \
    waybar \
    wlogout \
    rofi \
    cliphist \
    wl-clipboard \
    polkit-gnome \
    pipewire pipewire-pulse wireplumber \
    playerctl \
    brightnessctl \
    mako \
    foot \
    neovim \
    nodejs npm \
    lua lua-devel \
    luarocks \
    python3 python3-pip python3-pynvim \
    python3-pipenv python3-virtualenv \
    tmux \
    tree-sitter-cli \
    starship \
    zoxide \
    eza \
    fd-find \
    ripgrep \
    fzf \
    duf \
    fastfetch \
    btop \
    htop \
    tree \
    tldr \
    lazygit \
    bat \
    bash-completion \
    procs \
    git \
    swaybg \
    hyprland-guiutils

echo "========================================"
echo "✅ Instalação finalizada!"
echo "→ Reinicie o computador agora."
echo "========================================"