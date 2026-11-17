# =========================================================
# ~/.config/zsh/python.zsh —— Python / uv 环境
# （原 pyenv 配置已由 uv 取代；pyenv 仅剩 system 版本，可后续 brew uninstall pyenv）
# =========================================================

# --- uv 可执行目录（官方安装脚本装在 ~/.local/bin）---
if [[ -d "$HOME/.local/bin" ]]; then
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
  esac
fi

# --- uv 行为配置 ---
# 项目放在外置卷（如 /Volumes/lsy）时硬链接会跨文件系统失败，改用复制，更稳
export UV_LINK_MODE=copy
# 安装时预编译 .pyc，首次启动更快
export UV_COMPILE_BYTECODE=1
# uv 管理的 Python 安装目录（默认位置，显式写出便于迁移）
export UV_PYTHON_INSTALL_DIR="$HOME/.local/share/uv/python"
# uv tool / uvx 安装的可执行目录
export UV_TOOL_BIN_DIR="$HOME/.local/bin"

# --- 补全（uv 可用时才加载）---
if command -v uv >/dev/null 2>&1; then
  eval "$(uv generate-shell-completion zsh)"
fi

# --- 常用别名 ---
alias uvr='uv run'
alias uvs='uv sync'
alias uva='uv add'
alias uvl='uv python list --only-installed'
