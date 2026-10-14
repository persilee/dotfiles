# \~/.config/zsh —— Zsh 配置说明

> 模块化 zsh 配置：不使用 oh-my-zsh 等框架，采用 
>
> **ZDOTDIR + 按功能拆分文件 + 自建极简插件加载器**
>
>  的方式组织。本文档说明整套配置的运行机制、依赖清单，以及每个模块的功能点与快捷键。



***

## 目录



1. [整体结构](#一整体结构)

2. [运行机制：zsh 如何加载这套配置](#二运行机制zsh-如何加载这套配置)

3. [依赖清单](#三依赖清单)

4. [模块详解与快捷键](#四模块详解与快捷键)

5. [常用操作速查](#五常用操作速查)

6. [修改指南：什么功能改哪个文件](#六修改指南什么功能改哪个文件)

7. [常见问题排查](#七常见问题排查)



***

## 一、整体结构



```
~/.config/zsh/
├── .zshenv            # 所有 zsh 会话（含非交互/脚本）都会加载：XDG 目录 + 编辑器
├── .zshrc             # 交互式 shell 主配置：加载顺序编排 + 历史/补全/Shell 行为
├── exports.zsh        # 环境变量与 PATH（必须最先加载）
├── python.zsh         # Python / pyenv 环境
├── node.zsh           # Node.js / nvm 环境
├── go.zsh             # Go 语言环境
├── rust.zsh           # Rust / rustup 环境
├── fzf.zsh            # fzf 模糊查找配置
├── aliases.zsh        # 全部别名与便捷函数
├── bindings.zsh       # 自定义键位绑定（zsh-vi-mode 钩子内注册）
├── plugins.zsh        # 自建插件加载器 + 插件列表
├── prompt.zsh         # 提示符（starship）
├── starship.toml      # starship 主题配置（独立文件，不属于 zsh 脚本）
├── plugins/           # 插件克隆目录（由 plugins.zsh 自动管理）
│   ├── zsh-autosuggestions/
│   ├── zsh-history-substring-search/
│   ├── zsh-vi-mode/
│   └── fast-syntax-highlighting/
└── README.md          # 本文档
```



***

## 二、运行机制：zsh 如何加载这套配置

### 2.1 ZDOTDIR 入口

zsh 默认从 `~/.zshrc` 读取配置。为了让配置**集中到&#x20;**`~/.config/zsh/`，本套配置利用 `ZDOTDIR` 变量改变 zsh 的配置搜索目录：



1. macOS 上 zsh 启动时最先读取系统级文件 `/etc/zshenv`（root 拥有，用 sudo 写入）

2. `/etc/zshenv` 中设置：



```
if [[ -z "$XDG_CONFIG_HOME" ]]; then export XDG_CONFIG_HOME="$HOME/.config"; fi
if [[ -d "$XDG_CONFIG_HOME/zsh" ]]; then export ZDOTDIR="$XDG_CONFIG_HOME/zsh"; fi
```



1. `ZDOTDIR` 生效后，zsh 改为读取 `~/.config/zsh/.zshenv` 和 `~/.config/zsh/.zshrc`

### 2.2 加载顺序（关键）



```
zsh 启动
└─ /etc/zshenv（系统级）
    └─ 设置 ZDOTDIR
        ├─ .zshenv            # 所有会话：XDG 目录 + EDITOR/VISUAL
        └─ .zshrc             # 交互式 shell 主配置
            ├─ ① exports.zsh        # 环境变量 & PATH —— 必须最先，后续模块依赖 PATH
            ├─ ② 历史记录           # HISTFILE + setopt 历史选项
            ├─ ③ Shell 行为         # setopt AUTOCD 等 + zoxide 初始化
            ├─ ④ 补全系统           # compinit + zstyle 补全样式
            ├─ ⑤ fzf 官方键位脚本    # 多平台（macOS/Arch/Ubuntu）探测加载
            └─ ⑥ 模块化加载
                ├─ python.zsh / node.zsh / go.zsh / rust.zsh   # 语言环境
                ├─ fzf.zsh           # fzf 界面与预览配置
                ├─ aliases.zsh       # 别名
                ├─ bindings.zsh      # 键位
                ├─ plugins.zsh       # 插件
                └─ prompt.zsh        # starship 提示符
```

**为什么 exports.zsh 必须在最前面？**

`zoxide init`、`fzf` 键位脚本、`starship init` 等执行时都要在 PATH 里找到对应命令；而 `/opt/homebrew/bin`（brew 安装路径）不在 macOS 默认 PATH 里，必须由 `exports.zsh` 中的 `eval "$(/opt/homebrew/bin/brew shellenv)"` 注入。加载顺序颠倒就会报 `command not found`。

### 2.3 两种会话的差异



| 会话类型                  | 加载文件                                 | 说明                  |
| --------------------- | ------------------------------------ | ------------------- |
| 交互式 shell（终端）         | `/etc/zshenv` → `.zshenv` → `.zshrc` | 完整功能                |
| 非交互（脚本、cron、`zsh -c`） | `/etc/zshenv` → `.zshenv`            | 只有基础环境，不加载 `.zshrc` |

所以**只有最基础的环境变量（XDG、EDITOR）放在&#x20;**`.zshenv`，其余全部放 `.zshrc`。



***

## 三、依赖清单

### 3.1 外部命令



| 命令                              | 用途                   | 被谁使用                        | 缺失后果                          |
| ------------------------------- | -------------------- | --------------------------- | ----------------------------- |
| `brew`                          | Homebrew 包管理         | exports.zsh                 | PATH 注入失败，大量命令找不到             |
| `zoxide`                        | 智能目录跳转               | .zshrc / aliases            | `cd` 别名失效                     |
| `fzf`                           | 模糊查找                 | .zshrc / fzf.zsh / bindings | Ctrl+T / Ctrl+F / Ctrl+R 失效   |
| `fd`                            | 文件搜索后端（fzf 用）        | fzf.zsh                     | 默认搜索命令失效                      |
| `bat`                           | 文件查看 / 预览高亮          | aliases / fzf / exports     | `cat` 别名、fzf 预览、man 高亮失效      |
| `eza`                           | ls 增强替代              | aliases                     | `ls`/`ll`/`la`/`tree` 失效      |
| `rg`                            | 快速搜索（ripgrep）        | aliases                     | `grep` 别名失效                   |
| `starship`                      | 跨 shell 提示符          | prompt / exports            | 提示符不显示                        |
| `pyenv`                         | Python 版本管理          | python.zsh                  | Python 环境不初始化                 |
| `nvm`                           | Node 版本管理            | node.zsh                    | node 命令不在 PATH（如 bashls 启动失败） |
| `go`                            | Go 工具链               | go.zsh                      | GOPATH 工具不在 PATH              |
| `rustup`                        | Rust 工具链             | rust.zsh                    | cargo 工具不在 PATH               |
| `bob`                           | nvim 版本管理            | exports PATH / aliases      | `vim` 别名失效                    |
| `chezmoi`                       | dotfiles 管理          | aliases `chi`               | `chi` 别名失效                    |
| `lf`                            | 终端文件管理器              | aliases `lf()`              | `lf` 函数失效                     |
| `mpv`                           | 视频播放                 | aliases `stream`            | `stream` 别名失效                 |
| `fastfetch`                     | 系统信息展示               | aliases `ff`                | `ff` 别名失效                     |
| `cowsay` / `lolcat` / `fortune` | 趣味输出（fastfetch logo） | aliases `ff`                | `ff` 别名部分失效                   |

### 3.2 目录 / 文件依赖



| 路径                            | 用途                | 被谁使用             |
| ----------------------------- | ----------------- | ---------------- |
| `~/.nvm/nvm.sh`               | nvm 主脚本           | node.zsh         |
| `~/.pyenv/bin`                | pyenv 可执行目录       | python.zsh       |
| `~/.local/bin/env`            | rustup 生成的环境文件    | rust.zsh         |
| `~/.local/share/bob/nvim-bin` | bob 管理的 nvim 链接   | exports.zsh PATH |
| `~/.cargo/bin`                | cargo 安装的 Rust 工具 | exports.zsh PATH |
| `~/.local/bin`                | 个人脚本              | exports.zsh PATH |
| `~/.config/zsh/plugins/`      | 插件克隆目录            | plugins.zsh      |
| `~/.local/state/zsh/history`  | zsh 历史文件          | .zshrc           |
| `~/.cache/zsh/zcompdump`      | 补全缓存              | .zshrc           |

### 3.3 插件依赖（首次运行自动安装）

`plugins.zsh` 的 `_zplugin_load` 函数会在插件目录不存在时自动 `git clone`（depth=1），无需手动安装：



| 插件                           | 仓库                                         | 功能          |
| ---------------------------- | ------------------------------------------ | ----------- |
| zsh-autosuggestions          | zsh-users/zsh-autosuggestions              | 输入时自动建议（灰字） |
| zsh-history-substring-search | zsh-users/zsh-history-substring-search     | 历史命令子串搜索    |
| zsh-vi-mode                  | jeffreytse/zsh-vi-mode                     | 命令行 vi 键位模式 |
| fast-syntax-highlighting     | zdharma-continuum/fast-syntax-highlighting | 命令行语法高亮     |

> 插件更新：执行 
>
> `zplugin-update`
>
> （见下文）。



***

## 四、模块详解与快捷键

### 4.1 `.zshenv` —— 全局基础环境



| 配置                              | 作用                 |
| ------------------------------- | ------------------ |
| `XDG_CONFIG_HOME=~/.config`     | 配置文件根目录            |
| `XDG_CACHE_HOME=~/.cache`       | 缓存根目录              |
| `XDG_DATA_HOME=~/.local/share`  | 数据根目录              |
| `XDG_STATE_HOME=~/.local/state` | 状态根目录（日志、历史等）      |
| `EDITOR=nvim`                   | git、crontab 等默认编辑器 |
| `VISUAL=nvim`                   | 全屏 / 视觉编辑器         |

### 4.2 `.zshrc` 内嵌配置

**历史记录**



| 配置                                    | 作用                       |
| ------------------------------------- | ------------------------ |
| `HISTFILE=~/.local/state/zsh/history` | 历史文件位置（跟随 XDG）           |
| `HISTSIZE / SAVEHIST = 100000`        | 内存 / 磁盘历史条数上限            |
| `setopt APPEND_HISTORY`               | 追加写入而非覆盖                 |
| `setopt SHARE_HISTORY`                | 多终端会话共享历史                |
| `setopt HIST_IGNORE_DUPS`             | 忽略完全重复的命令                |
| `setopt HIST_IGNORE_SPACE`            | 以空格开头的命令不入历史（敏感命令可加空格前缀） |
| `setopt HIST_EXPIRE_DUPS_FIRST`       | 超限时优先淘汰重复项               |
| `setopt HIST_FIND_NO_DUPS`            | 搜索历史时不显示重复项              |

**Shell 行为**



| 配置                         | 作用                            |
| -------------------------- | ----------------------------- |
| `setopt AUTOCD`            | 直接输入目录路径回车即可进入（免敲 cd）         |
| `setopt NOBEEP`            | 关闭错误提示音                       |
| `setopt NUMERIC_GLOB_SORT` | 通配符展开按数值排序（file10 排在 file9 后） |

**补全系统**



| 配置                                       | 作用              |
| ---------------------------------------- | --------------- |
| `autoload -Uz compinit` + `compinit -d`  | 初始化补全，使用缓存加速    |
| `zstyle ':completion:*' menu select`     | Tab 弹出菜单后用方向键选择 |
| `zstyle matcher-list 'm:{a-z}={A-Za-z}'` | 补全大小写不敏感        |

### 4.3 `exports.zsh` —— 环境变量与 PATH



| 配置                                            | 作用                                        |
| --------------------------------------------- | ----------------------------------------- |
| `eval "$(/opt/homebrew/bin/brew shellenv)"`   | 注入 `/opt/homebrew/bin` 到 PATH（**本配置的地基**） |
| `PATH=~/.local/bin:$PATH`                     | 个人脚本目录                                    |
| `PATH=~/.cargo/bin:$PATH`                     | Rust 工具（cargo install 装的）                 |
| `PATH=~/.local/share/bob/nvim-bin:$PATH`      | bob 管理的 nvim                              |
| `MANPAGER=bat -l man -p`                      | man 手册用 bat 高亮分页                          |
| `GPG_TTY=$(tty)`                              | git 签名等 GPG 操作绑定当前终端                      |
| `STARSHIP_CONFIG=~/.config/zsh/starship.toml` | starship 配置文件位置                           |

### 4.4 目录导航（zoxide + AUTOCD + 别名）

**zoxide 智能跳转**（`.zshrc` 中 `zoxide init zsh` 初始化）



| 操作      | 快捷键 / 命令     | 说明            |
| ------- | ------------ | ------------- |
| 模糊跳转    | `z <关键字>`    | 按历史频率跳转到匹配目录  |
| 直接跳转    | 输入目录路径 + 回车  | 由 `AUTOCD` 支持 |
| 交互选择    | `z -i <关键字>` | 多个候选时用 fzf 选择 |
| 返回上一个目录 | `-` 或 `cd -` |               |

**上级目录快捷方式**（aliases.zsh）



| 命令                          | 作用            |
| --------------------------- | ------------- |
| `..`                        | 上一级           |
| `...`                       | 上两级           |
| `....` / `.....` / `......` | 上三级 / 四级 / 五级 |
| `-`                         | 返回上一个目录       |

**lf 文件管理器**：输入 `lf` 打开文件管理器，**退出后自动 cd 到最后浏览的目录**（无需手动进入）。

### 4.5 fzf 模糊查找

**官方键位**（`.zshrc` 加载 fzf 的 key-bindings.zsh，多平台自动探测）



| 快捷键      | 作用              |
| -------- | --------------- |
| `Ctrl+T` | 搜索文件，把选中路径插入命令行 |
| `Ctrl+R` | 搜索历史命令，选中后回填    |
| `Alt+C`  | 搜索目录，选中后 cd 进入  |

**自定义键位**（bindings.zsh 注册）



| 快捷键      | 作用                         |
| -------- | -------------------------- |
| `Ctrl+F` | 文件选择器（**排除隐藏文件**，带 bat 预览） |

**界面配置**（fzf.zsh）



| 项目   | 值                        | 说明             |
| ---- | ------------------------ | -------------- |
| 搜索后端 | `fd --type f --hidden`   | 文件类型过滤 + 含隐藏文件 |
| 高度   | 60%                      | 窗口高度           |
| 布局   | reverse                  | 结果从下往上排列       |
| 边框   | rounded                  | 圆角边框           |
| 预览窗  | 右侧 65%，自动换行              | 左侧列表、右侧预览文件内容  |
| 预览命令 | `bat`（纯文本 + 行号，最多 500 行） | 语法高亮预览         |

### 4.6 `aliases.zsh` —— 全部别名

**文件浏览（eza 替代 ls）**



| 别名      | 等价命令                                        | 说明            |
| ------- | ------------------------------------------- | ------------- |
| `ls`    | `eza --icons`                               | 列表 + 图标       |
| `ll`    | `eza -lh --icons --git`                     | 详细列表 + git 状态 |
| `la`    | `eza -lah --icons --git`                    | 详细列表含隐藏文件     |
| `tree`  | `eza --tree --icons`                        | 树形视图          |
| `lt`    | `eza --tree --level=2 --long --icons --git` | 2 层树 + 详情     |
| `ltree` | `eza --tree --level=2 --icons --git`        | 2 层树          |
| `cat`   | `bat`                                       | 高亮文件内容        |

**核心命令增强**



| 别名                           | 说明             |
| ---------------------------- | -------------- |
| `grep` → `rg --color=auto`   | 全文搜索换用 ripgrep |
| `diff` → `diff --color=auto` | 彩色 diff        |
| `df` → `df -h`               | 人类可读磁盘空间       |

**Git 别名**



| 别名           | 等价命令                                             | 说明                                               |
| ------------ | ------------------------------------------------ | ------------------------------------------------ |
| `gc`         | `git commit -m`                                  | 提交（带消息）                                          |
| `gca`        | `git commit -a -m`                               | 提交所有改动                                           |
| `gp`         | `git push origin HEAD`                           | 推送当前分支                                           |
| `gpu`        | `git pull origin`                                | 拉取                                               |
| `gst`        | `git status`                                     | 状态                                               |
| `glog`       | 图形化 log                                          | 彩色提交图（作者 / 时间 / 消息）                              |
| `gdiff`      | `git diff`                                       | 差异                                               |
| `gadog`      | `git log --all --oneline --graph`                | 全部分支提交图                                          |
| `gco`        | `git checkout`                                   | 切换分支                                             |
| `gcoall`     | `git checkout -- .`                              | 丢弃全部工作区改动                                        |
| `gb` / `gba` | `git branch` / `-a`                              | 分支列表 / 含远程                                       |
| `gadd`       | `git add`                                        | 暂存                                               |
| `ga`         | `git add -p`                                     | 交互式分块暂存                                          |
| `gre`        | `git reset`                                      | 重置                                               |
| `gr`         | `git remote`                                     | 远程仓库管理                                           |
| `dotfiles`   | `git --git-dir=$HOME/dotfiles --work-tree=$HOME` | chezmoi 仓库快捷操作（把 `~` 当工作区、`~/dotfiles` 当 git 目录） |

**其他**



| 别名             | 说明                                            |
| -------------- | --------------------------------------------- |
| `vim` → `nvim` | 编辑器统一走 nvim                                   |
| `stream`       | mpv 低延迟全屏预览摄像头（/dev/video4）                   |
| `chi`          | `chezmoi` 缩写                                  |
| `ff`           | fastfetch 系统信息（fortune+cowsay+lolcat 趣味 logo） |

### 4.7 `bindings.zsh` —— 键位绑定

**光标形状**（依赖 zsh-vi-mode）



| 模式   | 光标        | 值                   |
| ---- | --------- | ------------------- |
| 插入模式 | 竖线（beam）  | `$ZVM_CURSOR_BEAM`  |
| 普通模式 | 方块（block） | `$ZVM_CURSOR_BLOCK` |
| 可视模式 | 方块（block） | `$ZVM_CURSOR_BLOCK` |

（光标粗细由终端决定：WezTerm 用 `cursor_thickness`，kitty 不支持 beam 加粗）

**自定义键位**（注册在 `zvm_after_init` 钩子内，避免被 zsh-vi-mode 初始化重置）



| 快捷键      | 作用                 |
| -------- | ------------------ |
| `Ctrl+→` | 按词前移光标             |
| `Ctrl+←` | 按词后移光标             |
| `Ctrl+F` | fzf 文件选择器（不含隐藏文件）  |
| `Ctrl+\` | 切换自动建议开 / 关（录屏演示用） |
| `↑`      | 历史命令向上搜索（子串匹配）     |
| `↓`      | 历史命令向下搜索（子串匹配）     |

### 4.8 `plugins.zsh` —— 插件系统

**自建加载器原理**：`_zplugin_load <owner> <repo>` —— 插件目录不存在则 `git clone --depth=1`，存在则直接 `source 插件目录/<repo>.plugin.zsh`。无需 oh-my-zsh /zinit/antigen 等框架。

**更新插件**：`zplugin-update` —— 遍历 plugins 目录逐个 `git pull --ff-only`。

**插件功能与快捷键**



| 插件                           | 功能               | 相关快捷键 / 交互                                                                          |
| ---------------------------- | ---------------- | ----------------------------------------------------------------------------------- |
| zsh-autosuggestions          | 输入时显示灰字建议（按历史预测） | `→` 或 `End` 接受建议；`Ctrl+\` 开关；建议颜色 `fg=#ffffff,bg=#45475a`                           |
| zsh-history-substring-search | 历史命令子串搜索         | `↑`/`↓`（已绑定到 bindings.zsh）                                                          |
| zsh-vi-mode                  | 命令行 vi 编辑模式      | `Esc` 进入普通模式，`i` 插入；`hjkl` 移动；`0`/`$` 行首 / 行尾；`w`/`b` 按词移动；`dd` 删整行；`/` 历史搜索；`u` 撤销 |
| fast-syntax-highlighting     | 命令语法高亮           | 自动生效（命令合法为绿色，错误为红色）                                                                 |

### 4.9 `prompt.zsh` —— 提示符（starship）



| 配置                             | 作用                                   |
| ------------------------------ | ------------------------------------ |
| `VIRTUAL_ENV_DISABLE_PROMPT=1` | 阻止 Python venv 在提示符前加 `(venv)` 前缀    |
| `FUNCNEST=100`                 | 函数嵌套深度上限（防递归失控）                      |
| `eval "$(starship init zsh)"`  | 启用 starship 提示符（主题见 `starship.toml`） |

### 4.10 语言环境模块



| 模块         | 内容                       | 作用                               |
| ---------- | ------------------------ | -------------------------------- |
| python.zsh | `pyenv` 初始化              | 自动切换 Python 版本与虚拟环境              |
| node.zsh   | `nvm.sh` + 补全            | node/npm 版本管理（**依赖：\~/.nvm 存在**） |
| go.zsh     | `GOPATH` + `$GOPATH/bin` | Go 工具（gopls、dlv）可用               |
| rust.zsh   | 加载 `~/.local/bin/env`    | cargo/rustup 工具链可用               |



***

## 五、常用操作速查



```
# 重新加载配置（改完配置后）
source ~/.config/zsh/.zshrc

# 语法检查（改完文件先检查再重载）
zsh -n ~/.config/zsh/.zshrc

# 更新全部插件
zplugin-update

# 手动安装新插件（owner/repo 换成实际值）
_zplugin_load <github-owner> <repo-name>

# 查看所有别名
alias

# 查看当前 PATH
echo $PATH | tr ':' '\n'

# 历史搜索
Ctrl+R（fzf） / ↑↓（子串搜索）
```



***

## 六、修改指南：什么功能改哪个文件



| 想做什么                | 改哪个文件                                      |
| ------------------- | ------------------------------------------ |
| 加 / 改环境变量、PATH      | exports.zsh                                |
| 加 / 改别名、函数          | aliases.zsh                                |
| 加 / 改快捷键            | bindings.zsh（在 `zvm_after_init()` 内）       |
| 加 / 改插件             | plugins.zsh（`_zplugin_load` 行）             |
| 改提示符样式              | starship.toml                              |
| 改历史 / 补全 / Shell 行为 | .zshrc                                     |
| 加新语言环境              | 新建 `xxx.zsh` + 在 .zshrc 的模块加载段加一行 `source` |
| 改 XDG 目录、默认编辑器      | .zshenv                                    |



***

## 七、常见问题排查



| 现象                                                   | 原因                         | 解决                                                                                |
| ---------------------------------------------------- | -------------------------- | --------------------------------------------------------------------------------- |
| `command not found: zoxide/fzf/eza...`               | PATH 缺 `/opt/homebrew/bin` | 检查 exports.zsh 是否有 `eval "$(/opt/homebrew/bin/brew shellenv)"`，且它在 `.zshrc` 中最先加载 |
| node 相关（如 nvim 的 bashls 报 `env: node: No such file`） | nvm 未加载                    | 确认 node.zsh 已存在且被 source；新开终端验证 `which node`                                      |
| 插件不生效                                                | 未重载 / 插件未安装                | `source ~/.config/zsh/.zshrc` 或重开终端；检查 plugins/ 目录                                |
| 补全卡顿或旧                                               | 缓存未更新                      | 删除 `~/.cache/zsh/zcompdump` 后重开终端                                                 |
| zsh-vi-mode 键位异常                                     | 自定义绑定被重置                   | 自定义键位必须写在 `zvm_after_init()` 内（bindings.zsh 已如此）                                  |
| 提示符异常                                                | starship 配置 / 命令缺失         | `which starship`；检查 exports.zsh 的 STARSHIP\_CONFIG                                |