# =========================================================
# ~/.config/zsh/exports.zsh —— 环境变量与 PATH
# 职责：PATH 构建 + 通用环境变量。只放 export，不放命令逻辑。
# 注意：本文件在 .zshrc 中第一个加载，PATH 必须先就位
# =========================================================

# ---------- Homebrew（Apple Silicon） ----------
# 注入 /opt/homebrew/bin，修复 zoxide/fzf/eza 等命令失效
eval "$(/opt/homebrew/bin/brew shellenv)"

# ---------- PATH：个人脚本 ----------
export PATH="$HOME/.local/bin:$PATH"

# ---------- PATH：rustup / cargo ----------
export PATH="$HOME/.cargo/bin:$PATH"

# ---------- PATH：bob 安装的 nvim ----------
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"

# ---------- 分页器（man 手册高亮显示） ----------
if command -v bat >/dev/null 2>&1; then
  export MANPAGER="bat -l man -p"
elif command -v batcat >/dev/null 2>&1; then
  export MANPAGER="batcat -l man -p"
fi

# ---------- GPG（git 签名等需要终端 TTY） ----------
export GPG_TTY=$(tty)

# ---------- Starship 提示符配置 ----------
export STARSHIP_CONFIG="$ZDOTDIR/starship.toml"
