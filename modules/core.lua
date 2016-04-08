--[[ Core module - Docs:
This module provides the most basic set of functions.

ping
	A very simple function to check if the bot is responding.

lua (-x, -f) <cmd/filename>
	Runs a lua script either from given string or file.
	Admin-only command.
	FLAGS
	-x	return output
	-f	load file
	
sh <shellcmd>
	Runs a shell script from given command.
	Admin-only command.
	
ls
	Lists all available chat-commands
	
about
	Displays a short message naming the developers
]]

addCommand("ping", function(msg, args)
	sendMessage(msg.channel.id, "Pong!")
end)

addCommand("lua", function(msg, args)
	if(isAdmin(msg)) then
		if(#args > 0) then
			local luaCommand = string.sub(msg.text, 6)
			if(luaCommand ~= "") then
				func, errorStr = load(luaCommand)
				if (func ~= nil) then
					func()
				else
					sendMessage(msg.channel.id, "[ERROR] An error occured while running the script:\n"..errorStr)
				end
			end
		else
			sendMessage(msg.channel.id, "[INFO] Usage: lua <luascript>")
		end
	end
end)

addCommand("sh", function(msg, args)
	if(isAdmin(msg)) then
		if(#args > 0) then
			local output = tostring(os.capture(string.sub(msg.text,5), true))
			if(output ~= "") then
				sendMessage(msg.channel.id, output)
			else
				sendMessage(msg.channel.id, "[Empty]")
			end
		else
			sendMessage(msg.channel.id, "[INFO] Usage: sh <shellcmd>")
		end
	end
end)

addCommand("help", function(msg, args)
	local cmds = ""
	for key, value in pairs(chatCommands) do
		if key ~= "getuser" then
			cmds = cmds..key.."\n"
		end
	end
	sendMessage(msg.channel.id, "[INFO] Available commands:\n"..cmds)
end)