depends.onLib("core")
depends.onLib("command")

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

command.add("ping", function(msg, args)
	msg.getChannel().sendMessage("Pong!")
end)

command.add("lua", function(msg, args)
	if(core.isAdmin(msg)) then
		if(#args > 0) then
			local luaCommand = string.sub(msg.getContent(), 6)
			if(luaCommand ~= "") then
				func, errorStr = load(luaCommand)
				if (func ~= nil) then
					func()
				else
					msg.getChannel().sendMessage("[ERROR] An error occured while running the script:\n"..errorStr)
				end
			end
		else
			msg.getChannel().sendMessage("[INFO] Usage: lua <luascript>")
		end
	end
end)

command.add("sh", function(msg, args)
	if(core.isAdmin(msg)) then
		if(#args > 0) then
			local output = tostring(os.capture(string.sub(msg.getContent(),5), true))
			if(output ~= "") then
				msg.getChannel().sendMessage(output)
			else
				msg.getChannel().sendMessage("[Empty]")
			end
		else
			msg.getChannel().sendMessage("[INFO] Usage: sh <shellcmd>")
		end
	end
end)

command.add("help", function(msg, args)
	local cmds = ""
	for key, value in pairs(command.getTable()) do
		cmds = cmds..key.."\n"
	end
	msg.getChannel().sendMessage("[INFO] Available commands:\n"..cmds)
end)