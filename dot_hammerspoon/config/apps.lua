local keys = require("config.keys")

local M = {
	{ prefix = keys.hyper, key = "V", message = "WeChat", appName = "WeChat" },
	{ prefix = keys.hyper, key = "G", message = "QQ", appName = "QQ" },
	{ prefix = keys.hyper, key = "B", message = "Browser", appName = "Arc" },
	{ prefix = keys.hyper, key = "N", message = "Antinote", appName = "Antinote" },
	{ prefix = keys.hyper, key = "Y", message = "Discord", appName = "Discord" },
	{ prefix = keys.hyper, key = "R", message = "Redis Desktop Manager", appName = "Rust Redis Desktop" },
	{ prefix = keys.hyper, key = "O", message = "Apifox", appName = "Apifox" },
	{ prefix = keys.hyper, key = "T", message = "Terminal", appName = "WezTerm" },
	{ prefix = keys.hyper, key = ",", message = "Codex", appName = "Codex" },
	{ prefix = keys.hyper, key = "'", message = "ChatGPT", appName = "ChatGPT" },
	{ prefix = keys.hyper, key = "P", message = "iPhone Mirroring", appName = "iPhone Mirroring" },
}

return M
