# =========================================================
# ~/.config/zsh/prompt.zsh —— 提示符 / 主题
# =========================================================

# 禁止 Python virtualenv 污染提示符（避免出现 (venv) 前缀）
export VIRTUAL_ENV_DISABLE_PROMPT=1

# 函数嵌套调用深度上限（防止递归失控）
FUNCNEST=100

# 初始化 starship 提示符
eval "$(starship init zsh)"
