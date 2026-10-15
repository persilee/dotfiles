# Hammerspoon 配置说明

> 本项目的 Hammerspoon 配置，实现 **键盘驱动的窗口管理与应用快速切换**。
> 核心思路：通过自定义修饰键组合（Hyper / Super），不碰鼠标就能完成窗口分屏、调整大小、跨屏移动、应用切换等操作。

---

## 一、项目结构

```
~/.hammerspoon/
├── init.lua                  # 入口：全局设置 + 加载全部模块
├── .luarc.json               # Lua 语言服务器配置（编辑器诊断用，声明 hs 等全局变量）
├── config/                   # 配置中心（改键位、改应用、改样式都在这）
│   ├── keys.lua              # 修饰键组合定义
│   ├── apps.lua              # 应用切换热键表
│   ├── windows.lua           # 窗口操作热键表
│   └── highlight.lua         # 窗口高亮样式配置
├── modules/                  # 功能实现
│   ├── window/
│   │   ├── init.lua          # 窗口焦点追踪（记录上一个窗口）
│   │   ├── position.lua      # 窗口定位（半屏 / 四分之一 / 九宫格）
│   │   ├── resize.lua        # 窗口缩放（居中/最大化/放大/缩小）
│   │   ├── split.lua         # 双窗口分屏与边界调整
│   │   ├── multiscreen.lua   # 跨屏移动
│   │   └── layout.lua        # 自动布局（网格/横排/竖排，当前未启用）
│   ├── app.lua               # 应用快速切换
│   ├── screen.lua            # 系统控制（重载配置 / 台前调度）
│   ├── time.lua              # 日期时间显示
│   ├── countdown.lua         # 倒计时提醒
│   └── highlight.lua         # 聚焦窗口高亮边框
├── utils/
│   └── helper.lua            # 工具函数（竖屏判断、鼠标定位、台前调度检测等）
└── Spoons/
    └── PaperWM.spoon         # 第三方可滚动平铺窗口管理器（已下载，未启用）
```

---

## 二、修饰键体系

| 名称      | 组合                       | 说明                                 |
| --------- | -------------------------- | ------------------------------------ |
| **Hyper** | `Shift + Alt + Ctrl`       | 绝大多数快捷键的基础前缀             |
| **Super** | `Shift + Alt + Cmd + Ctrl` | 仅用于重载配置（更高级别，防止误触） |

> 修改位置：`config/keys.lua`

---

## 三、功能详解

### 1. 应用快速切换（Hyper + 字母）

按下即切换到对应应用；**如果该应用已在前台，会循环切换到它的下一个窗口**；应用未启动则自动启动。切换后鼠标会自动定位到当前屏幕内相对位置 (40, 60)。

| 快捷键    | 应用               |     | 快捷键    | 应用             |
| --------- | ------------------ | --- | --------- | ---------------- |
| `Hyper+V` | 微信 WeChat        |     | `Hyper+T` | Kitty 终端       |
| `Hyper+G` | QQ                 |     | `Hyper+P` | iPhone Mirroring |
| `Hyper+B` | Arc 浏览器         |     | `Hyper+;` | Telegram         |
| `Hyper+Y` | Discord            |     | `Hyper+N` | Xcode            |
| `Hyper+R` | Rust Redis Desktop |     | `Hyper+,` | Codex            |
| `Hyper+O` | Apifox             |     | `Hyper+'` | ChatGPT          |

> 配置位置：`config/apps.lua`（添加应用 = 在该表中新增一行）。
> 备注：`IntelliJ IDEA` 条目已被注释，如需使用取消注释即可。
> 实现细节：应用 Bundle ID 通过 `osascript` 解析并缓存，找不到的应用会打印警告。

### 2. 窗口定位（Hyper + 方向键）

将当前聚焦窗口摆放到屏幕指定位置：

| 快捷键                | 功能                                 | 快捷键        | 功能     |
| --------------------- | ------------------------------------ | ------------- | -------- |
| `Hyper+left`          | 左半屏                               | `Super+left`  | 左上 1/4 |
| `Hyper+right`         | 右半屏                               | `Super+right` | 右上 1/4 |
| `Hyper+up`            | 上半屏                               | `Super+up`    | 左下 1/4 |
| `Hyper+down`          | 下半屏                               | `Super+down`  | 右下 1/4 |
| `Hyper+1` ~ `Hyper+9` | 九宫格位置（3×3 网格，数字对应格子） |               |          |

