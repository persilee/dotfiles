#!/bin/bash
# pigma + cava Kitty 上下分屏一键启动（kitty 0.49+）
# 前提：kitty 已运行且 allow_remote_control 生效
# 用法：~/bin/pigma-cava-kitty.sh
# 说明：kitty 0.49 远程控制子命令已改名（ls 代替 ls-windows，launch 代替 new-split）；
#       macOS 上 kitty 默认 socket 为 /tmp/mykitty

KITTY_TO="--to unix:/tmp/mykitty"

# 0. 检测 kitty 远程控制是否可用
if ! kitty @ $KITTY_TO ls >/dev/null 2>&1; then
    echo "错误：kitty 远程控制不可用（连不上 unix:/tmp/mykitty）"
    echo "请确认 ~/.config/kitty/kitty.conf 中有 allow_remote_control yes 并重启 kitty"
    exit 1
fi

# 1. 上下分屏（hsplit），下方新窗格跑 cava（--hold 防止 cava 退出后窗口关闭）
kitty @ $KITTY_TO launch --location=hsplit --hold cava

# 2. 把下方窗格高度压到最小（launch 后焦点在新窗格，resize 作用于它）
for _ in $(seq 1 60); do
    kitty @ $KITTY_TO resize-window --axis=vertical --increment=-1 >/dev/null 2>&1 || break
done

# 3. 当前（上方）窗格跑 pigma
pigma
