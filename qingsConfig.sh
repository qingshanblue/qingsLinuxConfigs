# qingsConfig.sh

# 设置 zsshenv
echo '# ~/.zshenv
# 设置 Zsh 配置文件的目录
export ZDOTDIR="$HOME/.config/zsh"' > ~/.zshenv

# 设置深色主题
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# 设置rime配置文件软链接
mkdir -p ~/.local/share/fcitx5/rime/
rm -f ~/.local/share/fcitx5/rime/default.custom.yaml
ln -s ~/.config/rime/default.custom.yaml ~/.local/share/fcitx5/rime/default.custom.yaml
echo "Rime 配置链接已创建"