> 配置位置：`config/windows.lua` 中 `left/right/up/down`、`top_left/top_right/left_bottom/right_bottom`、`one~nine` 字段。

### 3. 窗口缩放（Hyper + 符号键）

| 快捷键    | 功能                                                                                                                                            |
| --------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `Hyper+C` | **居中 / 最大化 切换**：非最大化时最大化；已是最大化时缩小到屏幕中央 50%。若开启了「台前调度 (Stage Manager)」，最大化时自动让出左侧 170px 侧栏 |
| `Hyper+=` | **放大**：窗口四边各扩大 40px（按住可连续放大，不超出屏幕）                                                                                     |
| `Hyper+-` | **缩小**：窗口四边各缩小 40px（按住可连续缩小）                                                                                                 |

> 配置位置：`config/windows.lua` 中 `center_or_fullscreen / zoom / narrow` 字段。

### 4. 双窗口分屏（Hyper + 符号键）

基于**当前窗口与上一次聚焦的窗口**进行分屏（即"最后两个用过的窗口"）：

| 快捷键    | 功能                                                              |
| --------- | ----------------------------------------------------------------- |
| `Hyper+\` | 最后两个窗口**左右分屏**，各占半屏；再按一次**左右互换**          |
| `Hyper+/` | 最后两个窗口**上下分屏**，各占半屏；再按一次**上下互换**          |
| `Hyper+[` | **缩小**分屏边界（步长为屏幕短边的 5%，最小窗口为屏幕短边的 25%） |
| `Hyper+]` | **扩大**分屏边界                                                  |

> 前提：需先通过定位快捷键（如 Hyper+A / Hyper+D）把两个窗口摆成并排状态，才能用 `[` / `]` 调整边界；未检测到分屏窗口时会提示 "No split window found"。
> 实现依赖 `modules/window/init.lua` 的窗口焦点追踪（自动记录上一次聚焦的窗口）。

### 5. 跨屏移动（Super + Return）

`Super+N`：将当前窗口移动到**下一台显示器**，保持原有相对位置与大小；若窗口原本是最大化的，在新屏幕也保持最大化，鼠标跟随移动。

`Super+Return`：将当前窗口移动到**下一台显示器** 并且最大化显示窗口。

### 6. 系统控制（Super / Hyper）

| 快捷键    | 功能                                                                                       |
| --------- | ------------------------------------------------------------------------------------------ |
| `Super+R` | **重载配置**（修改配置文件后无需重启 Hammerspoon；屏幕上显示 "Configuration Reload" 提示） |
| `Hyper+.` | **切换「台前调度」Stage Manager** 开关（通过读写系统 `com.apple.WindowManager` 偏好实现）  |

### 7. 日期时间显示（Hyper + Space）

`Hyper+Space`：在屏幕中央弹出当前日期与时间（英文星期、年月日、12 小时制时分秒）。

### 8. 倒计时提醒（控制台调用）

`modules/countdown.lua` 提供三个函数，**当前未绑定热键**，需通过 Hammerspoon 控制台调用：

```lua
local countdown = require("modules.countdown")

