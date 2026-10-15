local helper = require("utils.helper")
local config = require("config.windows")

local M = {}

local function moveToNextScreen(forceMaximize)
	local win = hs.window.focusedWindow()
	if not win then
		return
	end
	local screen = win:screen()
	local f = win:frame()
	local max = screen:frame()
	local isMax = f.w == max.w and f.h == max.h
	win:move(f:toUnitRect(screen:frame()), screen:next(), true, 0)
	if isMax or forceMaximize then
		win:maximize()
	end
	helper.setMousePos()
end

if config.switchNextScreen ~= nil then
	hs.hotkey.bind(
		config.switchNextScreen.prefix,
		config.switchNextScreen.key,
		config.switchNextScreen.message,
		function()
			moveToNextScreen(false)
		end
	)
end

if config.switchNextScreenMaximize ~= nil then
	hs.hotkey.bind(
		config.switchNextScreenMaximize.prefix,
		config.switchNextScreenMaximize.key,
		config.switchNextScreenMaximize.message,
		function()
			moveToNextScreen(true)
		end
	)
end

return M
