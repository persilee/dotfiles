# =========================================================
# ~/.config/zsh/fzf.zsh —— fzf 模糊查找配置
# =========================================================

# 默认搜索命令：用 fd（含隐藏文件；strip-cwd-prefix 去掉结果中的 ./ 前缀）
export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix'  # strip-cwd-prefix 去掉 ./ 前缀

# Ctrl-T 触发时使用同样的搜索命令
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# ---------- 界面样式（--height 高度 / --layout 布局 / --border 边框 /
#            --prompt 提示符 / --pointer 指针 / --preview-window 预览窗） ----------
# ---------- Catppuccin-Mocha 配色（与 kitty 终端 / tmux 状态栏同一主题系列） ----------
export FZF_DEFAULT_OPTS='
  --height=60%
  --layout=reverse
  --border=rounded
  --prompt="  "
  --pointer="  "
  --preview-window=right:65%:wrap:border-left
  --color=bg+:#313244,bg:-1,spinner:#f5e0dc,hl:#f38ba8
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
  --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
  --color=selected-bg:#45475a
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
