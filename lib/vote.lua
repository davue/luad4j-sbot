vote = {}

local votelist = {}

function vote.start(identifier, printfunc, callback, ...)
	args = {...}
	
	if(#args >= 2) then
		local voteTable = {}				-- Table containing information about the vote
		voteTable.print = printfunc	-- Set the print function
		voteTable.callback = callback	-- Set the callback function
		voteTable.question = args[1]	-- Set the question
		voteTable.answers = {}
		table.remove(args, 1)
		
		for k, v in pairs(args) do
			voteTable.answers[k].name = v
			voteTable.answers[k].count = 0
		end
		
		votelist[identifier] = voteTable;	-- Insert vote into votelist
	end
end

function vote.startTimed(identifier, callback, delay, ...)
	
end