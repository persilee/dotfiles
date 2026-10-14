# =========================================================
# ~/.config/zsh/bindings.zsh —— 自定义键位绑定
# =========================================================

# ---------- zsh-vi-mode：各模式下的光标形状 ----------
# 插入模式：竖线光标
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLOCK
# 普通模式：方块光标
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
# 可视模式：方块光标
ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK

# ---------- zsh-vi-mode：关闭命令行高亮 ----------
ZVM_VI_HIGHLIGHT_BACKGROUND=none
ZVM_VI_HIGHLIGHT_FOREGROUND=none
ZVM_VI_HIGHLIGHT_EXTRASTYLE=none

# zsh-vi-mode 初始化时会重置所有绑定，
# 因此自定义绑定必须通过这个钩子注册才能保留。
zvm_after_init() {
  # Ctrl+→：按词前移光标（^[[1;5C 是终端转义码）
  bindkey '^[[1;5C' forward-word

  # Ctrl+←：按词后移光标（^[[1;5D 是终端转义码）
  bindkey '^[[1;5D' backward-word

  # Ctrl+F：fzf 文件选择器（不含隐藏文件）
  bindkey '^F' _fzf_file_no_hidden

  # Ctrl+\：切换自动建议（录屏演示时有用）
  bindkey '^\' autosuggest-toggle

  # ↑/↓：按子串搜索历史（^[[A/^[[B 是上下箭头转义码）
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
}
