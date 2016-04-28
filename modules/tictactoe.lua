local players = {} -- Player table
local fields = {} -- Fields table
local turn = 0	-- Which player plays next
local status = "" -- Status message

local gameMessage = nil -- Message object of game

local fieldmap = {A1=1, A2=2, A3=3, B1=4, B2=5, B3=6, C1=7, C2=8, C3=9} -- A mapping of field strings to indeces

local function reset() -- Resets the game
	players = {}
	players[1] = {}
	players[1].name = "none"
	players[1].id = "none"
	players[1].score = 0
	players[2] = {}
	players[2].name = "none"
	players[2].id = "none"
	players[2].score = 0
	
	players[0] = {}
	players[0].name = "none"
	
	fields = {}
	for i=1, 9 do
		fields[i] = " "
	end
	
	turn = 0
	status = "Waiting for players..."
end

local function toggleTurn()
	if(turn == 0) then
		turn = math.random(2) -- Randomly determine first turn
	elseif(turn == 1) then
		turn = 2
	elseif(turn == 2) then
		turn = 1
	else
		mainChannel.sendMessage("[ERROR] Unexpected behavior while toggling votes")
		turn = 0
	end
	
	status = "Waiting for turn..."
end

local function printGame(channel) -- Prints the game
	local message = "```    1   2   3\n"
	message = message.."  ┌───┬───┬───┐\n"
	message = message.."A │ ".. fields[1] .." │ ".. fields[2] .." │ ".. fields[3] .." │ Turn:	"..players[turn].name.."\n"
	message = message.."  ├───┼───┼───┤ Status:  "..status.."\n"
	message = message.."B │ ".. fields[4] .." │ ".. fields[5] .." │ ".. fields[6] .." │\n"
	message = message.."  ├───┼───┼───┤	"..players[1].name..":	"..players[1].score.."\n"
	message = message.."C │ ".. fields[7] .." │ ".. fields[8] .." │ ".. fields[9] .." │	"..players[2].name..":	"..players[2].score.."\n"
	message = message.."  └───┴───┴───┘```"
	
	if(gameMessage == nil) then
		gameMessage = channel.sendMessage(message)
	else
		gameMessage.edit(message)
	end
end

command.add("ttt", function(msg, args)
	if(#args > 0) then
		if(args[1] == "join") then -- If a player wants to join
			for k, v in pairs(players) do	-- Check if user is already playing
				if(msg.getAuthor().getID() == v.id) then
					local info = msg.getChannel().sendMessage("[INFO][TTT] You are already playing.")
					setTimer(5000, function() -- Delete message after 5 seconds
						info.delete()
					end)
					
					msg.delete()
					return
				end
			end
			
			if(players[1].id == "none" or players[2].id == "none") then -- If there is space for another player
				if(players[1].id == "none") then -- Start new game
					--gameMessage = nil -- Create new game message
					reset() -- Reset game
					players[1].name = msg.getAuthor().getName()
					players[1].id = msg.getAuthor().getID()
					status = "Waiting for second player..." 
				else
					players[2].name = msg.getAuthor().getName()
					players[2].id = msg.getAuthor().getID()
					
					-- Reset score
					players[1].score = 0
					players[2].score = 0
					
					-- Determine first turn
					toggleTurn()
				end
				
				printGame(msg.getChannel()) -- Update message
			else
				local info = msg.getChannel().sendMessage("[INFO][TTT] There are already 2 players.")
				setTimer(5000, function() -- Delete message after 5 seconds
					info.delete()
				end)
			end
		elseif(args[1] == "leave") then -- If a player wants to leave
			for k, v in pairs(players) do	-- Check if player is playing
				if(msg.getAuthor().getID() == v.id) then
					if(players[1].id ~= "none" and players[2].id ~= "none") then -- If there are 2 players playing
						if(k == 1) then -- If player 1 wants to leave
							-- Move player 2 to player 1
							tempplayer = deepcopy(players[2])
							players[1] = tempplayer
						end
						
						-- Reset player 2
						players[2].name = "none"
						players[2].id = "none"
						
						-- Reset score
						players[1].score = 0
						players[2].score = 0
						
						turn = 0
						
						status = "Waiting for second player..."
						
						printGame(msg.getChannel()) -- Update message
					elseif(players[1].id ~= "none") then -- If there is only one player left
						reset()
						printGame(msg.getChannel()) -- Update message
					end
					
					msg.delete()
					return
				end
			end
			
			local info = msg.getChannel().sendMessage("[INFO][TTT] You can't leave if you're not playing.")
			setTimer(5000, function() -- Delete message after 5 seconds
				info.delete()
			end)
		elseif(string.find(args[1], "%a%d") ~= nil) then -- If a player wants to make a turn
			if(players[1].id ~= "none" and players[2].id ~= "none") then -- If there are 2 players
				local playernum
				for k, v in pairs(players) do	-- Determine player number
					if(msg.getAuthor().getID() == v.id) then
						playernum = k
						break
					end
				end
				
				if(turn == playernum) then -- If it's the players turn
					if(fields[fieldmap[args[1]]] ~= nil) then
						if(fields[fieldmap[args[1]]] == " ") then
							if(playernum == 1) then
								fields[fieldmap[args[1]]] = "X"
							else
								fields[fieldmap[args[1]]] = "O"
							end
							
							-- TODO: Check for winner
							
							printGame(msg.getChannel()) -- Update message
						else
							local info = msg.getChannel().sendMessage("[INFO][TTT] "..args[1].." is already occupied.")
							setTimer(5000, function() -- Delete message after 5 seconds
								info.delete()
							end)
						end
					else
						local info = msg.getChannel().sendMessage("[INFO][TTT] Unknown field: "..args[1])
						setTimer(5000, function() -- Delete message after 5 seconds
							info.delete()
						end)
					end
				else
					local info = msg.getChannel().sendMessage("[INFO][TTT] It's not your turn.")
					setTimer(5000, function() -- Delete message after 5 seconds
						info.delete()
					end)
				end
			else
				local info = msg.getChannel().sendMessage("[INFO][TTT] 2 Players are needed to play.")
				setTimer(5000, function() -- Delete message after 5 seconds
					info.delete()
				end)
			end
		else
			local info = msg.getChannel().sendMessage("[WARN][TTT] Invalid parameters.")
			setTimer(5000, function() -- Delete message after 5 seconds
				info.delete()
			end)
		end
	else
		msg.getChannel().sendMessage("[INFO][TTT] Usage:\nttt join: Joins the game.\nttt leave: Leaves the game.\nttt <field>: Sets your sign to the given field.")
	end
	
	msg.delete()
end)

reset() -- Reset game

--[[
    1   2   3
  ┌───┬───┬───┐
A │ X │ X │ X │ Turn:	Dave-it
  ├───┼───┼───┤ Status: Dave-it's turn
B │ X │ X │ X │
  ├───┼───┼───┤	Dave-it:	0
C │ X │ X │ X │	Markus: 	1
  └───┴───┴───┘
]]