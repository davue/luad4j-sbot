local connectedChannel = nil -- #table

-- We Are One Network
command.add("weareone", function(msg, args)
	if(connectedChannel ~= nil) then
		if(connectedChannel.getAudioChannel().getQueueSize() == 0) then
			if(#args == 1 and (args[1] == "technobase" or args[1] == "housetime" or args[1] == "hardbase" or args[1] == "trancebase" or args[1] == "coretime" or args[1] == "clubtime")) then
				connectedChannel.getAudioChannel().queueURL("http://listen.".. args[1] ..".fm/tunein-mp3-pls")
			else
				msg.getChannel().sendMessage("[INFO] Usage: weareone (technobase/housetime/hardbase/trancebase/coretime/clubtime)")
			end
		else
			msg.getChannel().sendMessage("[INFO] There is already something queued.")
		end
	else
		msg.getChannel().sendMessage("[INFO] I am not in a voice channel.")
	end
	
	msg.delete()
end)

command.add("add", function(msg, args)
	if(connectedChannel ~= nil) then
		if(#args == 1) then
			if(string.find(args[1], "https?://w*%.?soundcloud%.com.+") ~= nil) then -- If it's a soundcloud link
				connectedChannel.getAudioChannel().queueURL("http://davue.dns1.us/soundcloudtomp3.php?url=".. args[1])
			elseif(string.find(args[1], "https?://w*%.?youtube%.com.+") ~= nil) then -- If it's a youtube link
				connectedChannel.getAudioChannel().queueFile(os.capture("youtube-dl -x --audio-format mp3 -o '/home/dave/discord/mp3/%(id)s.%(ext)s' ".. args[1])..".mp3")
			elseif(string.find(args[1], "https?://") ~= nil) then -- If it's another link
				connectedChannel.getAudioChannel().queueURL(args[1])
			else -- It's probably a file
				connectedChannel.getAudioChannel().queueFile(args[1])
			end
		else
			msg.getChannel().sendMessage("[INFO] Usage: add <url/file>\n[INFO] Supports Soundcloud, YouTube, direct links and local filepaths.")
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

command.add("join", function(msg, args)
	if(core.isAdmin(msg)) then
		voiceChannels = msg.getGuild().getVoiceChannels()
		connectedChannels = discord.getConnectedVoiceChannels()
		
		if(#voiceChannels == 1 and #args == 0) then -- if there is only one voice channel -> join this channel
			if(not voiceChannels[1].isConnected()) then
				voiceChannels[1].join()
				connectedChannel = voiceChannels[1]
			else
				msg.getChannel().sendMessage("[INFO] I'm already in the voice channel.")
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
								msg.getChannel().sendMessage("[INFO] I'm already in this voice channel.")
								break
							else
								msg.getChannel().sendMessage("[INFO] I'm already in the voice channel: \"".. channel.getName() .."\".\n[INFO] I can only join one channel per server.")
								break
							end
						end
					end
					
					if(args[1] == channel.getName() and not alreadyInChannel) then -- if there is a channel with name <arg>
						if(not voiceChannels[k].isConnected()) then
							voiceChannels[k].join()
							connectedChannel = voiceChannels[k]
							channelExists = true
							break
						end
					end
				end
				
				if(not channelExists) then
					msg.getChannel().sendMessage("[INFO] There is no channel called: \"".. args[1] .."\".\n")
				end
			elseif(#args >= 1) then
				msg.getChannel().sendMessage("[INFO] I can only join one channel per server.")
			else -- need one arg to specify channel to leave
				msg.getChannel().sendMessage("[INFO] There are multiple voice channels.\n[INFO] Please specify the voice channel you would like me to join.\n[INFO] Usage: join <channel>")
			end
		else
			msg.getChannel().sendMessage("[INFO] There are no voice channels on this server.")
		end
	else
		msg.getChannel().sendMessage("[INFO] Admin-only command.")
	end
	
	msg.delete()
end)

command.add("leave", function(msg, args)
	if(core.isAdmin(msg)) then
		local voiceChannels = discord.getConnectedVoiceChannels()

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

command.add("fskip", function(msg, args)
	if(msg == "override" or core.isAdmin(msg)) then
		if(connectedChannel ~= nil) then
			connectedChannel.getAudioChannel().skip()
		else
			msg.getChannel().sendMessage("[INFO] I am not in a voice channel.")
		end
	end
	
	msg.delete()
end)

----------------------------
---- Skip functionality ----
----------------------------
local voteMessage = nil

hook.add("onUserVoiceChannelLeave", "updateVote", function()
	if(vote.get("skip") ~= nil) then
		voteMessage.edit(printVote(vote.get("skip")))
	end
end)

hook.add("onUserVoiceChannelJoin", "updateVote", function()
	if(vote.get("skip") ~= nil) then
		voteMessage.edit(printVote(vote.get("skip")))
	end
end)

hook.add("onAudioStop", "resetVote", function()		-- Reset vote if audio has ended
	if(vote.get("skip") ~= nil) then
		vote.stop("skip")
		voteMessage.delete()
	end
end)

hook.add("onAudioUnqueued", "resetVote", function()	-- Reset vote if audio was unqueued (skipped)
	if(vote.get("skip") ~= nil) then
		vote.stop("skip")
		voteMessage.delete()
	end
end)

local function getConnectedUsers()	-- Function to get all users connected the voice channel
	connectedUsers = {}
	connectedUsers.count = 0
	for k, v in pairs(connectedChannel.getGuild().getUsers()) do
		voiceChannel = v.getVoiceChannel()
		if(voiceChannel ~= nil and voiceChannel.getID() == connectedChannel.getID()) then -- If there is a voicechannel and it's the same as connected
			table.insert(connectedUsers, v.getID())
			connectedUsers.count = connectedUsers.count + 1
		end
	end
	
	return connectedUsers
end

local function printVote(voteTable)
	local votesNeeded = math.floor(getConnectedUsers().count-1/2)+1
	local message = "--------- Skip? ---------\n"..voteTable.answers[1].votes.count.."/"..votesNeeded.." votes needed to skip"
	return message
end

command.add("skip", function(msg, args)
	if(connectedChannel ~= nil) then
		if(connectedChannel.getAudioChannel().getQueueSize() > 0) then
			if(vote.get("skip") == nil) then
				vote.start("skip", "Skip?", "Yes")
				vote.toggle("skip", 1, msg.getAuthor().getID())
				voteMessage = msg.getChannel().sendMessage(printVote(vote.get("skip")))
			else
				vote.toggle("skip", 1, msg.getAuthor().getID())
			end
			
			local votesNeeded = math.floor(getConnectedUsers().count-1/2)+1
			if(vote.get("skip").answers[1].votes.count == votesNeeded) then
				voteMessage.edit("Vote passed, skipping...")
				connectedChannel.getAudioChannel().skip()
			else
				voteMessage.edit(printVote(vote.get("skip")))
			end
		else
			msg.getChannel().sendMessage("[INFO] There is no queued audio.")
		end
	else
		msg.getChannel().sendMessage("[INFO] I am not in a voice channel.")
	end
end)

--------------
---- Init ----
--------------
local voiceChannels = discord.getConnectedVoiceChannels()	-- Leave all voice channels on init

for i, channel in pairs(voiceChannels) do
	channel.leave()
end