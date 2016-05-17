command.add("volvopls", function(msg, args)
	if(#args > 0) then
		local text = string.sub(msg.getContent(), 11)
		msg.getChannel().sendMessage("༼ つ ◕_◕ ༽つ "..text)
	else
		msg.getChannel().sendMessage("[INFO] Usage: volvopls <text>")
	end
	
	msg.delete()
end)