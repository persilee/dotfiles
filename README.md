# dotfiles

我的个人 dotfiles 仓库，用 [chezmoi](https://www.chezmoi.io/) 管理。

## 新机器初始化

```bash
# 1. 安装 chezmoi
brew install chezmoi

# 2. 拉取并初始化仓库
git clone git@github.com:persilee/dotfiles.git ~/dotfiles
chezmoi init ~/dotfiles

# 3. 应用配置（模板会从 macOS 钥匙串读取密钥，需先做第 4 步）
chezmoi apply

# 4. LLM API Key 存入钥匙串（nvim llm 插件需要）
security add-generic-password -U -a lishaoying -s "LLM_KEY" -w "你的key"
```

> 若钥匙串里没有 `LLM_KEY`，每次打开终端会打印提示，按提示执行第 4 步即可。

## 常用命令

```bash
chezmoi apply        # 将仓库配置应用到 ~/（模板渲染，注入密钥）
chezmoi status       # 查看目标文件与仓库源码的差异
chezmoi re-add       # 把修改过的目标文件重新纳入仓库
chezmoi edit <file>  # 用编辑器编辑仓库源码
chezmoi cd           # 进入仓库源码目录
```

## 管理范围

- zsh 配置（`~/.config/zsh/`）
- nvim 配置（`~/.config/nvim/`）
- kitty / wezterm 终端配置
- tmux 配置
- 其他（gitconfig、hammerspoon、vimrc 等）

---

> 说明：当前为简易版 README，等 dotfiles 体系完善稳定后再补充详细文档。
