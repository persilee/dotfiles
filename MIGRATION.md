# 换机迁移指南（dotfiles + Homebrew）

> 旧电脑：李少颖的 MacBook Air（Apple Silicon / arm64）
> 新电脑：Persilee 的 Mac Mini（Apple Silicon / arm64）

## 一、迁移前（旧电脑，本仓库已就绪）

以下已在旧电脑完成：

- [x] `chezmoi status` 无未提交修改（git 干净）
- [x] 生成 `Brewfile`（本仓库根目录，含 tap + formula + cask 全量清单）
- [ ] **commit + push Brewfile**（记得执行下面的命令）

```bash
cd ~/dotfiles
git add Brewfile
git commit -m "chore: 添加 Brewfile 依赖清单（换机迁移用）"
git push
```

## 二、新电脑初始化（按顺序执行）

### 1. 安装基础环境

```bash
# Xcode 命令行工具（如果还没装）
xcode-select --install

# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. 拉取 dotfiles 并应用

```bash
# 安装 chezmoi
brew install chezmoi

# 拉取仓库
git clone git@github.com:persilee/dotfiles.git ~/dotfiles   # 需先配好 SSH key，见下面"密钥迁移"
chezmoi init ~/dotfiles
chezmoi apply
```

### 3. 安装全部软件依赖（Brewfile）

```bash
# 在新电脑的 dotfiles 目录执行，一键装齐 201 formula + 17 cask
brew bundle install --file=~/dotfiles/Brewfile
```

> 若个别软件版本不一致导致问题：`brew bundle cleanup --file=~/dotfiles/Brewfile` 可对齐版本（谨慎使用）。

### 4. 密钥与凭证

```bash
# LLM API Key（nvim llm 插件必需，忘加时终端会打印提示）
security add-generic-password -U -a lishaoying -s "LLM_KEY" -w "你的key"

# SSH key：从旧电脑复制（scp 或 AirDrop），或重新生成并加到 GitHub
#   旧电脑: scp ~/.ssh/id_ed25519 ~/.ssh/id_ed25519.pub 新电脑:~/.ssh/
#   或新电脑重新生成: ssh-keygen -t ed25519 -C "你的邮箱" && 把 .pub 加到 GitHub

# gh CLI 登录（GitHub 发布/资产管理用）
gh auth login
```

### 5. 验证清单

```bash
# 终端核心工具（Brewfile 装完后应全部可用）
zoxide --version && eza --version && fzf --version && bat --version
fd --version && rg --version && starship --version && fastfetch --version
tmux -V && nvim --version | head -1 && lazygit --version

# 配置是否生效
echo $LLM_KEY          # 应有值（来自钥匙串）
echo $ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE   # zsh 配置已加载
nvim                   # 打开后 llm 对话 <leader>ac 正常、补全正常
kitty                  # 主题/字体/混合字体生效
tmux                   # 插件（tpm）自动安装完成后正常
```

## 三、注意点

| 事项 | 说明 |
|---|---|
| `~/.ssh` | 私钥权限必须 `600`（`chmod 600`），复制后检查 |
| `~/.gnupg` | 如旧电脑有 GPG 私钥，需一并迁移（`gpg --export-secret-keys`） |
| 钥匙串 | LLM_KEY 是新电脑**必须手动添加**的一步，其余密码（Wi-Fi/账号）各自登录 |
| nvim 插件 | 首次启动 Lazy 会自动安装，`nvim` 打开后等插件同步完再使用 |
| tmux 插件 | tpm 插件首次进入 tmux 后按 `prefix + I` 安装 |
| 字体 | kitty 混合字体（Maple Mono CN / Comic / Fira Code）需在系统里安装字体文件 |

## 四、旧电脑善后（可选）

- 确认新电脑一切正常后再处理旧电脑
- 若担心旧电脑数据：`chezmoi cd` 里检查还有哪些未纳入仓库的散落配置（`~/.config` 下非 dotfiles 管理的软件配置可另行备份）
