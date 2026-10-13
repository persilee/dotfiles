local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

config.term = "xterm-256color"

config.use_cap_height_to_scale_fallback_fonts = true
config.font = wezterm.font_with_fallback({
	{ family = "Fira Code", weight = "Regular" },
	{ family = "HarmonyOS Sans SC", weight = "Regular" },
	{ family = "Apple Color Emoji", weight = "Regular" },
	{ family = "Noto Color Emoji", weight = "Regular" },
	{ family = "Symbols Nerd Font Mono", weight = "Regular", scale = 0.80 },
	-- { family = "Sarasa Term SC Nerd", weight = "Regular" },
	-- { family = "SF Pro", weight = "Regular" },
})

config.font_size = 14
config.line_height = 1.3
-- 连字核心配置
config.harfbuzz_features = {
	"liga=1", -- 标准连字：基础的 fi、fl、=> 等
	"clig=1", -- 上下文连字：===、!== 等多字符组合
	"calt=1", -- 上下文替换：根据相邻字符自动调整字形
	-- 可选：字体专属风格集（依字体不同支持不同）
	"zero", -- 数字 0 用斜线替代圆点（Fira Code / JetBrains Mono 支持）
	"ss01", -- 风格集 1，不同字体效果不同
}

-- Tabs
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false

config.window_decorations = "RESIZE | MACOS_FORCE_SQUARE_CORNERS"

local C = {
	bg = "#282A36",
	bg_light = "#343746",
	bg_lighter = "#424450",
	bg_dark = "#21222C",
	bg_darker = "#191A21",
	blue = "#8aadf4",
	sapphire = "#7dc4e4",
	sky = "#91d7e3",
	teal = "#8bd5ca",
	grren = "#a6da95",
	yellow = "#eed49f",
	white = "#ffffff",
	ice_white = "#f0f8ff",
	mint_cream = "#f5fffa",
	red = "#ed8796",
	pink = "#f5bde6",
}
local border_color = C.ice_white
config.color_scheme = "Dracula"
config.colors = {
	split = border_color,
	foreground = C.mint_cream,
	background = C.bg_darker,
	-- 光标颜色配置
	cursor_bg = "#FF79C6", -- 块光标填充色
	cursor_fg = "#1e1e2e", -- 光标处文字颜色（和背景一致，实现反色）
	cursor_border = "#FF79C6", -- 光标边框/竖线颜色
	tab_bar = {
		background = "rgba(25, 26, 33, 0.5)",
		active_tab = {
			bg_color = "#cba6f7",
			fg_color = "rgba(12%, 12%, 18%, 0%)",
			intensity = "Bold",
		},
		inactive_tab = {
			fg_color = "#cba6f7",
			bg_color = "rgba(12%, 12%, 18%, 90%)",
			intensity = "Normal",
		},
		inactive_tab_hover = {
			fg_color = "#cba6f7",
			bg_color = "rgba(27%, 28%, 35%, 90%)",
			intensity = "Bold",
		},
		new_tab = {
			fg_color = "#808080",
			bg_color = "#1e1e2e",
		},
	},
}

-- config.window_frame = {
-- 	border_left_width = "0.25cell",
-- 	border_right_width = "0.25cell",
-- 	border_bottom_height = "0.125cell",
-- 	border_top_height = "0.125cell",
-- 	border_left_color = border_color,
-- 	border_right_color = border_color,
-- 	border_bottom_color = border_color,
-- 	border_top_color = border_color,
-- 	active_titlebar_bg = "none", -- 激活窗口的标题栏背景透明
-- 	inactive_titlebar_bg = "none", -- 未激活窗口的标题栏背景透明
-- }

-- 可选：禁用强制反转光标，让应用程序完全控制颜色
config.force_reverse_video_cursor = false

config.window_background_opacity = 0.5
config.macos_window_background_blur = 36

config.adjust_window_size_when_changing_font_size = false

config.key_tables = {
	resize_pane = {
		{ key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
		{ key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },
		{ key = "Escape", action = "PopKeyTable" },
	},
}
config.leader = { key = "z", mods = "CTRL", timeout_milliseconds = 1500 }
config.keys = {
	-- Command + \：垂直左右分屏
	{
		key = "\\",
		mods = "SUPER",
		action = wezterm.action.SplitVertical({}),
	},
	-- Command + Shift + \：水平上下分屏
	{
		key = "\\",
		mods = "SUPER|SHIFT",
		action = wezterm.action.SplitHorizontal({}),
	},
	-- Command + W：关闭当前窗格
	{
		key = "w",
		mods = "SUPER",
		action = wezterm.action.CloseCurrentPane({ confirm = false }),
	},
	-- Command + Enter：最大化/还原当前窗格
	{
		key = "Enter",
		mods = "SUPER",
		action = wezterm.action.TogglePaneZoomState,
	},
	-- Command + 方向键：切换相邻窗格
	{
		key = "LeftArrow",
		mods = "SUPER",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		key = "RightArrow",
		mods = "SUPER",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
	{
		key = "UpArrow",
		mods = "SUPER",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		key = "DownArrow",
		mods = "SUPER",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	-- Command + ; 等效按一次右箭头
	{
		mods = "SUPER",
		key = ";",
		action = wezterm.action.SendKey({
			key = "RightArrow",
		}),
	},
	{ key = "|", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "\\", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "r", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },
	{ key = "s", mods = "LEADER", action = act.PaneSelect({ mode = "SwapWithActive" }) },
	{ key = "b", mods = "LEADER", action = act.PaneSelect },
	{ key = " ", mods = "LEADER", action = act.TogglePaneZoomState },
	{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
	{
		key = "k",
		mods = "SUPER", -- SUPER 对应 macOS 的 Command (⌘) 键
		action = wezterm.action.SendString("clear\r"),
	},
	{
		key = "w",
		-- SHIFT=Shift，CTRL=Ctrl，META=Option（macOS）
		mods = "SHIFT|CTRL|META",
		-- 原样将组合键发送到终端内部
		action = act.SendKey({ key = "w", mods = "SHIFT|CTRL|META" }),
	},
}

return config
