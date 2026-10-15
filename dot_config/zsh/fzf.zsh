# =========================================================
# ~/.config/zsh/fzf.zsh —— fzf 模糊查找配置
# =========================================================

# 默认搜索命令：用 fd（含隐藏文件；strip-cwd-prefix 去掉结果中的 ./ 前缀）
export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix'  # strip-cwd-prefix 去掉 ./ 前缀

# Ctrl-T 触发时使用同样的搜索命令
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# ---------- 界面样式（--height 高度 / --layout 布局 / --border 边框 /
#            --prompt 提示符 / --pointer 指针 / --preview-window 预览窗） ----------
# ---------- Dracula 配色（与 kitty 终端  ） ----------
export FZF_DEFAULT_OPTS='
  --height=60%
  --layout=reverse
  --border=rounded
  --prompt=" "
  --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 
  --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 
  --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 
  --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4
'


# 预览命令：用 bat 高亮文件内容（纯文本+行号，最多 500 行）
export _FZF_PREVIEW_CMD='bat --color=always --style=plain,numbers --line-range=:500 {}'
export FZF_CTRL_T_OPTS="--preview '$_FZF_PREVIEW_CMD'"

# ---------- 自定义：Ctrl+F 文件选择（排除隐藏文件） ----------
_fzf_file_no_hidden() {
  local cmd result
  cmd="${FZF_DEFAULT_COMMAND/--hidden /}"
  result=$(eval "${cmd:-find . -type f}" | fzf --preview "$_FZF_PREVIEW_CMD") \
    && LBUFFER+="$result"  # LBUFFER 是光标左侧的文本
  zle reset-prompt
}
zle -N _fzf_file_no_hidden

# ---------- rg + fzf：按关键字搜索文件并打开（rgf） ----------
# 用法：
#   rgf              # 列出当前目录下所有包含 "import" 的文件，fzf 模糊选择
#   rgf python       # 搜索包含 "python" 的文件（关键字可任意替换）
#   rgf 'TODO|FIXME' # 也支持 rg 的正则语法
# 工作流程：
#   1. rg -l <关键字> 先列出所有包含关键字的文件（-l 只输出文件名，不输出匹配内容）
#   2. 管道交给 fzf 模糊选择（弹窗自动套用上方 FZF_DEFAULT_OPTS 的 Dracula 配色）
#   3. 预览窗实时显示匹配上下文：rg -n 带行号 / --color=always 语法高亮 / -C 3 前后各 3 行
#   4. 回车用 $EDITOR（默认 nvim）打开选中文件；ESC 取消则不执行
# 提示：只想看文件名不打开的话，删掉最后的 && ${EDITOR:-nvim} "$file" 即可
rgf() {
  local pattern="${1:-import}"          # 搜索关键字：可传参，默认 import
  local file
  file=$(rg -l "$pattern" 2>/dev/null \
    | fzf --preview "rg -n --color=always -C 3 \"$pattern\" {}") \
    && ${EDITOR:-nvim} "$file"          # 选中后打开；ESC 取消则不执行
}
