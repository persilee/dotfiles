local helper = require("utils.helper")
local config = require("config.windows")

local M = {}

if config.center_or_fullscreen ~= nil then
	hs.hotkey.bind(
		config.center_or_fullscreen.prefix,
		config.center_or_fullscreen.key,
		config.center_or_fullscreen.message,
		function()
			local win = hs.window.focusedWindow()
			if not win then
				return
			end
			local f = win:frame()
			local screen = win:screen()
			local max = screen:frame()

			if helper.isStageManager() then
				local stageWidth = 170
				if f.w == max.w and f.h == max.h then
					f.x = max.x + stageWidth
					f.y = max.y
					f.w = max.w - stageWidth
					f.h = max.h
					win:setFrame(f)
				else
					win:maximize()
				end
			else
				if f.w == max.w and f.h == max.h then
					f.x = max.x + max.w / 4
					f.y = max.y + max.h / 4
					f.w = max.w / 2
					f.h = max.h / 2
					win:setFrame(f)
				else
					win:maximize()
				end
			end
		end
	)
end

if config.center ~= nil then
	hs.hotkey.bind(config.center.prefix, config.center.key, config.center.message, function()
		local win = hs.window.focusedWindow()
		if not win then
			return
		end
		local f = win:frame()
		local screen = win:screen()
		local max = screen:frame()
		f.x = max.x + (max.w - f.w) / 2
		f.y = max.y + (max.h - f.h) / 2
		win:setFrame(f)
	end)
end

local function zoomWindow()
	local win = hs.window.focusedWindow()
	if not win then
		return
	end
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	f.w = f.w + 40
	f.h = f.h + 40
	f.x = f.x - 20
	f.y = f.y - 20
	if f.x < max.x then
		f.x = max.x
	end
	if f.y < max.y then
		f.y = max.y
	end
	if f.w > max.w then
		f.w = max.w
	end
	if f.h > max.h then
		f.h = max.h
	end
	win:setFrame(f)
end

local function narrowWindow()
	local win = hs.window.focusedWindow()
	if not win then
		return
	end
	local f = win:frame()
	f.w = f.w - 40
	f.h = f.h - 40
	f.x = f.x + 20
	f.y = f.y + 20
	win:setFrame(f)
end

hs.hotkey.bind(config.zoom.prefix, config.zoom.key, config.zoom.message, zoomWindow, nil, zoomWindow)
hs.hotkey.bind(config.narrow.prefix, config.narrow.key, config.narrow.message, narrowWindow, nil, narrowWindow)

if config.center_cycle ~= nil then
	hs.hotkey.bind(config.center_cycle.prefix, config.center_cycle.key, config.center_cycle.message, function()
		local win = hs.window.focusedWindow()
		if not win then
			return
		end
		local screen = win:screen()
		local max = screen:frame()
		local f = win:frame()

		local SIZES = { 0.6, 0.7, 0.8 }
		local ratio = f.w / max.w
		local currentIndex = nil
		for i, size in ipairs(SIZES) do
			if math.abs(ratio - size) < 0.05 then
				currentIndex = i
				break
			end
		end

		local target = SIZES[1]
		if currentIndex then
			target = SIZES[currentIndex % #SIZES + 1]
		end

		local w = max.w * target
		local h = max.h * target
		f.x = max.x + (max.w - w) / 2
		f.y = max.y + (max.h - h) / 2
		f.w = w
		f.h = h
		win:setFrame(f)
		hs.alert.show("Center " .. math.floor(target * 100) .. "%")
	end)
end

local savedFrames = {}

if config.fake_fullscreen ~= nil then
	hs.hotkey.bind(config.fake_fullscreen.prefix, config.fake_fullscreen.key, config.fake_fullscreen.message, function()
		local win = hs.window.focusedWindow()
		if not win then
			return
		end
		local screen = win:screen()
		local max = screen:frame()
		local f = win:frame()
		local winId = win:id()

		local isFull = math.abs(f.w - max.w) < 2
			and math.abs(f.h - max.h) < 2
			and math.abs(f.x - max.x) < 2
			and math.abs(f.y - max.y) < 2

		if isFull and savedFrames[winId] then
			win:setFrame(savedFrames[winId])
			savedFrames[winId] = nil
		else
			savedFrames[winId] = f
			win:setFrame(max)
		end
	end)
end

return M
