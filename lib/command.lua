--[[ Command Lib - Docs:
The command library contains the chat command handling of the bot

command.Add(string: command, function: cb_func)
	Adds a chat command which can be called via !<command>.
	The callback function gets 2 arguments:
		- msg: The message table of the message which triggered the command
		- args[]: An array of arguments passed to the command
	
command.Remove(string: command)
	Removes a chat command. The chat command will be unknown after removing it.
	
command.Call(string: command, table: msg, table: args)
	Calls a chat command from inside lua.
]]

command = {} -- Table containing the commmand library
local chatCommands = {} -- chatCommands[command] = function of command

function command.Add(command, func)
	chatCommands[command] = func
end

function command.Remove(command)
	chatCommands[command] = nil
end

function command.Call(command, msg, args)
	chatCommands[command](msg, args)
end

local function handleMessage(msg)
	if(msg.text ~= nil) then -- If there is actually text
		if(string.sub(msg.text,1,1) == "!") then -- If it starts like a command
			local args = {}
			for subStr in string.gmatch(string.sub(msg.text,2),"%S+") do table.insert(args, subStr) end -- Split message by spaces and remove command sign
			local command = args[1]
			table.remove(args, 1) -- Remove first element of arguments because it's the command itself
		
			if(chatCommands[command] ~= nil) then -- If command exists
				chatCommands[command](msg, args) -- Call command with msg and arguments
				deleteMessage(msg.channel.id, msg.id) -- Remove command message
			else
				sendMessage(msg.channel.id, "[INFO] Unknown command.")
			end
		end
	end
end

hook.Add("onMessageReceived", "messageHandler", handleMessage) -- Register message handler