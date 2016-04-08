--[[ Core Lib - Docs:
This library contains core functions of the bot

core.isAdmin(table: msg)
	Returns whether a user is admin or not
]]

core = {}	-- Table containing core library
local admins = {"S-Bot Dev"} -- All roles with admin access

function core.isAdmin(msg)
	for k, aRole in pairs(admins) do
		local userRoles = getRoles(msg.author.id, msg.guild.id)
		for k, uRole in pairs(userRoles) do
			if(aRole == uRole.name) then
				return true
			end
		end
	end
	
	return false
end