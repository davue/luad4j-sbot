--[[ Core Lib - Docs:
This library contains core functions of the bot

core.isAdmin(table: msg)
	Returns whether a user is admin or not
]]

core = {}	-- Table containing core library
local admins = {"163605020271575041"} -- Dave-it

function core.isAdmin(msg)
	for k, v in pairs(admin) do
		if (msg.author.id == v) then
			return true
		end
	end
	
	return false
end