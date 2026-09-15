set -euo pipefail
echo "=== qingsConfig.sh ==="

# 基础设置
xdg-user-dirs-update --force
echo 'export ZDOTDIR="$HOME/.config/zsh"' > ~/.zshenv
rm ~/.zcompdump
rm ~/.zshenv
rm ~/.zsh_history
rm ~/.zshrc
rm ~/.zprofile
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
echo "已设置深色主题"

# 设置npm的默认包路径，使得npm在NixOs下可以正常安装包
mkdir -p ~/.npm
npm config set prefix ~/.npm

# 链接 ~/.config/rime/ → ~/.local/share/fcitx5/rime/
#    这样 rime 直接读取配置目录（包括 default.yaml）
mkdir -p ~/.local/share/fcitx5/rime/
rm -rf ~/.local/share/fcitx5/rime/*
ln -s ~/.config/rime/default.custom.yaml ~/.local/share/fcitx5/rime/default.custom.yaml
ln -s ~/.config/rime/default.yaml ~/.local/share/fcitx5/rime/default.yaml 2>/dev/null || true

echo "=== done ==="
