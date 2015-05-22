-- config vars

local traverse_aux, traverse_attr, traverse_data
local get_buffer, buffer_tostring, fastAdd

-- string buffer
function get_buffer()
	return {""}
end

function buffer_tostring(buffer)
	return table.concat(buffer)
end

function fastAdd(buffer, string)
	buffer[#buffer + 1] = string
end

-- ausillary table traversal function
function traverse_aux(value)
	if not value then
		return ""
	end
	
	if type(value) == "string" then
		return value
	elseif type(value) == "table" then
		local buf = get_buffer()
		fastAdd(buf, traverse_attr(value))
		fastAdd(buf, traverse_data(value))
		return buffer_tostring(buf)
	elseif type(value) == "number" then
		return tostring(value)
	elseif type(value) == "function" then
		return traverse_aux(value())
	elseif type(value) == "boolean" then
		return tostring(value)
	elseif type(value) == "nil" then
		return "nil"
	elseif type(value) == "userdata" then
		return "userdata"
	elseif type(value) == "thread" then
		return "thread"
	end
end

-- queries all 
function traverse_data(table)
	local data = get_buffer()

	for k, v in pairs(table) do
		if type(k) == "number" then
			fastAdd(data, traverse_aux(v))
		end
	end
	
	return buffer_tostring(data)
end

-- queries all values with string keys
function traverse_attr(table)
	local attr = get_buffer()

	for k, v in pairs(table) do
		if type(k) == "string" then
			fastAdd(attr, " " .. k .. "=")
			fastAdd(attr, traverse_aux(v))
		end
	end
	
	return buffer_tostring(attr)
end


local h5tk = {}
-- meta table
local meta = {
	-- gets called if h5tk is accessed by a string key
	__index = function(tab, sub)
		return function(html)
			local buf = get_buffer()
			
			fastAdd(buf, "<" .. sub)
			fastAdd(buf, traverse_attr(html))
			fastAdd(buf, ">")
			fastAdd(buf, traverse_data(html))
			fastAdd(buf, "</" .. sub .. ">")
			
			return buffer_tostring(buf)
		end
	end
}

setmetatable(h5tk, meta)
return h5tk
