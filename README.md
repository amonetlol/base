# base

Instalador modular para ambientes **Hyprland** — dotfiles, temas, rice e scripts auxiliares para **Arch**, **Fedora** e **Ubuntu**.

## Estrutura

```
base/
├── install_all.sh          # Menu interativo dos módulos
├── modules/                # Módulos standalone (.sh)
├── scripts/                # Scripts por distro (Fedora, etc.)
├── vendor/                 # Overrides locais (bash, hypr, rofi)
├── Assets/                 # Temas, ícones, fontes (via vendor-assets.sh)
└── wallpapers/             # Wallpapers locais → ~/Imagens/wallpapers
```

## Uso rápido

```bash
git clone git@github.com:amonetlol/base.git
cd base
bash install_all.sh
```

No menu: escolha `1`, `1,3,5`, `1-5` ou `all`. Use `0` para sair.

## Módulos

| # | Módulo | Descrição |
|---|--------|-----------|
| 1 | VMware | open-vm-tools (Arch/Fedora/Ubuntu, só em VM) |
| 2 | Neovim | Clone amonetlol/nvim |
| 3 | Hypr + temas | Repo custom + hypr + rofi wallpaper |
| 4 | Fontes | pacman (Arch) ou dot → ~/.fonts |
| 5 | Chaotic-AUR | Só Arch |
| 6 | SDDM Theme | Só Arch |
| 7 | Hide Shortcuts | Oculta atalhos no rofi |
| 8 | Kitty | Dotfiles kitty |
| 9 | Alacritty | Dotfiles alacritty |
| 10 | Btop | Temas btop |
| 11 | Fastfetch | Config fastfetch |
| 12 | Starship | Binário + configs |
| 13 | Bin | Scripts ~/.bin |
| 14 | Bash | .bashrc, aliases, .bin |
| 15 | Rice | GTK, ícones, cursor (Arch/Fedora/Ubuntu) |
| 16 | Wallpapers | → ~/Imagens/wallpapers |

## Scripts Fedora

```bash
bash scripts/fedora_hyprland.sh      # Hyprland + pacotes base
bash scripts/fedora_gnome.sh         # Setup GNOME
bash scripts/fedora_waypaper_swaybg.sh  # swaybg + waypaper
bash scripts/test-distro.sh          # Testa detecção de distro
```

## Assets (temas GTK, ícones, cursor)

```bash
bash Assets/vendor-assets.sh         # Baixa zips para Assets/
bash Assets/vendor-assets.sh --fonts # Inclui fontes dot
bash modules/install-rice.sh         # Extrai para ~/.themes e ~/.icons
```

## Starship (.bashrc)

O módulo **Bash** instala `vendor/bash/.bashrc` com 3 temas — **nord** ativo por padrão:

```bash
# export STARSHIP_CONFIG="$HOME/.config/starship.toml"
# export STARSHIP_CONFIG="$HOME/.config/starship-tokyo-night.toml"
export STARSHIP_CONFIG="$HOME/.config/starship-nord.toml"
```

## Hyprland

- `vendor/hypr/scripts/gtkthemes` — aplica GTK, ícones, cursor e fonte
- `exec-once = ~/.config/hypr/scripts/gtkthemes` no hyprland.conf
- Rofi wallpaper suporta **awww**, **swww** e **swaybg**

## Bases suportadas

| Base | Detecção | Rice | Chaotic/SDDM |
|------|----------|------|--------------|
| Arch / CachyOS | `is_arch_based` | Sim | Sim |
| Fedora | `is_fedora_based` | Sim | Ignora |
| Ubuntu / Debian | `is_ubuntu_based` | Sim | Ignora |

## Repositórios externos

- [amonetlol/dot](https://github.com/amonetlol/dot) — dotfiles
- [amonetlol/custom](https://github.com/amonetlol/custom) — Hypr + temas
- [amonetlol/nvim](https://github.com/amonetlol/nvim) — Neovim
- [amonetlol/wall2](https://github.com/amonetlol/wall2) — wallpapers (fallback)

## Licença

Uso pessoal — configs e scripts do projeto [amonetlol](https://github.com/amonetlol).
