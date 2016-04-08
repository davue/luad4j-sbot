--[[ Voice module - Docs:
This modules provides functions to interact with the voice channel



]]

local connectedChannels = {}

addCommand("add", function(msg, args)
	if(#args == 1) then
		queueFile(getVoiceChannels(msg.guild.id)[1].id, args[1])
	else
		sendMessage(msg.channel.id, "Usage: add <soundpath>")
	end
end)

addCommand("addURL", function(msg, args)
	if(#args == 1) then
		queueURL(getVoiceChannels(msg.guild.id)[1].id, args[1])
	else
		sendMessage(msg.channel.id, "Usage: addURL <soundurl>")
	end
end)

addCommand("stop", function(msg, args)
	clearQueue(getVoiceChannels(msg.guild.id)[1].id)
end)

addCommand("volume", function(msg, args)
	if(tonumber(args[1]) >= 0 and tonumber(args[1]) <= 1) then
		setAudioVolume(getVoiceChannels(msg.guild.id)[1].id, args[1])
	else
		sendMessage(msg.channel.id, "Usage: volume <0 - 1>")
	end
end)

addCommand("pause", function(msg, args)
	pauseAudio(getVoiceChannels(msg.guild.id)[1].id)
end)

addCommand("resume", function(msg, args)
	resumeAudio(getVoiceChannels(msg.guild.id)[1].id)
end)

addCommand("joinVoice", function(msg, args)
	if(isAdmin(msg)) then
		local voiceChannels = getVoiceChannels(msg.guild.id)
		
		if(#voiceChannels > 1) then
			if(#args > 1) then
				for k,v in pairs(voiceChannels) do
					if (v.name == args[2]) then
						joinVoiceChannel(v.id)
						table.insert(connectedChannels, v.id)
						break
					else
						sendMessage(msg.channel.id, "Could not find channel: \""..args[2].."\"")
					end
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
			table.insert(connectedChannels, voiceChannels[1].id)
		else
			sendMessage(msg.channel.id, "No voicechannels found.")
		end
	end
end)

addCommand("leaveVoice", function(msg, args)
	if(isAdmin(msg)) then
		leaveVoiceChannel(getVoiceChannels(msg.guild.id)[1].id)
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
		skipAudio(getVoiceChannels(msg.guild.id)[1].id)
	end
end)