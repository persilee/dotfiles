# =========================================================
# ~/.config/zsh/aliases.zsh —— 别名与便捷函数
# =========================================================

# ---------- 文件浏览（eza 替代 ls） ----------
# 增强版 ls：带文件类型图标
alias ls='eza --icons'

# 详细信息列表（含 git 状态）
alias ll='eza -lh --icons --git'

# 详细信息列表（含隐藏文件）
alias la='eza -lah --icons --git'

# 树形目录视图
alias tree='eza --tree --icons'
alias lt="eza --tree --level=2 --long --icons --git"
alias ltree="eza --tree --level=2  --icons --git"

# 复用 ls 的补全（避免为 eza 单独定义补全函数）
compdef eza=ls

# ---------- 文件阅读（bat 替代 cat） ----------
alias cat='bat'

# =========================================================
# 核心命令增强
# =========================================================

alias grep='rg --color=auto'    # 全文搜索换用 ripgrep
alias diff='diff --color=auto'  # diff 彩色输出
alias df='df -h'                # 磁盘空间以人类可读单位显示
alias manr="tldr" 

# =========================================================
# 目录导航
# =========================================================

alias cd="z"    # cd 交给 zoxide 智能跳转

# 上级目录快捷跳转
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

alias -- -='cd -'  # -- 防止 - 被当作参数；cd - 返回上一个目录

# lf 文件管理器：退出后自动进入最后浏览的目录
lf() { # 封装 lf 导航
    tmp=$(mktemp)
    command lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir=$(cat "$tmp")
        rm -f "$tmp"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}

# =========================================================
# 编辑器
# =========================================================

alias vim='nvim'

# =========================================================
# Git
# =========================================================

# 提交
alias gc="git commit -m"
alias gca="git commit -a -m"
# 推送 / 拉取
alias gp="git push origin HEAD"
alias gpu="git pull origin"
# 状态 / 日志 / 对比
alias gst="git status"
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(#FF79C6)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
alias gdiff="git diff"
alias gadog='PAGER="less -F -X" git log --all --decorate --oneline --graph'
# 分支 / 检出
alias gco="git checkout"
alias gcoall='git checkout -- .'
alias gb='git branch'
alias gba='git branch -a'
# 暂存 / 重置
alias gadd='git add'
alias ga='git add -p'
alias gre='git reset'
# 远程仓库
alias gr='git remote'
# chezmoi dotfiles 仓库快捷操作（以 ~/dotfiles 为 git 目录、~ 为工作区）
alias dotfiles='git --git-dir=$HOME/dotfiles --work-tree=$HOME'

# =========================================================
# 视频 & 音乐
# =========================================================

# 摄像头实时预览（mpv 低延迟全屏）
alias stream='mpv av://v4l2:/dev/video4 --fullscreen --demuxer-lavf-o=input_format=mjpeg,framerate=30 --profile=low-latency --untimed'

# 一键分屏kitty窗口,打开pigma(音乐)和cava(频谱条)
alias music="$ZDOTDIR/scripts/pigma-cava-kitty.sh"

# =========================================================
# Chezmoi（dotfiles 管理）
# =========================================================

alias chi="chezmoi"

# =========================================================
# Fastfetch（系统信息展示）
# =========================================================

alias ff='fastfetch --logo-type command-raw --logo "fortune song100 | cowsay -W 50 | lolcat -f"'

# 交互式登录时自动展示系统信息（已注释，需要时启用）
# if [[ -o interactive ]]; then
#   fastfetch --logo-type command-raw --logo "fortune tang300 | cowsay -W 50 | lolcat -f"
# fi
