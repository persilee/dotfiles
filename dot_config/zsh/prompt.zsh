# =========================================================
# ~/.config/zsh/prompt.zsh —— 提示符 / 主题
# =========================================================

# 禁止 Python virtualenv 污染提示符（避免出现 (venv) 前缀）
export VIRTUAL_ENV_DISABLE_PROMPT=1

# 函数嵌套调用深度上限（防止递归失控）
FUNCNEST=100

# 初始化 starship 提示符
eval "$(starship init zsh)"

# ---------- kitty shell integration（官方手动加载） ----------
# kitty 自动注入依赖 ZDOTDIR，与自定义 ZDOTDIR 冲突，故按官方文档手动加载
if [[ -n "$KITTY_INSTALLATION_DIR" ]]; then
  export KITTY_SHELL_INTEGRATION="enabled no-cursor"
  autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
  kitty-integration
  unfunction kitty-integration
fi

# ---------- 标题增强：执行命令时在命令前显示图标 ----------
# 保留 kitty 官方逻辑（提示符 = 目录缩写），仅覆盖"执行命令"场景的标题
# 注意：kitty 官方集成是延迟初始化——首次提示符时才注册其 preexec 钩子，
# 会排在我们后面并覆盖标题。因此用 precmd 钩子把我们的标题钩子移到
# preexec 列表末尾，确保在官方钩子之后执行。
_my_preexec_title() {
  print -Pn "\e]2;  ${1//\%/%%}\a"
}
_my_fix_hook_order() {
  preexec_functions=(${preexec_functions:#_my_preexec_title} _my_preexec_title)
}
autoload -Uz add-zsh-hook
add-zsh-hook preexec _my_preexec_title
add-zsh-hook precmd _my_fix_hook_order
