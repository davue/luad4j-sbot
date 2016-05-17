command.add("volvopls", function(msg, args)
	if(#args > 0) then
		local text = string.sub(msg.getContent(), 11)
		msg.edit("༼ つ ◕_◕ ༽つ "..text)
	else
		msg.getChannel().sendMessage("[INFO] Usage: volvopls <text>")
		msg.delete()
	end
end)