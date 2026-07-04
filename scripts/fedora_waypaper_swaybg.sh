#!/bin/bash
# =============================================
# Script para instalar swaybg + waypaper no Fedora
# =============================================

echo "=== Instalando swaybg e waypaper no Fedora ==="

# Atualizar sistema
echo "→ Atualizando repositórios..."
sudo dnf update -y

# Instalar swaybg
echo "→ Instalando swaybg..."
sudo dnf install -y swaybg

# Ativar COPR e instalar waypaper
echo "→ Ativando repositório COPR para Waypaper..."
sudo dnf copr enable -y lionheartp/Hyprland

echo "→ Instalando waypaper..."
sudo dnf install -y waypaper

# Verificação final
echo "====================================="
echo "✅ Instalação concluída!"
echo ""
echo "Comandos para testar:"
echo "   swaybg -i /caminho/da/imagem.jpg -m fill"
echo "   waypaper"
echo ""
echo "Para iniciar o Waypaper automaticamente, adicione no seu arquivo de configuração:"
echo "   exec-once = waypaper --restore"