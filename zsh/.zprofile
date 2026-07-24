# qings .zprofile
# 环境变量
export PATH="$HOME/.local/bin:$PATH"

# 系统代理
proxy_host="127.0.0.1:20122"
export http_proxy="http://$proxy_host"
export https_proxy="http://$proxy_host"
export all_proxy="socks5://$proxy_host"
export no_proxy="localhost,127.0.0.1,::1"
