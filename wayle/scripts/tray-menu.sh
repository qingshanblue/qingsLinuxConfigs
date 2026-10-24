#!/bin/sh
# 托盘"收纳菜单":点击按钮 → walker dmenu 列出托盘项 → 选中后激活该项
# 注意:wayle systray list 只输出显示名,activate 需要 ID。映射关系需在实机上核实(见 TRAY_ID_MAP)。
# 用法: tray-menu.sh          (弹出菜单)
#       tray-menu.sh --parse  (仅解析列表,不激活,用于测试)

names=$(wayle systray list 2>/dev/null | sed -n 's/^  //p' | sed 's/ \[Active\]$//; s/ \[.*\]$//')

if [ "$1" = "--parse" ]; then
  printf '%s\n' "$names"
  exit 0
fi

[ -n "$names" ] || exit 0
choice=$(printf '%s\n' "$names" | walker -d -p "托盘" -w 360 -h 320 2>/dev/null)
[ -n "$choice" ] || exit 0

# TODO(实机核实后填写):显示名 -> activate ID 的映射
# 当前仅占位:未核实前不调用 activate,避免误触发应用窗口
echo "selected: $choice"
