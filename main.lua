installPath = "/home/pi/discord/lua"
defaultFilePath = installPath.."/main.lua"
libPath = installPath.."/lib/"
modulePath = installPath.."/modules/"
mainChannel = "165560868426219520" -- #stammbot-dev-channel @ Stammgruppe Afterbirth

local admins = {"163605020271575041"} -- Dave-it

------------------------
---- Initialization ----
------------------------
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

function loadLibs() -- Load Libraries
	lsStr = os.capture("ls "..libPath)
	local libs = {}
	for file in string.gmatch(lsStr, "%a+.lua") do 
		func, errorStr = loadfile(libPath..file) 
		if(func == nil) then
			sendMessage(mainChannel, "[INIT][ERROR] Error loading library ("..file.."):\n"..errorStr)
		else
			func()
			print("[LUA] Library ("..file..") loaded!")
		end
	end
end

function loadModules() -- Load Modules
	lsStr = os.capture("ls "..modulePath)
	local modules = {}
	for file in string.gmatch(lsStr, "%a+.lua") do 
		func, errorStr = loadfile(modulePath..file) 
		if(func == nil) then
			sendMessage(mainChannel, "[INIT][ERROR] Error loading module ("..file.."):\n"..errorStr)
		else
			func()
			print("[LUA] Module ("..file..") loaded!")
		end
	end
end

loadLibs()			-- Load essential libraries
loadModules()		-- Load additional modules

sendMessage(mainChannel, "[INFO] Initialized!")

-----------------------------
---- Vital Chat Commands ----
-----------------------------
core.addCommand("update", function(msg, args)
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

core.addCommand("reload", function(msg, args)
	if(isAdmin(msg)) then
		func, errorStr = loadfile(defaultFilePath)
		if(func == nil) then
			sendMessage(mainChannel, "[ERROR] An error occured while running the script:\n"..errorStr)
		else
			func()
		end
	end
end)

----------------
---- Events ----
----------------
function onMessageReceived(msg)
	hook.Call("onMessageReceived", msg)
end

function onLuaError(reason)
	sendMessage(mainChannel, "[ERROR] An error occured while running the script:\n"..reason)
end

function onPortData(data)
	sendMessage(mainChannel, data)
end