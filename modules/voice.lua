local connectedChannel = nil -- #table 

command.add("sc", function(msg, args)
	if(connectedChannel ~= nil) then
		if(#args == 1) then
			connectedChannel.getAudioChannel().queueURL("http://davue.dns1.us/soundcloudtomp3.php?url=".. args[1])
		else
			msg.getChannel().sendMessage("[INFO] Usage: sc <url>")
		end
	else
		msg.getChannel().sendMessage("[INFO] I am not in a voice channel.")
	end
	
	msg.delete()
end)

command.add("addFile", function(msg, args)
	if(connectedChannel ~= nil) then
		if(#args == 1) then
			connectedChannel.getAudioChannel().queueFile(args[1])
		else
			msg.getChannel().sendMessage("[INFO] Usage: add <soundpath>")
		end
	else
		msg.getChannel().sendMessage("[INFO] I am not in a voice channel.")
	end
	
	msg.delete()
end)

command.add("addURL", function(msg, args)
	if(connectedChannel ~= nil) then
		if(#args == 1) then
			connectedChannel.getAudioChannel().queueURL(args[1])
		else
			msg.getChannel().sendMessage("[INFO] Usage: add <soundURL>")
		end
	else
		msg.getChannel().sendMessage("[INFO] I am not in a voice channel.")
	end
	
	msg.delete()
end)

command.add("stop", function(msg, args)
	if(connectedChannel ~= nil) then
		connectedChannel.getAudioChannel().clearQueue()
	else
		msg.getChannel().sendMessage("[INFO] I am not in a voice channel.")
	end
	
	msg.delete()
end)

command.add("volume", function(msg, args)
	if(connectedChannel ~= nil) then
		if(tonumber(args[1]) >= 0 and tonumber(args[1]) <= 1) then
			connectedChannel.getAudioChannel().setVolume(args[1])
		else
			msg.getChannel().sendMessage("[INFO] Usage: volume <0 - 1>")
		end
	else
		msg.getChannel().sendMessage("[INFO] I am not in a voice channel.")
	end
	
	msg.delete()
end)

command.add("pause", function(msg, args)
	if(connectedChannel ~= nil) then
		connectedChannel.getAudioChannel().pause()
	else
		msg.getChannel().sendMessage("[INFO] I am not in a voice channel.")
	end
	
	msg.delete()
end)

command.add("resume", function(msg, args)
	if(connectedChannel ~= nil) then
		connectedChannel.getAudioChannel().resume()
	else
		msg.getChannel().sendMessage("[INFO] I am not in a voice channel.")
	end
	
	msg.delete()
end)

-- TODO: rewrite function to fully use the new wrapper
command.add("join", function(msg, args)
	if(core.isAdmin(msg)) then
		voiceChannels = msg.getGuild().getVoiceChannels()
		connectedChannels = discordClient.getConnectedVoiceChannels()
		
		if(#voiceChannels == 1 and #args == 0) then -- if there is only one voice channel -> join this channel
			if(not voiceChannels[1].isConnected()) then
				voiceChannels[1].join()
				connectedChannel = voiceChannels[1]
			else
				msg.getChannel().sendMessage("[INFO] Bot is already in the voice channel.")
			end
		elseif(#voiceChannels >= 1) then -- if there are more than one voice channels
			if(#args == 1) then -- when there are one or more arguments passed
				channelExists = false;
				alreadyInChannel = false;
				
				for k, channel in pairs(voiceChannels) do
					for i, conChannel in pairs(connectedChannels) do
						if(channel.getID() == conChannel.getID()) then -- if you are already in a channel of the same server
							channelExists = true
							alreadyInChannel = true
							if(channel.getName() == args[1]) then -- if it's the same channel you want to join
								msg.getChannel().sendMessage("[INFO] You are already in this voice channel.")
								break
							else
								msg.getChannel().sendMessage("[INFO] You are already in the voice channel: \"".. channel.name .."\".\n[INFO] You can only join one channel per server.")
								break
							end
						end
					end
					
					if(args[1] == channel.getName() and not alreadyInChannel) then -- if there is a channel with name <arg>
						if(not voiceChannels[k].isConnected()) then
							voiceChannels[k].join()
							connectedChannel = voiceChannels[1]
							channelExists = true
							break
						end
					end
				end
				
				if(not channelExists) then
					msg.getChannel().sendMessage("[INFO] There is no channel called: \"".. arg[1] .."\".\n")
				end
			elseif(#args >= 1) then
				msg.getChannel().sendMessage("[INFO] You can only join one channel per server.")
			else -- need one arg to specify channel to leave
				msg.getChannel().sendMessage("[INFO] There are multiple voice channels.\n[INFO] Please specify the voice channel you would like me to join.\n[INFO] Usage: joinVoice <channel>")
			end
		else
			msg.getChannel().sendMessage("[INFO] There are no voice channels on this server.")
		end
	else
		msg.getChannel().sendMessage("[INFO] Admin-only command.")
	end
end)

command.add("leave", function(msg, args)
	if(core.isAdmin(msg)) then
		local voiceChannels = discordClient.getConnectedVoiceChannels()

		for i, channel in pairs(voiceChannels) do
			channel.leave()
		end
	else
		msg.getChannel().sendMessage("[INFO] Admin-only command.")
	end
	
	msg.delete()
end)

command.add("lssounds", function(msg, args)
	lsStr = os.capture("ls sounds")
	soundlist = ""
	for file in string.gmatch(lsStr, "%a+.wav") do 
		soundlist = soundlist .. file .. "\r\n"
	end
	msg.getChannel().sendMessage(soundlist)
end)

command.add("skip", function(msg, args)
	
end)

command.add("fskip", function(msg, args)
	if(core.isAdmin(msg)) then
		if(connectedChannel ~= nil) then
			connectedChannel.getAudioChannel().skip()
		else
			msg.getChannel().sendMessage("[INFO] I am not in a voice channel.")
		end
	end
	
	msg.delete()
end)

-- Leave all voice channels on reload
local voiceChannels = discordClient.getConnectedVoiceChannels()

for i, channel in pairs(voiceChannels) do
	channel.leave()
end