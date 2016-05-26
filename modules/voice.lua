local cancel = false

if(queue == nil) then -- Only initialize queue once
	queue = {}
end

-- Update "Game" representing current title
hook.add("onAudioPlay", "updatePlayingTitle", function(audio)
	local title = queue[audio.file]
	if(title ~= nil and title ~= "") then
		discord.updatePresence(false, title)
		return true
	else
		discord.updatePresence(false, "Unknown")
		return false
	end
end)

-- We Are One Network
command.add("weareone", function(msg, args)
	audioChannel = msg.getGuild().getAudioChannel()
	if(audioChannel ~= nil) then
		if(audioChannel.getQueueSize() == 0) then
			if(#args == 1 and (args[1] == "technobase" or args[1] == "housetime" or args[1] == "hardbase" or args[1] == "trancebase" or args[1] == "coretime" or args[1] == "clubtime")) then
				audioChannel.queueURL("http://listen.".. args[1] ..".fm/tunein-mp3-pls")
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
	audioChannel = msg.getGuild().getAudioChannel()
	if(audioChannel ~= nil) then
		if(#args == 1) then
			if(string.find(args[1], "https?://w*%.?soundcloud%.com.+") ~= nil) then -- If it's a soundcloud link
				audioChannel.queueURL("http://davue.dns1.us/soundcloudtomp3.php?url=".. args[1])
			elseif(string.find(args[1], "https?://w*%.?youtube%.com.+") ~= nil) then -- If it's a youtube link
				local filepath = "/home/dave/discord/mp3/"..os.capture("youtube-dl -i --no-playlist --get-id "..args[1])..".mp3"
				if(filepath ~= nil) then
					if(not file_exists(filepath)) then
						os.execute("youtube-dl -x -i --no-playlist --audio-format mp3 -f bestaudio[filesize<50M] -o /home/dave/discord/mp3/%(id)s.%(ext)s ".. args[1]) -- Download mp3 to ~/discord/mp3/(id).mp3
					end
					
					if(file_exists(filepath)) then
						title = os.capture("youtube-dl -i --no-playlist --get-title ".. args[1])
						
						--[[ Clear title
						title = string.gsub(title, "%b()", "")
						title = string.gsub(title, "%b[]", "")
						title = string.gsub(title, "  ", " ")				-- Remove double spaces
						title = string.gsub(title, "^%s*(.-)%s*$", "%1")]]	-- Remove leading and tailing spaces
						
						queue[filepath] = title
						
						audioChannel.queueFile(filepath) -- Queue file
					else
						print("[LUA][add] Skipping: "..filepath)
					end
				else
					msg.getChannel().sendMessage("[INFO] Video not found.")
				end
			elseif(string.find(args[1], "https?://") ~= nil) then -- If it's another link
				audioChannel.queueURL(args[1])
			else -- It's probably a file
				audioChannel.queueFile(args[1])
			end
		else
			msg.getChannel().sendMessage("[INFO] Usage: add <url/file>\n[INFO] Supports Soundcloud, YouTube, direct links and local filepaths.")
		end
	else
		msg.getChannel().sendMessage("[INFO] I am not in a voice channel.")
	end
	
	msg.delete()
end)

local function queueYoutube(title, id)
		local filepath = "/home/dave/discord/mp3/"..id..".mp3"
		local url = "https://www.youtube.com/watch?v="..id
		queue[filepath] = title -- Fill queue cache
		
		if(not file_exists(filepath)) then
			os.execute("youtube-dl -x --no-playlist --audio-format mp3 -f bestaudio[filesize<50M] -o /home/dave/discord/mp3/%(id)s.%(ext)s ".. url) -- Download mp3 to ~/discord/mp3/(id).mp3
		end
		
		if(file_exists(filepath)) then
			audioChannel.queueFile(filepath) -- Queue file
		else
			print("[LUA][addpl] Skipping: "..filepath)
		end
end

command.add("addpl", function(msg, args)
	audioChannel = msg.getGuild().getAudioChannel()
	if(audioChannel ~= nil) then
		if(#args >= 1) then
			if(string.find(args[1], "https?://w*%.?youtube%.com.+") ~= nil) then -- If it's a youtube link
				-- Concurrency workaround with timer instead of coroutine
				-- TODO: Find error why coroutine isn't working
				setTimer(1, function ()
					local status = nil
					local trackcount = 0
					
					if(#args == 1) then
						status = mainChannel.sendMessage("[INFO] Loading all videos from playlist...")
					
						i = 1
						while true do
							if cancel then -- Cancel logic
								return false
							end
							
							local info = os.capture("youtube-dl -i --yes-playlist --get-title --get-id --playlist-items ".. i .." ".. args[1], true)
							if(info ~= nil) then
								local title, id = string.match(info, "(.+)[\n\r]+(.+)")
								queueYoutube(title, id)
								i = i + 1
							else
								break -- Break loop if no more videos are fetched
							end
						end
					elseif(#args == 2) then -- If only the start is specified
						status = mainChannel.sendMessage("[INFO] Loading videos starting from index ".. args[2].. "...")
						
						i = args[2]
						while true do
							if cancel then -- Cancel logic
								return false
							end
							
							local info = os.capture("youtube-dl -i --yes-playlist --get-title --get-id --playlist-items ".. i .." ".. args[1], true)
							if(info ~= nil) then
								local title, id = string.match(info, "(.+)[\n\r]+(.+)")
								queueYoutube(title, id)
								i = i + 1
							else
								break -- Break loop if no more videos are fetched
							end
						end
					elseif(#args == 3) then
						status = mainChannel.sendMessage("[INFO] Loading videos from index ".. args[2].. " to ".. args[3] .."...")
					
						for i=args[2], args[3] do
							if cancel then -- Cancel logic
								status.edit("[INFO] Canceled playlist loading.")
								return false
							end
							
							local info = os.capture("youtube-dl -i --yes-playlist --get-title --get-id --playlist-items ".. i .." ".. args[1], true)
							if(info ~= nil) then
								local title, id = string.match(info, "(.+)[\n\r]+(.+)")
								queueYoutube(title, id)
							else
								break -- Break loop if no more videos are fetched
							end
						end
					else
						msg.getChannel().sendMessage("[INFO] Usage: addpl <playlist url> [start] [end]\n[INFO] Supports only YouTube.")
					end
					
					if(trackcount > 0) then -- If at least one track has been queued
						status.edit("[INFO] Finished loading ".. trackcount .." Tracks!")
					else
						status.edit("[INFO] Couldn't load any videos from playlist!\n[INFO] All videos are probably exceeding 50MB file limit.")
					end
				end)
			else -- Invalid link format
				msg.getChannel().sendMessage("[INFO] Invalid link format.")
			end
		else
			msg.getChannel().sendMessage("[INFO] Usage: addpl <playlist url> [start] [end]\n[INFO] Supports only YouTube.")
		end
	else
		msg.getChannel().sendMessage("[INFO] I am not in a voice channel.")
	end
	
	msg.delete()
end)

command.add("track", function(msg, args)
	audioChannel = msg.getGuild().getAudioChannel()
	if(audioChannel ~= nil) then
		if(audioChannel.getQueueSize() > 0) then
			msg.getChannel().sendMessage("[INFO] Current track: ".. queue[audioChannel.getAudioMetaData().getFileSource()])
		else
			msg.getChannel().sendMessage("[INFO] There is no queued audio.")
		end
	else
		msg.getChannel().sendMessage("[INFO] I am not in a voice channel.")
	end
	
	msg.delete()
end)

command.add("stop", function(msg, args)
	audioChannel = msg.getGuild().getAudioChannel();
	if(audioChannel ~= nil) then
		audioChannel.clearQueue()
	else
		msg.getChannel().sendMessage("[INFO] I am not in a voice channel.")
	end
	
	msg.delete()
end)

command.add("volume", function(msg, args)
	audioChannel = msg.getGuild().getAudioChannel()
	if(audioChannel ~= nil) then
		if(tonumber(args[1]) >= 0 and tonumber(args[1]) <= 1) then
			audioChannel.setVolume(args[1])
		else
			msg.getChannel().sendMessage("[INFO] Usage: volume <0 - 1>")
		end
	else
		msg.getChannel().sendMessage("[INFO] I am not in a voice channel.")
	end
	
	msg.delete()
end)

command.add("pause", function(msg, args)
	audioChannel = msg.getGuild().getAudioChannel();
	if(audioChannel ~= nil) then
		audioChannel.pause()
	else
		msg.getChannel().sendMessage("[INFO] I am not in a voice channel.")
	end
	
	msg.delete()
end)

command.add("resume", function(msg, args)
	audioChannel = msg.getGuild().getAudioChannel()
	if(audioChannel ~= nil) then
		audioChannel.resume()
	else
		msg.getChannel().sendMessage("[INFO] I am not in a voice channel.")
	end
	
	msg.delete()
end)

command.add("join", function(msg, args)
	voiceChannels = msg.getGuild().getVoiceChannels()
	connectedChannels = discord.getConnectedVoiceChannels()
	
	if(#voiceChannels == 1 and #args == 0) then -- if there is only one voice channel -> join this channel
		if(not voiceChannels[1].isConnected()) then
			voiceChannels[1].join()
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
	
	msg.delete()
end)

command.add("leave", function(msg, args)
	local voiceChannels = discord.getConnectedVoiceChannels()

	for i, channel in pairs(voiceChannels) do
		channel.leave()
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
	audioChannel = msg.getGuild().getAudioChannel()
	if(audioChannel ~= nil) then
		audioChannel.skip()
	else
		msg.getChannel().sendMessage("[INFO] I am not in a voice channel.")
	end
	
	msg.delete()
end)
--[[
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
	
	discord.updatePresence(false, nil)
end)

hook.add("onAudioUnqueued", "resetVote", function()	-- Reset vote if audio was unqueued (skipped)
	if(vote.get("skip") ~= nil) then
		vote.stop("skip")
		voteMessage.delete()
	end
	
	-- AudioStopEvent buggy workaround:
	if(msg.getGuild().getAudioChannel().getQueueSize() <= 1) then
		discord.updatePresence(false, nil)
	end
end)

local function getConnectedUsers(connectedChannel)	-- Function to get all users connected to the voice channel
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
	local votesNeeded = math.floor((getConnectedUsers().count-1)/2)+1
	local message = "--------- Skip? ---------\n"..voteTable.answers[1].votes.count.."/"..votesNeeded.." votes needed to skip"
	return message
end

command.add("skip", function(msg, args)
	audioChannel = msg.getGuild().getAudioChannel();
	if(connectedChannel ~= nil) then
		if(connectedChannel.getAudioChannel().getQueueSize() > 0) then
			if(vote.get("skip") == nil) then
				vote.start("skip", "Skip?", "Yes")
				vote.toggle("skip", 1, msg.getAuthor().getID())
				voteMessage = msg.getChannel().sendMessage(printVote(vote.get("skip")))
			else
				vote.toggle("skip", 1, msg.getAuthor().getID())
			end
			
			local votesNeeded = math.floor((getConnectedUsers().count-1)/2)+1
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
]]
--------------
---- Init ----
--------------
local voiceChannels = discord.getConnectedVoiceChannels()	-- Leave all voice channels on init

for i, channel in pairs(voiceChannels) do
	channel.leave()
end