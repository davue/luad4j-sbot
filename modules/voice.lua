--[[ Voice module - Docs:
This modules provides functions to interact with the voice channel



]]

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
		sendMessage(msg.channel.id, "Usage: add <soundurl>")
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
		joinVoiceChannel(getVoiceChannels(msg.guild.id)[1].id)
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