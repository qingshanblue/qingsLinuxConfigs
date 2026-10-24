#!/bin/sh
# 魔法棒:呼出/隐藏特殊工作区(与 waybar custom/scratchpad 同一逻辑,多屏感知)
# 用法: scratchpad.sh toggle | next | prev
# 状态: /dev/shm/hypr-last-special (tmpfs,纯内存,不落盘)

mons=$(hyprctl -j monitors)

case "$1" in
  toggle)
    n=$(cat /dev/shm/hypr-last-special 2>/dev/null); [ -n "$n" ] || n=magic
    holder=$(echo "$mons" | yq -r '.[]|select(.specialWorkspace.name=="special:'"$n"'")|.name')
    cur=$(echo "$mons" | yq -r '.[]|select(.focused)|.name')
    if [ -n "$holder" ] && [ "$holder" = "$cur" ]; then
      hyprctl dispatch 'hl.dsp.workspace.toggle_special("'"$n"'")'
    elif [ -n "$holder" ]; then
      hyprctl dispatch 'hl.dsp.focus({monitor="'"$holder"'"})'
    else
      hyprctl dispatch 'hl.dsp.workspace.toggle_special("'"$n"'")'
    fi
    ;;
  next|prev)
    c=$(echo "$mons" | yq -r '[.[]|select(.focused)][0].specialWorkspace.name')
    if [ "$1" = next ]; then
      case "$c" in special:magic) n=mofa;; special:mofa) n=maho;; special:maho) n=magic;; *) n=magic;; esac
    else
      case "$c" in special:magic) n=maho;; special:maho) n=mofa;; special:mofa) n=magic;; *) n=magic;; esac
    fi
    holder=$(echo "$mons" | yq -r '.[]|select(.specialWorkspace.name=="special:'"$n"'")|.name')
    if [ -n "$holder" ]; then
      hyprctl dispatch 'hl.dsp.focus({monitor="'"$holder"'"})'
    else
      hyprctl dispatch 'hl.dsp.workspace.toggle_special("'"$n"'")'
    fi
    ;;
esac
