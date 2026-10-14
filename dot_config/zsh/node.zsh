# =========================================================
# ~/.config/zsh/node.zsh —— Node.js / NVM 环境
# =========================================================

# nvm 安装目录
export NVM_DIR="$HOME/.nvm"
# 加载 nvm（[ -s ] 判断文件存在且非空，\. 等价于 source）
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"               # 加载 nvm
# 加载 nvm 的 bash 补全
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
