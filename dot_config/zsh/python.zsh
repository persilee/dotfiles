# =========================================================
# ~/.config/zsh/python.zsh —— Python / pyenv 环境
# =========================================================

# pyenv 根目录
export PYENV_ROOT="$HOME/.pyenv"
# pyenv 可执行目录加入 PATH（目录存在时才添加）
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
# 初始化 pyenv（自动管理 Python 版本与虚拟环境）
eval "$(pyenv init -)"
