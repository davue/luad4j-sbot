local players = {} -- Player table
local fields = {} -- Fields table
local turn = 0	-- Which player plays next
local status = "" -- Status message

local gameMessage = nil -- Message object of game

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
	message = message.."  ├───┼───┼───┤	"..players[1].name..": "..players[1].score.."\n"
	message = message.."C │ ".. fields[7] .." │ ".. fields[8] .." │ ".. fields[9] .." │	"..players[2].name..": "..players[2].score.."\n"
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
					
					return
				end
			end
			
			if(players[1].id == "none" and players[2].id == "none") then -- If there is space for another player
				if(players[1].id == "none") then -- Start new game
					gameMessage = nil -- Create new game message
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
						
						status = "Waiting for second player..."
						
						printGame(msg.getChannel()) -- Update message
					elseif(players[1].id ~= "none") then -- If there is only one player left
						reset()
						printGame(msg.getChannel()) -- Update message
					end
					
					return
				end
			end
			
			local info = msg.getChannel().sendMessage("[INFO][TTT] You can't leave if you're not playing.")
			setTimer(5000, function() -- Delete message after 5 seconds
				info.delete()
			end)
		elseif(string.find(args[1], "%a%d") ~= nil) then -- If a player wants to make a turn
			-- Get field
			local char, num = string.match(args[1], "(%a)(%d)")
			
			-- TODO: implement game logic
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