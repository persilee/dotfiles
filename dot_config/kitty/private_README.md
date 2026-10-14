# ~/.config/kitty —— Kitty 终端配置说明

> 本 README 基于当前 `~/.config/kitty/` 目录下的全部配置自动整理，说明每个配置项、每个快捷键的作用，并附带常用技巧与排障指引。
> 官方文档：https://sw.kovidgoyal.net/kitty/conf.html

---

## 目录

1. [配置总览与文件结构](#一配置总览与文件结构)
2. [配置项详解](#二配置项详解)
3. [快捷键大全](#三快捷键大全)
4. [常规高频使用技巧](#四常规高频使用技巧)
5. [主题与字体](#五主题与字体)
6. [常见问题排查](#六常见问题排查)

---

## 一、配置总览与文件结构

```
~/.config/kitty/
├── kitty.conf              # 主配置：基础设置/字体/窗口外观/光标/鼠标/标签栏/主题/标记
├── mappings.conf           # 快捷键映射（由 kitty.conf include 加载）
├── dracula.conf            # Dracula 主题配色（当前生效，BEGIN_KITTY_THEME 块引用）
├── current-theme.conf      # Catppuccin-Mocha 主题存档（切换工具保留）
├── open-actions.conf       # 打开文件动作：文本中的文件路径用 nvim 打开
├── fonts/
│   ├── maplemono.conf      # 主字体：Maple Mono NF CN（当前启用）
│   └── berkley/caskaydia/firacode/hack/iosevka/jetbrain/sourcecodepro.conf  # 备选字体
└── helpers/
    └── custom_match.py     # hints 自定义匹配脚本（提取 KEY: xxx value; 中的 value）
```

**加载关系**：`kitty.conf` → `include fonts/maplemono.conf` + `include mappings.conf` + `include dracula.conf`（主题块）。

---

## 二、配置项详解

### 2.1 基础设置（Shell 与交互）

| 配置项 | 值 | 功能 |
|---|---|---|
| `shell` | `.` | 新窗口/新标签页启动时的工作目录**跟随当前 shell 所在目录** |
| `shell_integration` | `no-rc no-cursor` | shell 集成：`no-rc` 停止自动注入 ZDOTDIR（与自定义 ZDOTDIR 共存），`no-cursor` 禁用光标形状控制（交给 zsh-vi-mode） |
| `allow_remote_control` | `yes` | 允许外部通过 `kitty @` 命令远程控制本终端实例 |
| `copy_on_select` | `yes` | **选中文本即自动复制**到剪贴板（免 Cmd+C） |
| `click_interval` | `-1.0` | 禁用双击选择（-1 表示不启用），只保留单击/三击 |

### 2.2 字体

| 配置项 | 值 | 功能 |
|---|---|---|
| `include fonts/maplemono.conf` | — | 加载主字体：**Maple Mono NF CN**（自带完整中文字形 + Nerd Font 图标） |
| `font_size` | `14` | 主字号 14 磅 |
| `adjust_line_height` | `3` | 行高微调（正值增大行距） |
| `symbol_map` | 多个 Unicode 区段 → Symbols Nerd Font Mono | **图标字体映射**：把 Nerd Font/Powerline 等私有区字符交给 Nerd Font Mono 渲染（保证终端内图标/符号正常显示） |
| `disable_ligatures` | `cursor` | 连字策略：**光标移动经过时才禁用连字**（平时正常显示 `->`、`=>` 等连字） |
| `box_drawing_scale` | `0.5, 0.8, 1.0, 1.5` | 边框绘制字符缩放（细/常规/粗/特粗四档），兼容不同字体对齐 |

### 2.3 窗口外观

| 配置项 | 值 | 功能 |
|---|---|---|
| `hide_window_decorations` | `titlebar-only` | 隐藏系统窗口装饰，仅保留标题栏 |
| `macos_quit_when_last_window_closed` | `yes` | 关闭最后一个窗口时退出 kitty（macOS 习惯） |
| `dynamic_background_opacity` | `yes` | 允许动态调整背景透明度 |
| `background_opacity` | `0.5` | **背景半透明**（50% 不透明度） |
| `background_blur` | `26` | **毛玻璃模糊强度**（半透明背景下生效） |
| `window_padding_width` | `12` | 内容四周内边距 12px，不贴边 |
| `placement_strategy` | `top-left` | 新窗口从屏幕左上角开始排布 |
| `window_logo_scale` / `_alpha` / `_position` | `5` / `0.25` / `top-right` | 右上角窗口 Logo（缩放 5 倍、25% 透明度） |

### 2.4 光标样式与特效

| 配置项 | 值 | 功能 |
|---|---|---|
| `custom_shaders` | `cursor-trail-motion-blur` | 启用光标轨迹运动模糊着色器 |
| `cursor_shape` | `block` | 默认光标形状：方块 |
| `cursor_beam_thickness` | `2` | 竖线（beam）光标厚度 |
| `cursor_trail` | `20` | 光标移动轨迹长度（像素） |
| `cursor_trail_decay` | `0.0 0.3` | 轨迹衰减参数（控制消失速度） |
| `cursor_blink_interval` | `0` | 光标不闪烁 |

### 2.5 鼠标与滚动

| 配置项 | 值 | 功能 |
|---|---|---|
| `detect_urls` | `no` | 关闭 URL 自动检测（不自动给链接加下划线） |
| `pixel_scroll` | `yes` | **逐像素平滑滚动**（替代按行滚动） |

### 2.6 标签栏（Tab Bar）

| 配置项 | 值 | 功能 |
|---|---|---|
| `tab_bar_edge` | `top` | 标签栏在**顶部** |
| `tab_bar_style` | `powerline` | powerline 风格（带分隔箭头） |
| `tab_powerline_style` | `round` | 分隔箭头形状：圆角 |
| `active_tab_foreground/background` | `#1E1E2E / #CBA6F7` | 激活标签：深色字 + 薰衣草紫底（Catppuccin 风格，固定覆盖） |
| `inactive_tab_foreground/background` | `#CDD6F4 / #181825` | 未激活标签：浅色字 + 近黑底 |
| `tab_bar_background` | `none` | 标签栏背景跟随终端背景（配合半透明+毛玻璃） |

### 2.7 日志标记高亮（Marks）

| 配置项 | 值 | 功能 |
|---|---|---|
| `mark1_foreground/background` | `#74c7ec / #1E1E2E` | 级别 1（INFO）标记色 |
| `mark2_foreground/background` | `#F9E2AF / #1E1E2E` | 级别 2（WARNING）标记色 |
| `mark3_foreground/background` | `#F38BA8 / #1E1E2E` | 级别 3（ERROR/FATAL）标记色 |
| `map ctrl+shift+m ...` | — | 快捷键：切换日志标记高亮（按级别高亮 INFO/WARNING/ERROR/FATAL 关键字） |

### 2.8 其他

| 配置项 | 值 | 功能 |
|---|---|---|
| `macos_option_as_alt` | `yes` | 把 macOS 的 Option 键当作 Alt 使用（终端程序需要 Alt 前缀，如 vim 的 Alt 组合键） |
| `include dracula.conf` | — | 加载 Dracula 主题配色（见第五章） |
| `open-actions.conf` | file + text/* → nvim | 匹配文本中的文件路径时用 nvim（overlay 浮层）打开 |

---

## 三、快捷键大全

> 来源：`mappings.conf`。`cmd` = Command(⌘)，`alt` = Option(⌥)，`ctrl` = Control(⌃)。

### 3.1 被禁用的默认快捷键（no_op）

| 快捷键 | 原因 |
|---|---|
| `Cmd+F` | 避免与系统查找冲突 |
| `Alt+Shift+H` / `Alt+Shift+L` | 防误触 |
| `Cmd+Shift+D` | 防误触（默认 detach 类操作） |
| `Ctrl+Shift+R` | 防误触重载/重绘 |
| `Cmd+\`` / `Cmd+Shift+\`` | macOS 窗口切换键，防误触 |
| `Ctrl+Shift+U` / `Ctrl+Alt+U` / `Ctrl+Alt+F` | 禁用字符输入面板等误触入口 |
| `Cmd+W` | 禁用默认"关闭窗口"（改为 vim 的退出保存逻辑，见 3.4） |

### 3.2 kitty：标签页与窗口管理

| 快捷键 | 功能 |
|---|---|
| `Cmd+Alt+1 ~ 9` | 跳转到第 1~9 号标签页 |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | 切换到下一个 / 上一个标签页 |
| `Ctrl+Shift+T` | **以当前目录新建标签页** |
| `Ctrl+Shift+N` | 新建操作系统级窗口 |
| `F5` | 上下分屏（horizontal split） |
| `F6` | 左右分屏（vertical split） |
| `F4` | 智能分屏（宽则左右、高则上下） |
| `F7` | 旋转当前分栏轴（水平 ↔ 垂直） |
| `Ctrl+Shift+H/J/K/L` | 移动焦点到**左/下/上/右**相邻窗口（Vim 风格） |
| `Ctrl+Shift+Z` | 切换为堆叠（stack）布局 |
| `Cmd+Enter` | 最大化/还原当前窗口 |
| `Ctrl+Shift+F` | **打开回滚缓冲区**（终端历史输出在 less 中搜索浏览） |

### 3.3 tmux 透传（发送 Ctrl+A 前缀 + 子键）

> 原理：组合键被 kitty 捕获后，向终端发送 `Ctrl+A`（tmux 前缀）再发送对应键，实现 kitty 按键直接操作 tmux。

| 快捷键 | 发送到 tmux | 功能 |
|---|---|---|
| `Cmd+Shift+W` | `Ctrl+A` + `w` | tmux 拆离当前会话（detach） |
| `Cmd+Z` | `Ctrl+A` + `z` | 当前窗格全屏/还原（zoom） |
| `Cmd+Shift+H` | `Ctrl+A` + `Space` | 循环切换窗格布局 |
| `Cmd+1 ~ 9` | `Ctrl+A` + `1~9` | 切换到 tmux 窗口 1~9 |

### 3.4 vim / Neovim 快捷键（发送文本命令到编辑器）

> 原理：`send_text all` 直接把按键序列发送给所有窗格中的编辑器（Esc 退出插入模式后执行命令）。

| 快捷键 | 发送内容 | 功能 |
|---|---|---|
| `Cmd+S` | `Esc :w ⏎` | **保存当前文件** |
| `Cmd+W` | `Esc :q ⏎` | **退出 Neovim**（覆盖 kitty 默认关窗） |
| `Cmd+P` | `:lua Snacks.picker.smart()⏎` | **智能模糊查找文件**（Snacks.nvim 插件） |
| `Cmd+O` | `:lua Snacks.picker.lsp_workspace_symbols()⏎` | 查找 **LSP 工作区符号**（函数/类等） |

### 3.5 文本选取（kitten hints）

| 快捷键 | 功能 |
|---|---|
| `Ctrl+Shift+P` | 高亮屏幕上的**路径类文本**，选中后复制到剪贴板 |
| `Ctrl+Shift+O` | 高亮路径，选中后在 **tmux 浮窗中用 nvim 打开**（浮窗 60%×50% 居中，退出自动关闭） |
| `Ctrl+Shift+D` | 运行自定义脚本 `custom_match.py` 匹配 `KEY: xxx value;` 格式的文本（提取 value），输出到 stdout |

### 3.6 自定义

| 快捷键 | 功能 |
|---|---|
| `Cmd+;` | 发送右箭头键（等效 `→`） |
| `Cmd+K` | 输入 `clear` 并回车（命令行清屏） |
| `Ctrl+Shift+M` | 切换日志标记高亮（见 2.7） |

---

## 四、常规高频使用技巧

### 4.1 基础操作

| 操作 | 快捷键 |
|---|---|
| 复制 | 鼠标选中即自动复制（`copy_on_select`） |
| 粘贴 | `Cmd+V`（终端内） |
| 字体放大/缩小 | `Cmd+=` / `Cmd+-`，重置 `Cmd+0` |
| 全屏 | `Ctrl+Cmd+F` |
| 查找当前屏文本 | `Ctrl+Shift+F`（less 中 `/` 搜索、`q` 退出） |
| 滚动查看历史 | 滚轮（逐像素平滑）或 `Shift+PageUp/PageDown` |

### 4.2 多任务管理

- **分屏**：`F5` 上下、`F6` 左右、`F4` 智能分屏；`F7` 旋转分栏轴；`Ctrl+Shift+H/J/K/L` 在窗格间移动焦点
- **标签页**：`Ctrl+Shift+T` 在当前目录新建；`Cmd+Alt+1~9` 直达指定标签；`Ctrl+Tab` 循环切换
- **堆叠布局**：`Ctrl+Shift+Z` 切换 stack 布局（多个窗口叠放，适合聚焦单个）
- **最大化**：`Cmd+Enter`

### 4.3 与 vim/nvim 配合

- 编辑文件时 `Cmd+S` 保存、`Cmd+W` 退出、`Cmd+P` 找文件、`Cmd+O` 找符号——**全程不用碰键盘模式切换**
- `Ctrl+Shift+O`：屏幕上有文件路径时，高亮选择后直接在 nvim 中打开（配 tmux 浮窗）
- 若同时开着 kitty 多窗格，`send_text all` 会向所有窗格发送（保存/退出对多个文件同时生效）

### 4.4 日志/输出高亮

- 查看日志时按 `Ctrl+Shift+M`：自动高亮 INFO（蓝）/WARNING（黄）/ERROR/FATAL（粉红）关键字，快速定位问题

### 4.5 远程会话

- `Ctrl+Shift+O/P` 等 hints 功能在 SSH 会话中同样可用（kitty 会传递关键转义序列）
- `--allow-fallback=shifted,ascii`（`Ctrl+Shift+F`）保证远程按键编码不精确时依然生效

### 4.6 配置生效

- 修改配置后 **`Ctrl+Shift+F5`** 重载（无需重启）
- 或 `kitty @ reload-config`

---

## 五、主题与字体

### 5.1 当前主题

- **生效主题**：`dracula.conf`（Dracula 配色，前景 `#f8f8f2` / 背景 `#282a36` / 亮粉光标 `#FF79C6`）
- **标签栏固定为 Catppuccin-Mocha 风格**（kitty.conf 中手动覆盖：激活标签薰衣草紫 `#CBA6F7`）
- `current-theme.conf` 是 Catppuccin-Mocha 主题存档（kitty 主题切换工具保留）

**换主题方法**：编辑 `kitty.conf` 中 `BEGIN_KITTY_THEME` 与 `END_KITTY_THEME` 之间的 `include` 行，指向新的主题文件即可。

### 5.2 字体

- **主字体**：Maple Mono NF CN（等宽 + 中文字形 + Nerd Font 图标三合一），启用 OpenType 特性 `cv01`（圆点/字形变体）与 `calt`（连字）
- **备选字体**：`fonts/` 目录下还准备了 JetBrains Mono、Fira Code、Hack、Iosevka、Caskaydia、Source Code Pro、Berkley 等配置文件，切换方法：把 `kitty.conf` 的 `include fonts/maplemono.conf` 换成对应文件

### 5.3 图标显示

- Nerd Font 图标通过 `symbol_map` 映射到 `Symbols Nerd Font Mono` 渲染（覆盖 Font Awesome、Material、Powerline、Octicons 等区段）
- 终端内提示符（starship）、状态栏图标若显示为方块，通常是字体缺字形，需确认所用字体带 Nerd Font 补丁

---

## 六、常见问题排查

| 现象 | 原因 | 解决 |
|---|---|---|
| 终端标题不跟随目录/命令 | kitty shell integration 与自定义 ZDOTDIR 冲突 | kitty.conf 已设 `no-rc`；zsh 侧在 `prompt.zsh` 手动加载官方 `kitty-integration` 脚本 |
| 光标形状不随 vi 模式变化 | shell integration 的 no-cursor 已禁用 | 由 zsh-vi-mode 管理光标（`ZVM_*_CURSOR` 变量） |
| 选中不复制 | `copy_on_select` 失效 | 确认配置生效（`Ctrl+Shift+F5` 重载）；检查是否在远程/特殊模式 |
| 终端图标显示方块 | 字体缺 Nerd Font 字形 | 换用带 NF 的等宽字体（Maple Mono NF CN 已覆盖） |
| 背景不透明 | `background_opacity` 为 1.0 或系统限制 | 检查透明度与 `background_blur`；macOS 需系统设置允许 |
| 快捷键无反应 | 可能被 unmap 或与系统快捷键冲突 | 对照 `mappings.conf` 的 no_op 列表；查 `kitty --debug-config` 确认最终键位 |
| tmux 快捷键无效 | tmux 前缀不是 `Ctrl+A` | 本配置假定 tmux prefix = `Ctrl+A`（在 `~/.tmux.conf` 设置 `set -g prefix C-a`） |
