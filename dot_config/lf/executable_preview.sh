#!/bin/sh
# =========================================================
# ~/.config/lf/preview.sh —— lf 文件预览器
# lf 调用约定：$1=文件路径 $2=窗口宽 $3=窗口高 $4=位置
# 输出到 stdout，lf 会显示在右侧预览窗
# =========================================================

file="$1"
[ -z "$file" ] && exit 1

# 定位 bat：优先 PATH，兜底 brew 固定路径（兼容非登录 shell 环境）
if command -v bat >/dev/null 2>&1; then
    BAT_CMD="bat"
elif [ -x /opt/homebrew/bin/bat ]; then
    BAT_CMD="/opt/homebrew/bin/bat"
else
    echo "预览需要 bat，请先执行: brew install bat"
    exit 0
fi

# 根据 MIME 类型分发：
# - 文本/代码类：用 bat 渲染（语法高亮 + 行号，最多 500 行，避免大文件卡顿）
# - 其他类型：显示文件类型摘要
case "$(file -b --mime-type "$file")" in
    text/*|application/json|application/xml)
        "$BAT_CMD" --color=always --style=plain,numbers --line-range=:500 "$file"
        ;;
    *)
        echo "非文本文件: $(file -b "$file")"
        ;;
esac
