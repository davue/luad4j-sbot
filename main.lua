chatCommands = {} -- chatCommands[command] = function of command
botName = "S-Bot"
installPath = "/home/pi/discord/lua"
defaultFilePath = installPath.."/main.lua"
libPath = installPath.."/lib/"
modulePath = installPath.."/modules/"
mainChannel = "165560868426219520" -- #stammbot-dev-channel @ Stammgruppe Afterbirth

local admins = {"163605020271575041"} -- Dave-it

-- Events
function onMessageReceived(msg)
	hook.Call("onMessageReceived", msg)
end

function onLuaError(reason)
	sendMessage(mainChannel, "An error occured while running the script:\n"..reason)
end

function onPortData(data)
	sendMessage(mainChannel, data)
end

-- Core functions
function addCommand(command, func)
	chatCommands[command] = func
end

-- Checks if sender is admin
function isAdmin(msg)
	for k, v in pairs(admins) do
		if(msg.author.id == v) then
			return true
		end
	end
	sendMessage(msg.channel.id, "Admin-Only Command")
	return false
end

function handleMessage(msg)
	if(msg.text ~= nil) then -- if there is actually text
		if(string.sub(msg.text,1,1) == "!") then -- if it starts like a command
			local args = {}
			for subStr in string.gmatch(string.sub(msg.text,2),"%S+") do table.insert(args, subStr) end -- split message by spaces and remove command sign
			local command = args[1]
			table.remove(args, 1) -- remove first element of arguments because it's the command itself
		
			if(chatCommands[command] ~= nil) then -- if command exists
				chatCommands[command](msg, args) -- call command with msg and arguments
			else
				sendMessage(msg.channel.id, "Unknown command.")
			end
		end
	end
end

-- WARNING: this function is super chaotic and non-readable
-- needs proper recoding
function handleMessageOld(msg)
	if(msg.text ~= nil) then
		if(string.sub(msg.text,1,1) == "!") then
			local subStrings = {}
			for subStr in string.gmatch(string.sub(msg.text,2),"%S+") do table.insert(subStrings, subStr) end -- Split message
			
			local args = {}
			args = deepcopy(subStrings) -- Make a true copy of array
			table.remove(args,1) -- Remove first element, since it's the command itself
			
			local qArgs = {}
			
			local quoteClosed = true
			local skipTo = 1
			
			for k, v in pairs(args) do -- Quotes parsen
				if(string.sub(v, -1) == "\"" and string.sub(v, 1, 1) == "\"") then -- Wenn Anfangsquote auch Endquote ist
					table.insert(qArgs, string.sub(v, 2, -2))
				elseif(string.sub(v, 1, 1) == "\"") then -- Wenn Anfangsquote gefunden wurde
					quoteClosed = false
					for i=k+1,#args do -- Durch alle restlichen Argumente gehen und Endquote suchen
						if(string.sub(args[i], -1) == "\"") then -- Wenn Endquote gefunden wurde
							quoteClosed = true -- Quote wurde geschlossen
							local quoteArg = ""
							quoteArg = quoteArg..string.sub(v, 2) -- Argument mit Anfangsquote zu quoteArg hinzufügen
							for j=k+1,i-1 do -- Von Anfangs+1 bis Endquote-1 durchgehen
								quoteArg = quoteArg.." "..args[j] -- Argumente zwischen Anfangs und Endquote zu quoteArg hinzufügen
							end
							quoteArg = quoteArg.." "..string.sub(args[i], 1, -2) -- Argument mit Endquote zu quoteArg hinzufügen
							skipTo = i+1 -- Bis nach die Quote skippen
							table.insert(qArgs, quoteArg) -- quoteArg in neues Argument-Table hinzufügen
							break
						end
					end
				else
					if(k >= skipTo) then -- Erst wenn loop nach der letzten Quote ist wieder einzelne Elemente inserten
						table.insert(qArgs, v)
					end
				end
			end

			local commandExist = false
			local command = string.lower(subStrings[1])
			for k, v in pairs(chatCommands) do
				if(chatCommands[command] ~= nil) then
					commandExist = true
					if (quoteClosed or command == "lua" or command == "luas" or command == "sh") then -- Lua and Shell command should ignore quotes
						chatCommands[command](msg, qArgs)
					else -- If there are unclosed quotes
						sendMessage(msg.channel.id, "["..botName.."] Error: Not every quote is closed!")
					end
					break
				end
			end
			
			if (not commandExist) then -- If command wasn't existing
				sendMessage(msg.channel.id, "["..botName.."] Unknown command.")
			end
		end
	end
end

-- Vital chat commands
addCommand("update", function(msg, args)
	if(isAdmin(msg)) then
		os.execute("git -C ".. installPath .." reset --hard")
		local text = os.capture("git -C ".. installPath .." pull")
		if (text ~= "Already up-to-date.") then
			local beginPos, endPos, fromVersion, toVersion = string.find(text, "(%w+)%.%.(%w+)") 	-- Get version hashes
			text = string.sub(text, endPos+15)														-- Remove version hashes from string
			text = string.gsub(text, "([%+%-]+)%s", "%1\n")											-- Format file changes
			sendMessage(mainChannel, "[Update] Updating from <".. fromVersion .."> to <".. toVersion .. ">\n"..text)
			sendMessage(mainChannel, "[Update] Please reload the bot to apply the changes.")		-- Safety delay to give the update process some time (needs admin credentials)
		else
			sendMessage(mainChannel, "[Update] Already up-to-date.")
		end
	end
end)

addCommand("reload", function(msg, args)
	if(isAdmin(msg)) then
		func, errorStr = loadfile(defaultFilePath)
		if(func == nil) then
			sendMessage(mainChannel, "An error occured while running the script:\n"..errorStr)
		else
			func()
		end
	end
end)
 
-- Function to execute "cmd" in the standard command line and returns it's output.
-- is needed to initialize
function os.capture(cmd, raw)
	local f = assert(io.popen(cmd, 'r'))
	local s = assert(f:read('*a'))
	f:close()
	if raw then return s end
	s = string.gsub(s, '^%s+', '')
	s = string.gsub(s, '%s+$', '')
	s = string.gsub(s, '[\n\r]+', ' ')
	return s
end

------ Load Libraries ------
function loadLibs()
	lsStr = os.capture("ls "..libPath)
	local libs = {}
	for file in string.gmatch(lsStr, "%a+.lua") do 
		func, errorStr = loadfile(libPath..file) 
		if(func == nil) then
			sendMessage(mainChannel, "[INIT] Error loading library ("..file.."):\n"..errorStr)
		else
			func()
			print("[LUA] Library ("..file..") loaded!")
		end
	end
end

------ Load Modules ------
function loadModules()
	lsStr = os.capture("ls "..modulePath)
	local modules = {}
	for file in string.gmatch(lsStr, "%a+.lua") do 
		func, errorStr = loadfile(modulePath..file) 
		if(func == nil) then
			sendMessage(mainChannel, "[INIT] Error loading module ("..file.."):\n"..errorStr)
		else
			func()
			print("[LUA] Module ("..file..") loaded!")
		end
	end
end

loadLibs()			-- Load essential libraries
loadModules()		-- Load additional modules

sendMessage(mainChannel, "["..botName.."] Initialized!")

hook.Add("onMessageReceived", "messageHandler", handleMessage)