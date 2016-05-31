depends.onLib("command")
depends.onLib("other")

--------------
---- Init ----
--------------
local busy = false		-- If something is currently being queued
local cancel = false		-- If a user wants to cancel the queueing process
local audioPlayers = {} -- Table with audioPlayers depending on guilds

--------------------------
---- Helper Functions ----
--------------------------
local function getAudioPlayer(guildID)
	if(audioPlayers[guildID] == nil) then
		audioPlayers[guildID] = discord.getAudioPlayerForGuild(guildID)
		return audioPlayers[guildID]
	else
		return audioPlayers[guildID]
	end
end

------------------
---- Commands ----
------------------

--------------
-- Queueing --
--------------
command.add("weareone", function(msg, args)
	local audioPlayer = getAudioPlayer(msg.getGuild().getID())
	if(audioPlayer.playlistSize() == 0) then
		if(#args == 1 and (args[1] == "technobase" or args[1] == "housetime" or args[1] == "hardbase" or args[1] == "trancebase" or args[1] == "coretime" or args[1] == "clubtime")) then
			audioPlayer.queueURL("http://listen.".. args[1] ..".fm/tunein-mp3-pls").setTitle(string.upper(args[1][1])..string.sub(args[1],2))
		else
			msg.getChannel().sendMessage("[INFO] Usage: weareone (technobase/housetime/hardbase/trancebase/coretime/clubtime)")
		end
	else
		msg.getChannel().sendMessage("[INFO] There is already something queued.")
	end
	
	msg.delete()
end)

command.add("add", function(msg, args)
	if not busy then
		busy = true
		local audioPlayer = getAudioPlayer(msg.getGuild().getID())
		if(#args == 1) then
			local loaded = false
			if(string.find(args[1], "https?://w*%.?soundcloud%.com.+") ~= nil) then -- If it's a soundcloud link
				local info = os.capture("youtube-dl -i --no-playlist --get-title --get-id --playlist-items 1 ".. args[1], true)
				if(info ~= nil) then
					local title, id = string.match(info, "(.+)[\n\r]+(.+)[\n\r]+")
					local filepath = "/home/dave/discord/mp3/soundcloud/"..id..".mp3"
					local url = "http://api.soundcloud.com/tracks/"..id
					
					if(not file_exists(filepath)) then
						os.execute("youtube-dl -x --no-playlist --playlist-items 1 --audio-format mp3 -f bestaudio[filesize<50M] -o /home/dave/discord/mp3/soundcloud/%(id)s.%(ext)s ".. url) -- Download mp3 to ~/discord/mp3/(id).mp3
					end
					
					if(file_exists(filepath)) then
						audioPlayer.queueFile(filepath).setTitle(title) -- Queue file
						loaded = true
					else
						print("[LUA][addpl] Skipping: "..filepath)
					end
				end
			elseif(string.find(args[1], "https?://w*%.?youtube%.com.+") ~= nil) then -- If it's a youtube link
				local info = os.capture("youtube-dl -i --no-playlist --get-title --get-id --playlist-items 1 ".. args[1], true)
				if(info ~= nil) then
					local title, id = string.match(info, "(.+)[\n\r]+(.+)[\n\r]+")
					local filepath = "/home/dave/discord/mp3/youtube/"..id..".mp3"
					local url = "https://www.youtube.com/watch?v="..id
					
					if(not file_exists(filepath)) then
						os.execute("youtube-dl -x --no-playlist --audio-format mp3 -f bestaudio[filesize<50M] -o /home/dave/discord/mp3/youtube/%(id)s.%(ext)s ".. url) -- Download mp3 to ~/discord/mp3/(id).mp3
					end
					
					if(file_exists(filepath)) then
						audioPlayer.queueFile(filepath).setTitle(title) -- Queue file
						loaded = true
					else
						print("[LUA][addpl] Skipping: "..filepath)
					end
				end
			elseif(string.find(args[1], "https?://") ~= nil) then -- If it's another link
				audioPlayer.queueURL(args[1]).setTitle("<Direct Link>")
				loaded = true
			else -- It's probably a file
				if(file_exists(args[1])) then
					audioPlayer.queueFile(args[1]).setTitle("<Local File>")
				else
					msg.getChannel().sendMessage("[INFO] Couldn't find file: ".. args[1])
				end
				loaded = true
			end
			
			if not loaded then
				msg.getChannel().sendMessage("[INFO] Couldn't load audio.\n[INFO] Invalid URL or audio exceeding 50MB limit.")
			end
		else
			msg.getChannel().sendMessage("[INFO] Usage: add <url/file>\n[INFO] Supports Soundcloud, YouTube, direct links and local filepaths.")
		end
		
		busy = false
	else
		msg.getChannel().sendMessage("[INFO] There is already something being queued.\n[INFO] Wait for it to finish or !cancel it.")
	end
	
	msg.delete()
end)

command.add("addpl", function(msg, args)
	if not busy then
		busy = true
		local audioPlayer = getAudioPlayer(msg.getGuild().getID())
		if(#args >= 1) then
			if(string.find(args[1], "https?://w*%.?youtube%.com.+") ~= nil) then -- If it's a youtube link
				-- Concurrency workaround with timer instead of coroutine
				-- TODO: Find error why coroutine isn't working
				setTimer(1, function ()
					local status = nil
					local trackcount = 0
					
					if(#args == 1) then
						status = msg.getChannel().sendMessage("[INFO] Loading all videos from playlist...")
					
						i = 1
						while not cancel do							
							local info = os.capture("youtube-dl -i --yes-playlist --get-title --get-id --playlist-items ".. i .." ".. args[1], true)
							if(info ~= nil) then
								local title, id = string.match(info, "(.+)[\n\r]+(.+)[\n\r]+")
								local filepath = "/home/dave/discord/mp3/youtube/"..id..".mp3"
								local url = "https://www.youtube.com/watch?v="..id
								
								if(not file_exists(filepath)) then
									os.execute("youtube-dl -x --no-playlist --audio-format mp3 -f bestaudio[filesize<50M] -o /home/dave/discord/mp3/youtube/%(id)s.%(ext)s ".. url) -- Download mp3 to ~/discord/mp3/(id).mp3
								end
								
								if(file_exists(filepath)) then
									audioPlayer.queueFile(filepath).setTitle(title) -- Queue file
								else
									print("[LUA][addpl] Skipping: "..filepath)
								end
								i = i + 1
								trackcount = trackcount + 1
							else
								break -- Break loop if no more videos are fetched
							end
						end
					elseif(#args == 2) then -- If only the start is specified
						status = msg.getChannel().sendMessage("[INFO] Loading videos starting from index ".. args[2].. "...")
						
						i = args[2]
						while not cancel do							
							local info = os.capture("youtube-dl -i --yes-playlist --get-title --get-id --playlist-items ".. i .." ".. args[1], true)
							if(info ~= nil) then
								local title, id = string.match(info, "(.+)[\n\r]+(.+)[\n\r]+")
								local filepath = "/home/dave/discord/mp3/youtube/"..id..".mp3"
								local url = "https://www.youtube.com/watch?v="..id
								
								if(not file_exists(filepath)) then
									os.execute("youtube-dl -x --no-playlist --audio-format mp3 -f bestaudio[filesize<50M] -o /home/dave/discord/mp3/youtube/%(id)s.%(ext)s ".. url) -- Download mp3 to ~/discord/mp3/(id).mp3
								end
								
								if(file_exists(filepath)) then
									audioPlayer.queueFile(filepath).setTitle(title) -- Queue file
								else
									print("[LUA][addpl] Skipping: "..filepath)
								end
								i = i + 1
								trackcount = trackcount + 1
							else
								break -- Break loop if no more videos are fetched
							end
						end
					elseif(#args == 3) then
						status = msg.getChannel().sendMessage("[INFO] Loading videos from index ".. args[2].. " to ".. args[3] .."...")
					
						for i=args[2], args[3] do
							if cancel then -- Cancel logic
								cancel = false
								break
							end
							
							local info = os.capture("youtube-dl -i --yes-playlist --get-title --get-id --playlist-items ".. i .." ".. args[1], true)
							if(info ~= nil) then
								local title, id = string.match(info, "(.+)[\n\r]+(.+)[\n\r]+")
								local filepath = "/home/dave/discord/mp3/youtube/"..id..".mp3"
								local url = "https://www.youtube.com/watch?v="..id
								
								if(not file_exists(filepath)) then
									os.execute("youtube-dl -x --no-playlist --audio-format mp3 -f bestaudio[filesize<50M] -o /home/dave/discord/mp3/youtube/%(id)s.%(ext)s ".. url) -- Download mp3 to ~/discord/mp3/(id).mp3
								end
								
								if(file_exists(filepath)) then
									audioPlayer.queueFile(filepath).setTitle(title) -- Queue file
								else
									print("[LUA][addpl] Skipping: "..filepath)
								end
								trackcount = trackcount + 1
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
					
					busy = false
				end)
			else -- Invalid link format
				msg.getChannel().sendMessage("[INFO] Invalid link format.")
			end
		else
			msg.getChannel().sendMessage("[INFO] Usage: addpl <playlist url> [start] [end]\n[INFO] Supports only YouTube.")
		end
	else
		msg.getChannel().sendMessage("[INFO] There is already something being queued.\n[INFO] Wait for it to finish or !cancel it.")
	end
	
	msg.delete()
end)

command.add("cancel", function(msg,args)
	if busy then
		cancel = true
	else
		cancel = false
		msg.getChannel().sendMessage("[INFO] There is nothing to cancel.")
	end
	
	msg.delete()
end)

----------
-- Info --
----------
command.add("lssounds", function(msg, args)
	local lsStr = os.capture("ls sounds")
	local soundlist = ""
	for file in string.gmatch(lsStr, "%a+.wav") do 
		soundlist = soundlist .. file .. "\r\n"
	end
	msg.getChannel().sendMessage(soundlist)
end)

command.add("status", function(msg, args)
	local audioPlayer = getAudioPlayer(msg.getGuild().getID())
	msg.getChannel().sendMessage("```\nCurrent Track: ".. audioPlayer.getCurrentTrack().getTitle() .."\nQueue Length:  ".. audioPlayer.playlistSize() .."\nLooping:       ".. tostring(audioPlayer.isLooping()) .."\nVolume:        ".. audioPlayer.getVolume()*100 .."%\n```")
	msg.delete()
end)

command.add("track", function(msg, args)
	local audioPlayer = getAudioPlayer(msg.getGuild().getID())
	if(audioPlayer.playlistSize() > 0) then
		msg.getChannel().sendMessage("[INFO] Current track: `".. audioPlayer.getCurrentTrack().getTitle().."`")
	else
		msg.getChannel().sendMessage("[INFO] There is no queued audio.")
	end
	
	msg.delete()
end)

command.add("next", function(msg, args)
	local audioPlayer = getAudioPlayer(msg.getGuild().getID())
	if(audioPlayer.playlistSize() > 0) then
		local playlist = audioPlayer.getPlaylist()
		msg.getChannel().sendMessage("[INFO] Next track: `".. playlist[2].getTitle().."`")
	else
		msg.getChannel().sendMessage("[INFO] There is no queued audio.")
	end
	
	msg.delete()
end)

command.add("playlist", function(msg, args)
	local audioPlayer = getAudioPlayer(msg.getGuild().getID())
	if(audioPlayer.playlistSize() > 0) then
		local playlist = audioPlayer.getPlaylist()
		local message = "[INFO] Playlist:\n```"
		for k, track in pairs(playlist) do
			if(k == 1) then
				message = message.."-> "..track.getTitle().."\n"
			else
				message = message.. k-1 ..": "..track.getTitle().."\n"
			end
		end
		msg.getChannel().sendMessage(message.."```")
	else
		msg.getChannel().sendMessage("[INFO] There are no tracks in the playlist.")
	end
	msg.delete()
end)

---------------------
-- Channel Control --
---------------------
command.add("join", function(msg, args)
	local voiceChannels = msg.getGuild().getVoiceChannels()
	local connectedChannels = discord.getConnectedVoiceChannels()
	
	if(#voiceChannels == 1 and #args == 0) then -- if there is only one voice channel -> join this channel
		if(not voiceChannels[1].isConnected()) then
			voiceChannels[1].join()
		else
			msg.getChannel().sendMessage("[INFO] I'm already in the voice channel.")
		end
	elseif(#voiceChannels >= 1) then -- if there are more than one voice channels
		if(#args == 1) then -- when there are one or more arguments passed
			local channelExists = false;
			local alreadyInChannel = false;
			
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

-------------------
-- Audio Control --
-------------------
command.add("stop", function(msg, args)
	local audioPlayer = getAudioPlayer(msg.getGuild().getID())
	audioPlayer.skipTo(audioPlayer.playlistSize()+1)
	
	msg.delete()
end)

command.add("volume", function(msg, args)
	local audioPlayer = getAudioPlayer(msg.getGuild().getID())
	if(tonumber(args[1]) >= 0 and tonumber(args[1]) <= 1) then
		audioPlayer.setVolume(args[1])
		volume = args[1]
	else
		msg.getChannel().sendMessage("[INFO] Usage: volume <0 - 1>")
	end
	
	msg.delete()
end)

command.add("pause", function(msg, args)
	local audioPlayer = getAudioPlayer(msg.getGuild().getID())
	audioPlayer.setPaused(true)
	
	msg.delete()
end)

command.add("resume", function(msg, args)
	local audioPlayer = getAudioPlayer(msg.getGuild().getID())
	audioPlayer.setPaused(false)
	
	msg.delete()
end)

command.add("skip", function(msg, args)
	local audioPlayer = getAudioPlayer(msg.getGuild().getID())
	audioPlayer.skip()
	
	msg.delete()
end)

command.add("skipto", function(msg, args)
	if(#args == 1) then
		local audioPlayer = getAudioPlayer(msg.getGuild().getID())
		audioPlayer.skipTo(args[1])
	else
		msg.getChannel().sendMessage("[INFO] Usage: skipto <index>")
	end
	
	msg.delete()
end)

command.add("loop", function(msg, args)
	local audioPlayer = getAudioPlayer(msg.getGuild().getID())
	if(audioPlayer.isLooping()) then
		audioPlayer.setLoop(false)
		msg.getChannel().sendMessage("[INFO] Looping disabled.")
	else
		audioPlayer.setLoop(true)
		msg.getChannel().sendMessage("[INFO] Looping enabled.")
	end
	
	msg.delete()
end)

command.add("shuffle", function(msg, args)
	local audioPlayer = getAudioPlayer(msg.getGuild().getID())
	audioPlayer.shuffle()
	
	msg.delete()
end)