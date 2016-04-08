installPath = "/home/pi/discord/lua"
defaultFilePath = installPath.."/main.lua"
libPath = installPath.."/lib/"
modulePath = installPath.."/modules/"
mainChannel = "165560868426219520" -- #stammbot-dev-channel @ Stammgruppe Afterbirth

------------------------
---- Initialization ----
------------------------
function loadDependencyManager()
	local func, errorStr = loadfile(libPath.."depends.lua")
	if(func == nil) then
		sendMessage(mainChannel, "[INIT][ERROR] An error occured while loading dependency manager:\n"..errorStr)
	else
		func()
		print("[LUA] Dependency manager loaded!")
	end
end

function loadLibs() -- Load Libraries
	local lsStr = os.capture("ls "..libPath)
	for file in string.gmatch(lsStr, "(%a+).lua") do 
		depends.onLib(file)
	end
end

function loadModules() -- Load Modules
	local lsStr = os.capture("ls "..modulePath)
	for file in string.gmatch(lsStr, "(%a+).lua") do 
		depends.onModule(file)
	end
end

loadDependencyManager() -- Load dependency manager

loadLibs()				-- Load essential libraries
loadModules()			-- Load additional modules

sendMessage(mainChannel, "[INFO] Initialized!")

-----------------------------
---- Vital Chat Commands ----
-----------------------------
command.add("update", function(msg, args)
	if(core.isAdmin(msg)) then
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

command.add("reload", function(msg, args)
	if(core.isAdmin(msg)) then
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