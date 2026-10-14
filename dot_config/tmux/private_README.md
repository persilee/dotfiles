# ~/.config/tmux —— tmux 配置说明

> 本 README 基于当前 `~/.config/tmux/` 下的配置文件整理，说明这套 tmux 配置的**工作原理**、**依赖插件**、**每个配置的功能**与**常用技巧**。
> 官方文档：https://github.com/tmux/tmux/wiki

---

## 目录

1. [配置总览与工作原理](#一配置总览与工作原理)
2. [依赖清单](#二依赖清单)
3. [配置详解](#三配置详解)
4. [常用高频使用技巧](#四常用高频使用技巧)
5. [常见问题与注意事项](#五常见问题与注意事项)

---

## 一、配置总览与工作原理

### 文件结构

```
~/.config/tmux/
├── tmux.conf          # 主配置：终端颜色 / 全局设置 / 插件 / 主题 / 状态栏
├── tmux.reset.conf    # 键位绑定（前缀键后的操作键）
└── plugins/           # tpm 管理的插件 + 手动 clone 的插件
```

### 加载流程（工作原理）

```
启动 tmux
  └─ 读取 ~/.config/tmux/tmux.conf（tmux 默认搜索路径）
      ├─ 1. source-file tmux.reset.conf      → 加载全部自定义键位
      ├─ 2. 终端类型 / 真彩色 / CSI-u 扩展按键
      ├─ 3. 全局基础设置（前缀键 / 历史 / 剪贴板 / 鼠标 / vi 键位...）
      ├─ 4. 声明插件（@plugin 列表）+ run-shell 手动加载 vim-tmux-navigator
      ├─ 5. 插件参数（floax / sessionx / resurrect / continuum / catppuccin）
      └─ 6. run tpm → 安装/更新插件
             run-shell catppuccin.tmux → 生成状态栏
             设置状态栏半透明
```

### 核心设计

| 设计点              | 说明                                                                  |
| ------------------- | --------------------------------------------------------------------- |
| **前缀键 `Ctrl+A`** | 所有 tmux 操作的前置按键（默认是 Ctrl+B，这里改为 Ctrl+A）            |
| **Vim 风格键位**    | 窗格移动用 `hjkl`、复制模式用 vi 键位（`setw -g mode-keys vi`）       |
| **插件化**          | 通过 tpm 管理 12 个插件，功能模块化（主题/会话/复制/浮动窗口/持久化） |
| **会话持久化**      | tmux-resurrect + tmux-continuum：定时保存会话，重启自动恢复           |
| **与外部工具集成**  | fzf（模糊查找）、zoxide（目录记忆）、lazygit（Git TUI）               |
| **状态栏**          | catppuccin 主题，顶部显示（会话名 / 当前目录 / 时间）                 |

---

## 二、依赖清单

### 2.1 tmux 插件（tpm 管理 + 手动加载）

| 插件                        | 安装方式                   | 功能                                                                 |
| --------------------------- | -------------------------- | -------------------------------------------------------------------- |
| **tpm**（tmux-plugins/tpm） | 声明                       | tmux 插件管理器本身（安装/更新/卸载插件）                            |
| **tmux-sensible**           | 声明                       | 一组通用的默认优化（历史、绑定、行为修正）                           |
| **vim-tmux-navigator**      | **手动 clone + run-shell** | `Ctrl+h/j/k/l` 智能切换：窗格内是 vim 类程序则透传按键，否则切换窗格 |
| **tmux-yank**               | 声明                       | 复制文本到系统剪贴板（配合 macOS pbcopy）                            |
| **tmux-resurrect**          | 声明                       | 手动保存/恢复会话（窗格布局、pane 内容、nvim 会话）                  |
| **tmux-continuum**          | 声明                       | 定时自动保存 + 重启后自动恢复会话                                    |
| **tmux-thumbs**             | 声明                       | 屏幕文本快速复制（hints：按序号选中即复制）                          |
| **tmux-fzf**                | 声明                       | fzf 快速切换窗口/会话                                                |
| **tmux-fzf-url**            | 声明                       | 扫描历史命令中的 URL，fzf 选中后用浏览器打开                         |
| **catppuccin-tmux**         | **手动 clone + run-shell** | Catppuccin 主题状态栏（不在 tpm 目录时需手动加载）                   |
| **tmux-sessionx**           | 声明                       | 会话切换器（fzf + zoxide 智能排序常用目录）                          |
| **tmux-floax**              | 声明                       | 浮动窗口（scratchpad，一键弹出/收起）                                |

> 手动 clone 的插件目录：`~/.config/tmux/plugins/{vim-tmux-navigator, catppuccin-tmux}`；
> tpm 安装的插件默认在 `~/.tmux/plugins/`（配置里的 `run '~/.tmux/plugins/tpm/tpm'` 指向 tpm 本体）。

### 2.2 外部程序依赖

| 程序          | 用途                                              | 安装                   |
| ------------- | ------------------------------------------------- | ---------------------- |
| **fzf**       | sessionx / tmux-fzf / tmux-fzf-url 的模糊查找引擎 | `brew install fzf`     |
| **zoxide**    | sessionx 的目录频率记忆（`zoxide-mode on`）       | `brew install zoxide`  |
| **lazygit**   | 前缀 `g` 弹出 Git 终端界面                        | `brew install lazygit` |
| **Nerd Font** | 状态栏图标/分隔符正常显示                         | 如 Maple Mono NF CN    |
| **tmux**      | 本体                                              | `brew install tmux`    |

---

## 三、配置详解

### 3.1 tmux.conf —— 主配置

#### ① 终端与颜色

| 配置                             | 值                  | 功能                                                     |
| -------------------------------- | ------------------- | -------------------------------------------------------- |
| `default-terminal`               | `tmux-256color`     | 对内声明 tmux 原生终端类型，启用全部现代特性             |
| `terminal-overrides`             | `,*:Tc:RGB`         | 对**外部终端**追加真彩色能力（兼容 WezTerm/iTerm/Kitty） |
| `terminal-overrides`（服务器级） | `,*:Tc:RGB:extkeys` | 追加真彩色 + 扩展按键支持                                |

#### ② 扩展按键（CSI-u）

| 配置                   | 值              | 功能                                |
| ---------------------- | --------------- | ----------------------------------- |
| `extended-keys`        | `off`（窗口级） | 关闭扩展按键透传                    |
| `extended-keys-format` | `csi-u`         | 强制使用标准 CSI-u 格式输出按键序列 |

#### ③ 全局基础设置

| 配置                       | 值               | 功能                                 |
| -------------------------- | ---------------- | ------------------------------------ |
| `prefix`                   | `^A`             | 前缀键设为 **Ctrl+A**（默认 Ctrl+B） |
| `base-index`               | `1`              | 窗口编号从 1 开始（默认 0）          |
| `detach-on-destroy`        | `off`            | 关闭最后一个窗口时不退出 tmux        |
| `escape-time`              | `0`              | Esc 键零延迟（响应更快）             |
| `history-limit`            | `1000000`        | 回滚历史上限 100 万行（默认 2000）   |
| `renumber-windows`         | `on`             | 关闭任意窗口后自动重新编号           |
| `set-clipboard`            | `on`             | 复制写入系统剪贴板                   |
| `status-position`          | `top`            | 状态栏在顶部（macOS 风格）           |
| `default-terminal`         | `${TERM}`        | 默认终端类型跟随外部终端             |
| `mode-keys`                | `vi`             | 复制模式用 vi 键位                   |
| `mouse`                    | `on`             | 开启鼠标支持                         |
| `pane-active-border-style` | `fg=magenta`     | 活动窗格边框品红色                   |
| `pane-border-style`        | `fg=brightblack` | 普通窗格边框暗灰色                   |

#### ④ tmux-fzf-url

| 配置                     | 值                                                      | 功能                     |
| ------------------------ | ------------------------------------------------------- | ------------------------ |
| `@fzf-url-fzf-options`   | `-p 60%,30% --prompt="..." --border-label=" Open URL "` | fzf 弹出窗口的尺寸与外观 |
| `@fzf-url-history-limit` | `2000`                                                  | 扫描历史命令的条数上限   |

#### ⑤ 插件声明（见第二节依赖清单）

#### ⑥ tmux-floax（浮动窗口）

| 配置                             | 值            | 功能                           |
| -------------------------------- | ------------- | ------------------------------ |
| `@floax-width` / `@floax-height` | `80%` / `80%` | 浮动窗口尺寸                   |
| `@floax-border-color`            | `magenta`     | 浮动窗口边框品红               |
| `@floax-text-color`              | `blue`        | 浮动窗口标题文字蓝色           |
| `@floax-bind`                    | `p`           | **前缀 + p** 打开/关闭浮动窗口 |
| `@floax-change-path`             | `true`        | 打开时切换到当前 pane 所在路径 |

#### ⑦ tmux-sessionx（会话切换器）

| 配置                                    | 值                           | 功能                             |
| --------------------------------------- | ---------------------------- | -------------------------------- |
| `@sessionx-bind`                        | `o`                          | **前缀 + o** 打开会话选择器      |
| `@sessionx-bind-zo-new-window`          | `ctrl-y`                     | 选择器内 Ctrl+Y 新建窗口并切换   |
| `@sessionx-auto-accept`                 | `off`                        | 不自动接受首个匹配（需回车确认） |
| `@sessionx-x-path`                      | `~/dotfiles`                 | 选择器默认起始目录               |
| `@sessionx-window-width/height`         | `75%` / `85%`                | 选择器窗口尺寸                   |
| `@sessionx-zoxide-mode`                 | `on`                         | 集成 zoxide，按访问频率排序目录  |
| `@sessionx-custom-paths`                | `/Users/lishaoying/dotfiles` | 附加扫描路径                     |
| `@sessionx-custom-paths-subdirectories` | `false`                      | 不递归子目录                     |
| `@sessionx-filter-current`              | `false`                      | 结果中包含当前会话               |

#### ⑧ 会话持久化（resurrect / continuum）

| 配置                               | 值        | 功能                         |
| ---------------------------------- | --------- | ---------------------------- |
| `@resurrect-capture-pane-contents` | `on`      | 恢复时还原各 pane 的屏幕内容 |
| `@continuum-restore`               | `on`      | tmux 重启后自动恢复上次会话  |
| `@continuum-save-interval`         | `1`       | 每 1 分钟自动保存一次        |
| `@resurrect-strategy-nvim`         | `session` | nvim 恢复策略：按会话恢复    |

#### ⑨ catppuccin 主题

| 配置                                 | 值                               | 功能                                 |
| ------------------------------------ | -------------------------------- | ------------------------------------ |
| 窗口分隔符（left/middle/right）      | ` / █ /`                         | 窗口标签的分隔箭头（Nerd Font 图标） |
| `@catppuccin_window_number_position` | `right`                          | 窗口编号显示在右侧                   |
| `@catppuccin_window_default_fill`    | `number`                         | 普通窗口填充编号                     |
| `@catppuccin_window_default_text`    | `#W`                             | 普通窗口显示窗口名                   |
| `@catppuccin_window_current_text`    | `#W#{?window_zoomed_flag,(  ),}` | 当前窗口名 + 缩放标记                |
| `@catppuccin_status_modules_left`    | `session`                        | 状态栏左侧：会话名                   |
| `@catppuccin_status_modules_right`   | `directory`                      | 状态栏右侧：当前目录                 |
| `@catppuccin_directory_text`         | `#{b:pane_current_path}`         | 目录模块显示 pane 路径的 basename    |
| `@catppuccin_date_time_text`         | `%m-%d %H:%M`                    | 时间格式（当前未启用）               |

#### ⑩ 状态栏半透明

| 配置        | 值        | 功能                                                  |
| ----------- | --------- | ----------------------------------------------------- |
| `status-bg` | `default` | 状态栏背景跟随终端背景 → 配合终端半透明实现毛玻璃效果 |

### 3.2 tmux.reset.conf —— 键位全表

> 前缀键 = **Ctrl+A**。`-n` = 无需前缀直接按；`-r` = 可连续重复按。

#### 会话级

| 快捷键          | 功能                                 |
| --------------- | ------------------------------------ |
| `Ctrl+A Ctrl+X` | 锁定 tmux（需密码解锁）              |
| `Ctrl+A Ctrl+C` | 在 HOME 目录新建窗口（覆盖默认中断） |
| `Ctrl+A Ctrl+D` | 分离会话（回到 shell，会话保留）     |
| `Ctrl+A *`      | 列出客户端                           |
| `Ctrl+A S`      | 交互式选择会话                       |

#### 窗口

| 快捷键                  | 功能                                  |
| ----------------------- | ------------------------------------- |
| `Ctrl+A H` / `Ctrl+A L` | 上一个 / 下一个窗口                   |
| `Ctrl+A Ctrl+A`         | 切回最近使用的窗口                    |
| `Ctrl+A W` / `Ctrl+A w` | 列出所有窗口                          |
| `Ctrl+A r`              | 重命名当前窗口                        |
| `Option+Shift+←/→`      | 与左/右侧窗口交换位置并选中（无前缀） |

#### 窗格（分割 / 移动 / 缩放）

| 快捷键                  | 功能                                |
| ----------------------- | ----------------------------------- |
| `Ctrl+A \|`             | 水平分割（左右）                    |
| `Ctrl+A s` / `Ctrl+A v` | 垂直 / 水平分割，新窗格继承当前路径 |
| `Ctrl+A "`              | 交互式选择窗口                      |
| `Ctrl+A z`              | 当前窗格全屏 / 还原（zoom）         |
| `Ctrl+A h/j/k/l`        | 焦点移到左/下/上/右窗格（Vim 风格） |
| `Ctrl+A ,` / `.`        | 左/右增宽 20（可连续按）            |
| `Ctrl+A -` / `=`        | 下/上增高 7（可连续按）             |
| `Ctrl+A c`              | 关闭当前窗格                        |
| `Ctrl+A x`              | 与下方窗格交换位置                  |
| `Shift+↑/↓/←/→`         | 直接调整当前窗格 5 格（无前缀）     |

#### 复制 / 同步 / 其它

| 快捷键         | 功能                    |
| -------------- | ----------------------- |
| `Ctrl+A P`     | 切换窗格边框状态栏      |
| `Ctrl+A *`     | 所有窗格同步输入        |
| `Ctrl+A :`     | 进入 tmux 命令行        |
| `Ctrl+A R`     | 重新加载全部配置        |
| `Ctrl+A K`     | 清屏（等效输入 clear）  |
| 复制模式按 `v` | 开始选择文本（vi 键位） |

#### 插件快捷键

| 快捷键                       | 功能                                         |
| ---------------------------- | -------------------------------------------- |
| `Ctrl+A p`                   | 打开/关闭**浮动窗口**（floax）               |
| `Ctrl+A o`                   | 打开**会话选择器**（sessionx，fzf 模糊搜索） |
| `Ctrl+A g`                   | 当前路径弹出 **lazygit**                     |
| `Ctrl+A Space`（kitty 透传） | tmux 布局循环切换                            |
| `Ctrl+A w`（kitty 透传）     | tmux 拆离会话                                |
| `Ctrl+A z`（kitty 透传）     | 窗格全屏/还原                                |

---

## 四、常用高频使用技巧

### 4.1 基础操作

1. **启动/重进**：`tmux` 新建会话；`tmux attach` 重连上次会话；`tmux ls` 查看会话
2. **分离不退出**：`Ctrl+A Ctrl+D` —— 任务在后台继续跑，随时 `tmux attach` 回来
3. **重载配置**：改完配置文件按 `Ctrl+A R`（无需重启 tmux）
4. **清屏**：`Ctrl+A K`

### 4.2 窗格与窗口

- **快速分屏**：`Ctrl+A s`（上下）/ `Ctrl+A v`（左右）/ `Ctrl+A |`（左右）——新窗格自动继承当前目录
- **Vim 式移动**：`Ctrl+A h/j/k/l` 在窗格间跳转；装了 vim-tmux-navigator 后，**在 nvim 里按 Ctrl+h/j/k/l 也能跨窗格切换**（智能透传）
- **临时放大**：`Ctrl+A z` 全屏当前窗格，再按一次还原
- **窗口编号从 1 开始**：`Ctrl+A L/H` 或 `Ctrl+A 数字`（kitty 里 Cmd+1~9 透传）切换

### 4.3 会话持久化（推荐日常使用）

- **自动保存**：continuum 每 1 分钟自动保存（配置已开）
- **重启恢复**：电脑重启后 `tmux attach` 自动恢复上次的窗口/窗格/目录/nvim 会话
- **手动保存/恢复**：`Ctrl+A Ctrl+s`（resurrect 保存）、`Ctrl+A Ctrl+r`（恢复）——tpm 插件默认键位

### 4.4 文本复制

- **系统剪贴板**：`copy_on_select` + tmux-yank，在复制模式选中即复制到 macOS 剪贴板
- **快速复制屏幕文本**（tmux-thumbs）：在 pane 里按 `Ctrl+A Space` 或插件默认键（通常是 `Ctrl+A` 后再按 `Space` 外的绑定）→ 屏幕文本标序号 → 按序号即复制对应文本

### 4.5 会话切换与浮动窗口

- **切会话**：`Ctrl+A o` 打开 sessionx → 输入关键词模糊搜索 → 回车进入；常用目录会被 zoxide 排到前面
- **浮动窗口**：`Ctrl+A p` 弹出/收起浮动窗（适合临时跑命令、看手册）
- **Git 操作**：`Ctrl+A g` 弹出 lazygit

### 4.6 多窗格同步

- `Ctrl+A *` 开启/关闭同步输入：所有窗格同时执行同一命令（如批量安装、批量 git pull）

### 4.7 与 kitty 配合

- kitty 的 `Cmd+1~9`、`Cmd+Z`、`Cmd+Shift+H/W` 等会透传成 tmux 操作（见 kitty README 的 tmux 透传段）
- 建议统一前缀键：kitty 透传发的是 `Ctrl+A`，与本配置一致

---

## 五、常见问题与注意事项

| 现象                   | 原因 / 解决                                                                                          |
| ---------------------- | ---------------------------------------------------------------------------------------------------- |
| 状态栏图标显示方块     | 终端字体不是 Nerd Font（换 Maple Mono NF CN 等）                                                     |
| 新增插件不生效         | tpm 安装后需按 `Ctrl+A I`（安装插件）/ `Ctrl+A U`（更新）                                            |
| 会话恢复失败           | 确认 `@continuum-restore on`；首次恢复需 `tmux attach` 触发                                          |
| `Ctrl+A o` 找不到目录  | `@sessionx-custom-paths` 目前是插件作者的示例路径 `/Users/omerxx/dotfiles`，**建议改成你自己的目录** |
| 真彩色不生效           | 确认外部终端支持（kitty/WezTerm 均支持），检查 `terminal-overrides`                                  |
| 浮动窗口无边框         | floax 的 `@floax-border-color` 与主题色一致时可调整颜色值                                            |
| 旧版 `.tmux.conf` 冲突 | 本配置读取 `~/.config/tmux/`；如果 `~/.tmux.conf` 也存在，tmux 会合并加载，注意键位覆盖关系          |
