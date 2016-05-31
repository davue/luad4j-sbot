hook.add("onJavaError", "ErrorHandler", function(error)
	local exception, text = string.match(error, "(%w+):(.+)")
	if (exception == "HTTP429Exception") then
		print("[LUA] Slow down, you got rate-limited!")
	else
		mainChannel.sendMessage("[ERROR] A ".. exception .." occured:\n"..error)
	end
end)