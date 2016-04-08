--[[ Voice module - Docs:
This modules provides functions to interact with the voice channel



]]

local connectedChannel = ""

addCommand("add", function(msg, args)
	if(#args == 1) then
		err = queueFile(connectedChannel, args[1])
		if(err ~= nil) then
			if(err == "DiscordException") then
				sendMessage(msg.channel.id, "I am not in a channel yet.")
			else
				sendMessage(msg.channel.id, "An unknown error occured.")
			end
		end
	else
		sendMessage(msg.channel.id, "Usage: add <soundpath>")
	end
end)

addCommand("addURL", function(msg, args)
	if(#args == 1) then
		err = queueURL(connectedChannel, args[1])
		if(err ~= nil) then
			if(err == "DiscordException") then
				sendMessage(msg.channel.id, "I am not in a channel yet.")
			else
				sendMessage(msg.channel.id, "An unknown error occured.")
			end
		end
	else
		sendMessage(msg.channel.id, "Usage: addURL <soundurl>")
	end
end)

addCommand("stop", function(msg, args)
	clearQueue(getVoiceChannels(msg.guild.id)[1].id)
end)

addCommand("volume", function(msg, args)
	if(tonumber(args[1]) >= 0 and tonumber(args[1]) <= 1) then
		setAudioVolume(connectedChannel, args[1])
	else
		sendMessage(msg.channel.id, "Usage: volume <0 - 1>")
	end
end)

addCommand("pause", function(msg, args)
	pauseAudio(connectedChannel)
end)

addCommand("resume", function(msg, args)
	resumeAudio(connectedChannel)
end)

addCommand("joinVoice", function(msg, args)
	if(isAdmin(msg)) then
		local voiceChannels = getVoiceChannels(msg.guild.id)
		local err = nil;
		
		if(#voiceChannels > 1) then
			if(#args >= 1) then
				for k,v in pairs(voiceChannels) do
					if (v.name == args[1]) then
						joinVoiceChannel(v.id)
						connectedChannels = v.id
						return
					end
					sendMessage(msg.channel.id, "Could not find channel: \""..args[1].."\"")
				end
			else
				local message = "Multiple channels found: \n"
				
				for k,v in pairs(voiceChannels) do
					message = message .. v.name .. "\n"
				end
			
				sendMessage(msg.channel.id, message)
			end
		elseif(#voiceChannels == 1) then
			joinVoiceChannel(voiceChannels[1].id)
			connectedChannels = v.id
		else
			sendMessage(msg.channel.id, "No voicechannels found.")
		end
	end
end)

addCommand("leaveVoice", function(msg, args)
	if(isAdmin(msg)) then
		local voiceChannels = getVoiceChannels(msg.guild.id)
		local err = nil;
		
		if(#voiceChannels > 1) then
			if(#args >= 1) then
				for k,v in pairs(voiceChannels) do
					if (v.name == args[1]) then
						leaveVoiceChannel(v.id)
						connectedChannels = v.id
						return
					end
					sendMessage(msg.channel.id, "Could not find channel: \""..args[1].."\"")
				end
			else
				local message = "Multiple channels found: \n"
				
				for k,v in pairs(voiceChannels) do
					message = message .. v.name .. "\n"
				end
			
				sendMessage(msg.channel.id, message)
			end
		elseif(#voiceChannels == 1) then
			leaveVoiceChannel(voiceChannels[1].id)
			connectedChannels = v.id
		else
			sendMessage(msg.channel.id, "No voicechannels found.")
		end
	end
end)

addCommand("lssounds", function(msg, args)
	lsStr = os.capture("ls sounds")
	soundlist = ""
	for file in string.gmatch(lsStr, "%a+.wav") do 
		soundlist = soundlist .. file .. "\r\n"
	end
	sendMessage(msg.channel.id, soundlist)
end)

addCommand("skip", function(msg, args)
	
end)

addCommand("fskip", function(msg, args)
	if(isAdmin(msg)) then
		skipAudio(connectedChannel)
	end
end)