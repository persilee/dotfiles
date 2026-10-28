local M = {}

-- 总开关
M.enabled = true

-- 应用名 → 输入法 ID（切到该应用时自动切换）
-- 常用 ID：
--   英文 ABC: com.apple.keyboardlayout.ABC
--   简体拼音: moe.bemly.inputmethod.AfmIME.afmpinyin.hans
-- 编码 / 终端类 → 英文
M.appInputSources = {
	["Xcode"] = "com.apple.keylayout.ABC",
	["Codex"] = "com.apple.keylayout.ABC",
	["kitty"] = "com.apple.keylayout.ABC",
	["tmux"] = "com.apple.keylayout.ABC",
	["Apifox"] = "com.apple.keylayout.ABC",
	["Finder"] = "com.apple.keylayout.ABC",
	["Ghostty"] = "com.apple.keylayout.ABC",
	["WezTerm"] = "com.apple.keylayout.ABC",
	["Code"] = "com.apple.keylayout.ABC",
	["Raycast"] = "com.apple.keylayout.ABC",

	-- 聊天类 → 中文（AfmIME，你当前在用的；想用微信输入法就换 ID）
	["WeChat"] = "moe.bemly.inputmethod.AfmIME.afmpinyin.hans",
	["QQ"] = "moe.bemly.inputmethod.AfmIME.afmpinyin.hans",
	["豆包"] = "moe.bemly.inputmethod.AfmIME.afmpinyin.hans",
	["Arc"] = "moe.bemly.inputmethod.AfmIME.afmpinyin.hans",
}

-- 未在上表注册的应用，切到这个输入法；
-- 设为 nil 表示"保持当前输入法，不切换"
M.defaultInputSource = "moe.bemly.inputmethod.AfmIME.afmpinyin.hans"

return M
