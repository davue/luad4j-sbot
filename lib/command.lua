depends.onLib("hook")

--[[ Command Lib - Docs:
The command library contains the chat command handling of the bot

command.add(string: command, function: cb_func)
	Adds a chat command which can be called via !<command>.
	The callback function gets 2 arguments:
		- msg: The message table of the message which triggered the command
		- args[]: An array of arguments passed to the command
	
command.remove(string: command)
	Removes a chat command. The chat command will be unknown after removing it.
	
command.call(string: command, table: msg, table: args)
	Calls a chat command from inside lua.
]]

command = {} -- Table containing the commmand library
local chatCommands = {} -- chatCommands[command] = function of command
--[[
Possible command structure:
command.add(command, description, function)

command.add("Tests:test string:arg1 number:arg2", "A test command", function(msg, args)
	...
end)

command table:
	chatCommands[command].call = function: func
	chatCommands[command].params = table: params
	chatCommands[command].desc = string: description
	
	chatCommands[command].call = function(msg, args) ... end
	chatCommands[command].params = {"string:arg1", "number:arg2"}
	chatCommands[command].desc = "A test command"
]]

function command.add(command, description, func)
	if(chatCommands[command] == nil) then
		-- TODO:
		-- 1. split command by spaces
		-- 2. check for category in 1. part
		-- 3. parse parameters
		beginIndex, endIndex, text = string.find(command, "(%w+):%w+%s")
		chatCommands[command] = {}
		chatCommands[command].call = func
		chatCommands[command].desc = description
		chatCommands[command].params = {}
		
		local temp = {}
		for subString in string.gmatch(command, "%S+") do
			table.insert(temp, subString)
		end
		table.remove(temp,1)
		
		return true
	else
		hook.call("LuaError", "Failed to add command: Command already exists")
		return false
	end
end

function command.remove(command)
	chatCommands[command] = nil
end

function command.getTable()
	return chatCommands
end

local function handleMessage(msg)
	text = msg.getContent()
	
	if(text ~= nil) then -- If there is actually text
		if(string.sub(text,1,1) == "!") then -- If it starts like a command
			local args = {}
			for subStr in string.gmatch(string.sub(text,2),"%S+") do table.insert(args, subStr) end -- Split message by spaces and remove command sign
			local command = args[1]
			table.remove(args, 1) -- Remove first element of arguments because it's the command itself
		
			if(chatCommands[command] ~= nil) then -- If command exists
				chatCommands[command](msg, args) -- Call command with msg and arguments
				--deleteMessage(msg.channel.id, msg.id) -- Remove command message
			else
				msg.getChannel().sendMessage("[INFO] Unknown command.")
			end
		end
	end
end

hook.add("onMessageReceived", "messageHandler", handleMessage) -- Register message handler