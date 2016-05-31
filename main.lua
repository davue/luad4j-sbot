-----------------
---- Globals ----
-----------------
luaPath = "lua/"
libPath = luaPath .. "lib/"
modulePath = luaPath .. "modules/"

mainChannel = discord.getChannelByID("165560868426219520") -- stammbot-dev-channel @ Stammgruppe Afterbirth

------------------------
---- Initialization ----
------------------------
function loadDependencyManager()
	local func, errorStr = loadfile(libPath.."depends.lua")
	if(func == nil) then
		mainChannel.sendMessage("[INIT][ERROR] An error occured while loading dependency manager:\n"..errorStr)
	else
		func()
		print("[LUA] Dependency manager loaded!")
	end
end

function loadModules() -- Load Modules
	local lsStr = os.capture("ls "..modulePath)
	for file in string.gmatch(lsStr, "(%a+).lua") do 
		depends.onModule(file)
	end
end

function reconnect() -- Try to reconnect to Discord
	hook.remove("autoreconnect") -- Prevents multiple reconnect attempts at the same time
	
	if(not discord.isReady()) then
		discord.login()
		setTimer(5000, reconnect) -- Retry in 5sec
	end
end

loadDependencyManager() 	-- Load dependency manager

loadModules()				-- Load additional modules

mainChannel.sendMessage("[INFO] Initialized!")

-----------------------------
---- Vital Chat Commands ----
-----------------------------
depends.onLib("core")
depends.onLib("command")

command.add("update", function(msg, args)
	if(core.isAdmin(msg)) then
		os.execute("git -C ".. luaPath .." reset --hard")
		local text = os.capture("git -C ".. luaPath .." pull")
		if (text ~= "Already up-to-date.") then
			local beginPos, endPos, fromVersion, toVersion = string.find(text, "(%w+)%.%.(%w+)") 	-- Get version hashes
			text = string.sub(text, endPos+15)																		-- Remove version hashes from string
			text = string.gsub(text, "([%+%-]+)%s", "%1\n")														-- Format file changes
			mainChannel.sendMessage("[Update] Updating from <".. fromVersion .."> to <".. toVersion .. ">:\n```"..text.."```")
			setTimer(1000, command.getTable()["reload"], msg)													-- Reload bot after update
		else
			mainChannel.sendMessage("[Update] Already up-to-date.")
		end
	end
end)

command.add("reload", function(msg, args)
	if(core.isAdmin(msg)) then
		func, errorStr = loadfile(luaPath .."main.lua")
		if(func == nil) then
			mainChannel.sendMessage("[ERROR] An error occured while running the script:\n"..errorStr)
		else
			func()
		end
	end
end)

----------------
---- Events ----
----------------
function onAudioUpdateEvent()
	hook.call("onAudioUpdate")
end

function onDiscordDisconnectedEvent(reason)
	hook.call("onDiscordDisconnected", reason)
end

function onMessageReceivedEvent(msg)
	hook.call("onMessageReceived", msg)
end

function onAudioUnqueuedEvent(event)
	hook.call("onAudioUnqueued", event)
end

function onAudioPlayEvent(event)
	hook.call("onAudioPlay", event)
end

function onAudioQueuedEvent(event)
	hook.call("onAudioQueued", event)
end

function onAudioStopEvent(event)
	hook.call("onAudioStop", event)
end

function onUserVoiceChannelLeaveEvent(event)
	hook.call("onUserVoiceChannelLeave", event)
end

function onUserVoiceChannelJoinEvent(event)
	hook.call("onUserVoiceChannelJoin", event)
end

function onJavaErrorEvent(error)
	hook.call("onJavaError", error)
end

function onPortData(data)
	mainChannel.sendMessage(data)
end

hook.add("onDiscordDisconnected", "autoreconnect", function(reason)
	print("[LUA] API Disconnected: "..reason.."\n[LUA] Trying to reconnect...")	-- Print the reason why Discord4J lost connection
	setTimer(5000, reconnect)
end)