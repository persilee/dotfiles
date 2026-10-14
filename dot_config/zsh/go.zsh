# =========================================================
# ~/.config/zsh/go.zsh —— Go 语言环境
# =========================================================

# Go 模块与工具安装目录
export GOPATH="$HOME/go"
# go install 安装的工具（gopls、dlv 等）加入 PATH
export PATH="$PATH:$GOPATH/bin"