countdown.startRemindTimer()   -- 弹出输入框，输入倒计时时长
countdown.stopRemindTimer()    -- 取消当前倒计时
countdown.getRemainTime()      -- 查看剩余时间
```

- 时间格式：`5s`、`10m`、`1h`、`1h3m4s`（s=秒，m=分钟，h=小时，可组合），默认值 `20m`
- 时间到：屏幕提示 "Time is up!" 5 秒 + 播放系统音效 "Glass"
- 取消 / 无计时器时会发送系统通知

### 9. 聚焦窗口高亮（默认关闭）

聚焦窗口时自动在窗口四周绘制**呼吸发光边框**（青色：主边框 4px、外圈光晕 12px），用于在众多窗口间快速定位当前焦点。效果流程：淡入（0.1s）→ 稳定（0.25s）→ 呼吸（透明度 0.7~1.0 循环）→ 淡出（0.15s）。窗口移动时边框实时跟随。

- **当前默认关闭**（`config/highlight.lua` 中 `enabled = false`）
- 开启方式：
  1. 修改 `config/highlight.lua` 中 `enabled = true`，然后 `Super+R` 重载；或
  2. 控制台调用 `require("modules.highlight").toggle()`
- 排除应用：Hammerspoon 自身（`excludedApps`），非标准窗口不生效
- 样式调整：颜色 / 边框宽度 / 圆角 / 时长全部在 `config/highlight.lua`

### 10. 自动布局（当前未启用）

`modules/window/layout.lua` 支持三种一键布局：

| 模式          | 效果                                                                 |
| ------------- | -------------------------------------------------------------------- |
| **GRID**      | 按窗口数量自动选择网格：1 / 2 / 4 / 6 / 9 / 12 / 16 格预置布局       |
| **横向/竖向** | 横屏显示器时窗口竖向等分排列（左右分列）；竖屏显示器时横向等分行排列 |

作用范围有两种：同一应用的全部可见窗口（`same_application`），或当前 Space 内全部窗口（`same_space`）。竖屏（屏幕旋转 90°/270°）时自动交换行列。

> **注意：目前 `config/windows.lua` 中对应的三个键位均为 `nil`（禁用状态）**，如需启用，需在配置中绑定快捷键，例如：
>
> ```lua
> M.same_space_auto_layout_grid = { prefix = keys.hyper, key = "G", message = "Auto Grid Layout" }
> ```

### 11. PaperWM.spoon（已下载，未启用）

`Spoons/PaperWM.spoon` 是第三方**可滚动平铺窗口管理器**（受 Linux PaperWM 启发，窗口像纸带一样横向排列滚动）。目前只是克隆在本地，`init.lua` 并未加载，**不生效**。

如需启用：

1. 系统设置 → 桌面与程序坞 → 调度中心：取消勾选「基于最近使用情况自动重新排列空间」，勾选「显示器具有单独的空间」
2. 在 `init.lua` 中加载并绑定热键：

```lua
PaperWM = hs.loadSpoon("PaperWM")
PaperWM:bindHotkeys({
    focus_left = {{"alt", "cmd"}, "left"},
    focus_right = {{"alt", "cmd"}, "right"},
    -- ... 更多键位见 Spoons/PaperWM.spoon/README.md
})
```

---

## 四、使用与维护指南

### 快速上手

1. 启动 Hammerspoon（顶部菜单栏出现 Hammerspoon 图标）
2. 直接按 `Hyper + 字母/符号` 即可使用各功能（Hyper = `Shift + Alt + Ctrl`）
3. 常用示例：
   - 微信窗口在前台时按 `Hyper+V` → 循环切换微信的多个窗口
   - `Hyper+A` → 当前窗口贴左半屏；`Hyper+\` → 最后两个窗口左右分屏
   - `Hyper+S` → 最大化 / 居中切换
   - 双屏用户 `Hyper+Return` → 窗口移到另一块屏幕

### 修改配置

| 想改什么                  | 改哪里                 |
| ------------------------- | ---------------------- |
| 全局修饰键（Hyper/Super） | `config/keys.lua`      |
| 应用切换键位 / 新增应用   | `config/apps.lua`      |
| 窗口定位、缩放、分屏键位  | `config/windows.lua`   |
| 高亮颜色、宽度、时长      | `config/highlight.lua` |
| 各功能行为逻辑            | `modules/` 下对应文件  |

改完执行 `Super+R` 重载，或点击菜单栏 Hammerspoon 图标 → Reload Config。

### 常见问题

- **快捷键无效**：确认 Hammerspoon 已运行，且未与其他软件（输入法、系统快捷键）冲突；改键后记得重载配置。
- **窗口分屏不生效**：分屏依赖"上一次聚焦的窗口"，请先分别聚焦两个目标窗口；调整边界前需先让两窗口处于并排/上下拼合状态。
- **找不到应用 Bundle ID**：控制台会打印 `[app.lua] Warning: Cannot find bundleId for app 'xxx'`，检查 `config/apps.lua` 中应用名是否与系统显示名称一致。

---

_文档生成时间：2026-09-21_
