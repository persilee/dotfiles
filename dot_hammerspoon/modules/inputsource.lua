local config = require("config.inputsource")

local M = {}

local function switchInputSource(appName)
	if not config.enabled then
		return
	end
	local targetId = config.appInputSources[appName] or config.defaultInputSource
	if not targetId then
		return
	end

	local current = hs.keycodes.currentSourceID()
	if current == targetId then
		return
	end

	local ok = hs.keycodes.currentSourceID(targetId)
	if not ok then
		hs.printf("[inputsource] Failed to switch to: " .. tostring(targetId))
	end
end

hs.window.filter.default:subscribe(hs.window.filter.windowFocused, function(win)
	if not win then
		return
	end
	local app = win:application()
	if not app then
		return
	end
	switchInputSource(app:name())
end)

-- 工具：Super+f12 显示当前应用信息（填输入法映射表用）
local keys = require("config.keys")

hs.hotkey.bind(keys.super, "f12", "App Info", function()
	local win = hs.window.focusedWindow()
	if not win then
		hs.alert.show("No focused window")
		return
	end
	local app = win:application()
	if not app then
		hs.alert.show("No application")
		return
	end
	local name = app:name() or "?"
	local bundleID = app:bundleID() or "?"
	local title = win:title() or ""
	hs.pasteboard.setContents(name)
	hs.alert.show(
		string.format(
			"App: %s\nBundle ID: %s\nTitle: %s\n\n（应用名已复制到剪贴板）",
			name,
			bundleID,
			title
		),
		3
	)
end)

return M
