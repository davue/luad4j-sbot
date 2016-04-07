--[[ Voice module - Docs:
This modules provides functions to interact with the voice channel



]]

addCommand("play", function(msg, args)
	queueFile(getVoiceChannels(getGuilds()[1].id)[1].id, args[1])
end)

addCommand("stop", function(msg, args)
	clearQueue(getVoiceChannels(getGuilds()[1].id)[1].id)
end)

addCommand("volume", function(msg, args)
	if(isAdmin(msg)) then
		setAudioVolume(getVoiceChannels(getGuilds()[1].id)[1].id, args[1])
	end
end)

addCommand("pause", function(msg, args)
	pauseAudio(getVoiceChannels(getGuilds()[1].id)[1].id)
end)

addCommand("resume", function(msg, args)
	resumeAudio(getVoiceChannels(getGuilds()[1].id)[1].id)
end)

addCommand("joinVoice", function(msg, args)
	if(isAdmin(msg)) then
		joinVoiceChannel(getVoiceChannels(getGuilds()[1].id)[1].id)
	end
end)

addCommand("leaveVoice", function(msg, args)
	if(isAdmin(msg)) then
		leaveVoiceChannel(getVoiceChannels(getGuilds()[1].id)[1].id)
	end
end)

addCommand("lssounds", function(msg, args)
	lsStr = os.capture("ls sounds")
	soundlist = ""
	for file in string.gmatch(lsStr, "%a+.wav") do 
		soundlist = soundlist .. file .. "\r\n"
	end
	sendMessage(mainChannel, soundlist)
end)