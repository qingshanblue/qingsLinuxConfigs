# qingsConfig.sh
# 设置 zsshenv
echo '# ~/.zshenv
# 设置 Zsh 配置文件的目录
export ZDOTDIR="$HOME/.config/zsh"' > ~/.zshenv
# 设置深色主题
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'