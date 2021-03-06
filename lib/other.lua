--[[ Other Lib - Docs:
This library is just a random collection of functions which don't fit into another library.

deepcopy(variable)
	Makes a true copy (not just a reference) of a given variable.
	
table.show(table)
	Returns a readable representation of a table as string.
]]

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

function table_print (tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    local sb = {}
    for key, value in pairs (tt) do
      table.insert(sb, string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        table.insert(sb, "{\n");
        table.insert(sb, table_print (value, indent + 2, done))
        table.insert(sb, string.rep (" ", indent)) -- indent it
        table.insert(sb, "}\n");
      elseif "number" == type(key) then
        table.insert(sb, string.format("\"%s\"\n", tostring(value)))
      else
        table.insert(sb, string.format(
            "%s = \"%s\"\n", tostring (key), tostring(value)))
       end
    end
    return table.concat(sb)
  else
    return tt .. "\n"
  end
end

function to_string( tbl )
    if  "nil"       == type( tbl ) then
        return tostring(nil)
    elseif  "table" == type( tbl ) then
        return table_print(tbl)
    elseif  "string" == type( tbl ) then
        return tbl
    else
        return tostring(tbl)
    end
end

function table.show(tbl)
  local charS,charE = "   ","\n"
  local file = ""
  if err then return err end

  -- Initiate variables for display procedure
  local tables,lookup = { tbl },{ [tbl] = 1 }
  file = file .. ( "return {"..charE )

  for idx,t in ipairs( tables ) do
	 file = file .. ( "-- Table: {"..idx.."}"..charE )
	 file = file .. ( "{"..charE )
	 local thandled = {}

	 for i,v in ipairs( t ) do
		thandled[i] = true
		local stype = type( v )
		-- Only handle value
		if stype == "table" then
		   if not lookup[v] then
			  table.insert( tables, v )
			  lookup[v] = #tables
		   end
		   file = file .. ( charS.."{"..lookup[v].."},"..charE )
		elseif stype == "string" then
		   file = file .. (  charS..string.format("%q", v )..","..charE )
		elseif stype == "number" then
		   file = file .. (  charS..tostring( v )..","..charE )
		end
	 end

	 for i,v in pairs( t ) do
		-- Escape handled values
		if (not thandled[i]) then
		
		   local str = ""
		   local stype = type( i )
		   -- Handle index
		   if stype == "table" then
			  if not lookup[i] then
				 table.insert( tables,i )
				 lookup[i] = #tables
			  end
			  str = charS.."[{"..lookup[i].."}]="
		   elseif stype == "string" then
			  str = charS.."["..string.format("%q", i ).."]="
		   elseif stype == "number" then
			  str = charS.."["..tostring( i ).."]="
		   end
		
		   if str ~= "" then
			  stype = type( v )
			  -- Handle value
			  if stype == "table" then
				 if not lookup[v] then
					table.insert( tables,v )
					lookup[v] = #tables
				 end
				 file = file .. ( str.."{"..lookup[v].."},"..charE )
			  elseif stype == "string" then
				 file = file .. ( str..string.format("%q", v )..","..charE )
			  elseif stype == "number" then
				 file = file .. ( str..tostring( v )..","..charE )
			  end
		   end
		end
	 end
	 file = file .. ( "},"..charE )
  end
  file = file .. ( "}" )
  
  return file
end