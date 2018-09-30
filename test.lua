require("functional.functional")
function isPureTable(tt)
	return fn.every(tt, function(k, v, curT) 
		return type(k) ~= "table" and type(v) ~= "table"	
	end)
end
function serializeTable(t) 
	local result = ""
	if isPureTable(t) then
		print("~~~~~~~~")
		table.sort(t)
		fn.foreach(t, function(k, v, curT) 
			result = result .. tostring(k) .. tostring(v)
		end)
		return result
	end
	
	table.sort(t)
	fn.foreach(t, function(k, v, curT) 
		print(k, v) 
		result = result .. tostring(k) .. serializeTable(v)
		print(result)
	end)
	return result
end

local testT = {
	b = "bbbb",
    c = {
        e = "eee",
		d = 22,
        f = {
			g = 33,
            h = "hhh"
        }
    },
	a = 11
}

-- print(table.sort(testT))

-- fn.foreach(testT, function(k, v, t) 
-- 	print(k, v)
-- end)

print(serializeTable(testT))