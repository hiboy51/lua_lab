require("functional.functional")

function customSort(t) 
	local keys = {}
	fn.foreach(t, function(k, v, ct) 
		keys[#keys + 1] = k
	end)

	table.sort(keys)

	return keys, t
end

function serializeTable(t)
	-- t是属性
	if type(t) ~= "table" then return tostring(t) end
	
	-- t是table
	local result = ""
	local sortKeys = customSort(t) 

	fn.foreach(sortKeys, function(k, v, curT) 	--递归序列化
		result = result .. tostring(v) .. serializeTable(t[v])
	end)
	return result
end

local testT = {
	b = "bbbb",
    c = {
        e = "eee",
		d = 22.012,
        f = {
			g = 33,
            h = "hhh"
        }
    },
	a = 11
}

print(serializeTable(testT))