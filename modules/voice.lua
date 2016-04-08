local connectedChannel = nil

command.Add("add", function(msg, args)
	if(#args == 1) then
		err = queueFile(connectedChannel, args[1])
		if(err ~= nil) then
			if(err == "DiscordException") then
				sendMessage(msg.channel.id, "[INFO] I am not in a channel yet.")
			else
				sendMessage(msg.channel.id, "[ERROR] An unknown error occured.")
			end
		end
	else
		sendMessage(msg.channel.id, "[INFO] Usage: add <soundpath>")
	end
end)

command.Add("addURL", function(msg, args)
	if(#args == 1) then
		err = queueURL(connectedChannel, args[1])
		if(err ~= nil) then
			if(err == "DiscordException") then
				sendMessage(msg.channel.id, "[INFO] I am not in a channel yet.")
			else
				sendMessage(msg.channel.id, "[ERROR] An unknown error occured.")
			end
		end
	else
		sendMessage(msg.channel.id, "[INFO] Usage: addURL <soundurl>")
	end
end)

command.Add("stop", function(msg, args)
	clearQueue(getVoiceChannels(msg.guild.id)[1].id)
end)

command.Add("volume", function(msg, args)
	if(tonumber(args[1]) >= 0 and tonumber(args[1]) <= 1) then
		setAudioVolume(connectedChannel, args[1])
	else
		sendMessage(msg.channel.id, "[INFO] Usage: volume <0 - 1>")
	end
end)

command.Add("pause", function(msg, args)
	pauseAudio(connectedChannel)
end)

command.Add("resume", function(msg, args)
	resumeAudio(connectedChannel)
end)

command.Add("joinVoice", function(msg, args)
	if(isAdmin(msg)) then
		if (connectedChannel ~= nil) then
			chatCommands["leaveVoice"](msg)
		end
		
		local voiceChannels = getVoiceChannels(msg.guild.id)
		local err = nil;
		
		if(#voiceChannels > 1) then
			if(#args >= 1) then
				for k,v in pairs(voiceChannels) do
					if (v.name == args[1]) then
						joinVoiceChannel(v.id)
						connectedChannel = v.id
						return
					end
				end
				sendMessage(msg.channel.id, "[INFO] Could not find channel: \""..args[1].."\"")
			else
				local message = "[INFO] Multiple channels found: \n"
				
				for k,v in pairs(voiceChannels) do
					message = message .. v.name .. "\n"
				end
			
				sendMessage(msg.channel.id, message)
			end
		elseif(#voiceChannels == 1) then
			joinVoiceChannel(voiceChannels[1].id)
			connectedChannel = v.id
		else
			sendMessage(msg.channel.id, "[INFO] No voicechannels found.")
		end
	end
end)

command.Add("leaveVoice", function(msg, args)
	if(isAdmin(msg)) then
		if(connectedChannel ~= nil) then
			leaveVoiceChannel(connectedChannel)
			connectedChannel = nil
		end
	end
end)

command.Add("lssounds", function(msg, args)
	lsStr = os.capture("ls sounds")
	soundlist = ""
	for file in string.gmatch(lsStr, "%a+.wav") do 
		soundlist = soundlist .. file .. "\r\n"
	end
	sendMessage(msg.channel.id, soundlist)
end)

command.Add("skip", function(msg, args)
	
end)

command.Add("fskip", function(msg, args)
	if(isAdmin(msg)) then
		skipAudio(connectedChannel)
	end
end)

hook.Add("lua_onReload", "", chatCommands["leaveVoice"])