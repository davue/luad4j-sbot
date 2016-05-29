--[[ Depends Lib - Docs:
This library handles dependencies between libraries and modules.
You need to load it before loading anything else.

depends.onLib(string: name)
	Searches for a library called <name>.lua inside the lib path and tries to load it.
	
depends.onModule(string: name)
	Searches for a module called <name>.lua inside the modules path and tries to load it.
	
depends.libLoaded(string: name)
	Returns whether a lib was loaded.
	
depends.moduleLoaded(string: name)
	Returns whether a module was loaded.
]]

depends = {} 								-- Table containing depends library
local loaded = {libs = {}, modules = {}}	-- Table containing names of loaded libraries

function os.capture(cmd, raw)
	local f = assert(io.popen(cmd, 'r'))
	local s = f:read('*a')
	f:close()
	if raw then return s end
	if s == nil then return s end
		s = string.gsub(s, '^%s+', '')
		s = string.gsub(s, '%s+$', '')
		s = string.gsub(s, '[\n\r]+', ' ')
	return s
end

function depends.onLib(name)
	if(not depends.libLoaded(name)) then
		func, errorStr = loadfile(libPath..name..".lua") 
		if(func == nil) then
			mainChannel.sendMessage("[DEPENDS][ERROR] Error loading library ("..name.."):\n"..errorStr)
		else
			func()
			print("[LUA] Library ("..name..") loaded!")
			table.insert(loaded["libs"], name)
			return true
		end
	end
end

function depends.onModule(name)
	if(not depends.moduleLoaded(name)) then
		func, errorStr = loadfile(modulePath..name..".lua") 
		if(func == nil) then
			mainChannel.sendMessage("[DEPENDS][ERROR] Error loading module ("..name.."):\n"..errorStr)
		else
			func()
			print("[LUA] Module ("..name..") loaded!")
			table.insert(loaded["modules"], name)
			return true
		end
	end
end

function depends.libLoaded(name)
	for k, v in pairs(loaded["libs"]) do
		if(v == name) then
			return true
		end
	end
	
	return false
end

function depends.moduleLoaded(name)
	for k, v in pairs(loaded["modules"]) do
		if(v == name) then
			return true
		end
	end
	
	return false
end

table.insert(loaded["libs"], "depends") -- Dependency manager loaded.