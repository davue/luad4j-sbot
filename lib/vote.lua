vote = {}

local votelist = {}

function vote.start(identifier, ...)
	args = {...}
	
	if(#args >= 2) then
		local voteTable = {}			-- Table containing information about the vote
		voteTable.question = args[1]	-- Set the question
		voteTable.answers = {}
		table.remove(args, 1)
		
		for k, v in pairs(args) do
			voteTable.answers[k] = {}
			voteTable.answers[k].name = v
			voteTable.answers[k].votes = {}
			voteTable.answers[k].votes.count = 0
		end
		
		votelist[identifier] = voteTable;	-- Insert vote into votelist
	end
end

function vote.get(identifier)
	return votelist[identifier]
end

function vote.stop(identifier)
	if(votelist[identifier] ~= nil) then	-- If vote is still running
		votelist[identifier] = nil
	end
end

function vote.toggle(identifier, ansnum, userID)
	if(votelist[identifier] ~= nil) then
		if(votelist[identifier].answers[tonumber(ansnum)] ~= nil) then
			if(votelist[identifier].answers[tonumber(ansnum)].votes[userID] == nil) then
				votelist[identifier].answers[tonumber(ansnum)].votes[userID] = 1
				votelist[identifier].answers[tonumber(ansnum)].votes.count = votelist[identifier].answers[tonumber(ansnum)].votes.count + 1
			else
				votelist[identifier].answers[tonumber(ansnum)].votes[userID] = nil
				votelist[identifier].answers[tonumber(ansnum)].votes.count = votelist[identifier].answers[tonumber(ansnum)].votes.count - 1
			end
		end
	end
end

function vote.startTimed(identifier, channel, printfunc, callback, delay, ...)
	vote.start(identifier, ...)				-- Start vote normally
	setTimer(delay, vote.stop(identifier))	-- Stop it after <delay> ms
end