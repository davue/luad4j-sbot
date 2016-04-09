local connectedChannel = nil

local function isInChannel(guild, channelname)
	voiceChannels = getVoiceChannels(guild)
	connectedChannels = getConnectedVoiceChannels()
	
	for k, conChannel in pairs(connectedChannels) do
		for i, channel in pairs(voiceChannels) do
			if(conChannel.id == channel.id and channelname == channel.name) then
				return true
			end
		end
	end
	
	return false
end

command.add("sc", function(msg, args)
	if(connectedChannel ~= nil) then
		if(#args == 1) then
			queueURL(connectedChannel, "http://davue.dns1.us/soundcloudtomp3.php?url=".. args[1])
			deleteMessage(msg.channel.id, msg.id)
		else
			sendMessage(msg.channel.id, "[INFO] Usage: sc <url>")
		end
	else
		sendMessage(msg.channel.id, "[INFO] I am not in a voice channel.")
	end
end)

command.add("addFile", function(msg, args)
	if(connectedChannel ~= nil) then
		if(#args == 1) then
			queueFile(connectedChannel, args[1])
			deleteMessage(msg.channel.id, msg.id)
		else
			sendMessage(msg.channel.id, "[INFO] Usage: add <soundpath>")
		end
	else
		sendMessage(msg.channel.id, "[INFO] I am not in a voice channel.")
	end
end)

command.add("addURL", function(msg, args)
	if(connectedChannel ~= nil) then
		if(#args == 1) then
			queueURL(connectedChannel, args[1])
			deleteMessage(msg.channel.id, msg.id)
		else
			sendMessage(msg.channel.id, "[INFO] Usage: add <soundURL>")
		end
	else
		sendMessage(msg.channel.id, "[INFO] I am not in a voice channel.")
	end
end)

command.add("stop", function(msg, args)
	if(connectedChannel ~= nil) then
		clearQueue(connectedChannel, args[1])
	else
		sendMessage(msg.channel.id, "[INFO] I am not in a voice channel.")
	end
end)

command.add("volume", function(msg, args)
	if(connectedChannel ~= nil) then
		if(tonumber(args[1]) >= 0 and tonumber(args[1]) <= 1) then
			setAudioVolume(connectedChannel, args[1])
		else
			sendMessage(msg.channel.id, "[INFO] Usage: volume <0 - 1>")
		end
	else
		sendMessage(msg.channel.id, "[INFO] I am not in a voice channel.")
	end
end)

command.add("pause", function(msg, args)
	if(connectedChannel ~= nil) then
		pauseAudio(connectedChannel)
	else
		sendMessage(msg.channel.id, "[INFO] I am not in a voice channel.")
	end
end)

command.add("resume", function(msg, args)
	if(connectedChannel ~= nil) then
		resumeAudio(connectedChannel)
	else
		sendMessage(msg.channel.id, "[INFO] I am not in a voice channel.")
	end
end)

command.add("join", function(msg, args)
	if(core.isAdmin(msg)) then
		voiceChannels = getVoiceChannels(msg.guild.id)
		connectedChannels = getConnectedVoiceChannels()
		
		if(#voiceChannels == 1 and #args == 0) then -- if there is only one voice channel -> join this channel
			if(not isConnectedToVoice(voiceChannels[1].id)) then
				joinVoiceChannel(voiceChannels[1].id)
				connectedChannel = voiceChannels[1].id
			else
				sendMessage(msg.channel.id, "[INFO] Bot is already in the voice channel.")
			end
		elseif(#voiceChannels >= 1) then -- if there are more than one voice channels
			if(#args == 1) then -- when there are one or more arguments passed
				channelExists = false;
				alreadyInChannel = false;
				
				for k, channel in pairs(voiceChannels) do
					for i, conChannel in pairs(connectedChannels) do
						if(channel.id == conChannel.id) then -- if you are already in a channel of the same server
							channelExists = true
							alreadyInChannel = true
							if(channel.name == args[1]) then -- if it's the same channel you want to join
								sendMessage(msg.channel.id, "[INFO] You are already in this voice channel.")
								break
							else
								sendMessage(msg.channel.id, "[INFO] You are already in the voice channel: \"".. channel.name .."\".\n[INFO] You can only join one channel per server.")
								break
							end
						end
					end
					
					if(args[1] == channel.name and not alreadyInChannel) then -- if there is a channel with name <arg>
						if(not isConnectedToVoice(voiceChannels[k].id)) then
							joinVoiceChannel(voiceChannels[k].id)
							connectedChannel = voiceChannels[1].id
							channelExists = true
							break
						end
					end
				end
				
				if(not channelExists) then
					message = message .."[INFO] There is no channel called: \"".. arg[1] .."\".\n"
				end
			elseif(#args >= 1) then
				sendMessage(msg.channel.id, "[INFO] You can only join one channel per server.")
			else -- need one arg to specify channel to leave
				sendMessage(msg.channel.id, "[INFO] There are multiple voice channels.\n[INFO] Please specify the voice channel you would like me to join.\n[INFO] Usage: joinVoice <channel>")
			end
		else
			sendMessage(msg.channel.id, "[INFO] There are no voice channels on this server.")
		end
	else
		sendMessage(msg.channel.id, "[INFO] Admin-only command.")
	end
end)

command.add("leave", function(msg, args)
	if(core.isAdmin(msg)) then
		local voiceChannels = getVoiceChannels(msg.guild.id)

		for i, channel in pairs(voiceChannels) do
			if(isConnectedToVoice(channel.id)) then
				leaveVoiceChannel(channel.id)
				connectedChannel = nil
			end
		end
	else
		sendMessage(msg.channel.id, "[INFO] Admin-only command.")
	end
end)

command.add("lssounds", function(msg, args)
	lsStr = os.capture("ls sounds")
	soundlist = ""
	for file in string.gmatch(lsStr, "%a+.wav") do 
		soundlist = soundlist .. file .. "\r\n"
	end
	sendMessage(msg.channel.id, soundlist)
end)

command.add("skip", function(msg, args)
	
end)

command.add("fskip", function(msg, args)
	if(core.isAdmin(msg)) then
		if(connectedChannel ~= nil) then
			skipAudio(connectedChannel)
		else
			sendMessage(msg.channel.id, "[INFO] I am not in a voice channel.")
		end
	end
end)

-- Leave all voice channels on reload
local guilds = getGuilds()
for k, guild in pairs(guilds) do
	local voiceChannels = getVoiceChannels(guild.id)

	for i, channel in pairs(voiceChannels) do
		if(isConnectedToVoice(channel.id)) then
			leaveVoiceChannel(channel.id)
			connectedChannel = nil
		end
	end
end
