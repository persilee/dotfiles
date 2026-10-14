# =========================================================
# ~/.config/zsh/plugins.zsh —— 插件管理
# 极简自建加载器：按需 git clone + source，无第三方框架
# =========================================================

# 插件存放目录
ZPLUGINDIR="${ZDOTDIR:-$HOME/.config/zsh}/plugins"

# 插件加载函数：不存在则克隆安装，存在则直接 source
_zplugin_load() {
  local plugin_path="${ZPLUGINDIR}/${2}"
  if [[ ! -d "$plugin_path" ]]; then
    mkdir -p "$ZPLUGINDIR"
    echo "Installing ${2}..."
    git clone --depth=1 "https://github.com/${1}/${2}" "$plugin_path" \
      || { echo "ERROR: failed to install ${2}" >&2; return 1; }
  fi
  source "${plugin_path}/${2}.plugin.zsh"
}

# 一键更新所有已安装插件
zplugin-update() {
  local dir
  for dir in "${ZPLUGINDIR}"/*/; do
    echo "Updating ${dir:t}..."
    git -C "$dir" pull --ff-only
  done
}

# 自动建议文字的高亮样式（白字 + 深灰蓝底）
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ffffff,bg=#45475a"

# ---------- 插件加载列表 ----------
_zplugin_load zsh-users zsh-autosuggestions              # 输入自动建议（幽灵文字）
_zplugin_load zsh-users zsh-history-substring-search     # 历史命令子串搜索
_zplugin_load jeffreytse zsh-vi-mode                     # 命令行 vi 键位模式
_zplugin_load zdharma-continuum fast-syntax-highlighting # 命令行语法高亮
