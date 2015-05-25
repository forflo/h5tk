-- config vars for init
local this_format = true
local this_num_sep = 2
local this_use_tabs = false

local fast_traverse_aux, fast_traverse_attr, fast_traverse_data
local fmt_traverse_attr, fmt_traverse_data, fmt_traverse_aux_data
local fmt_traverse_aux_attr, fmt_add_sep
local buffer_get, buffer_tostring, buffer_add
local emit, init
local tree_addnode, tree_collapse, tree_add_name
local tree_get 

-- string buffer
function buffer_get()
	return {""}
end

function buffer_tostring(buffer)
	return table.concat(buffer)
end

function buffer_add(buffer, string)
	buffer[#buffer + 1] = string
end

function tree_get()
	return {}
end

function tree_collapse(lvl, tree)
	local bigbuf = buffer_get()
	local meta = getmetatable(tree)

	for _, v in pairs(tree) do
		if type(v) == "table" then
			if meta == nil then
				buffer_add(bigbuf, tree_collapse(lvl, v))
			else
				buffer_add(bigbuf, tree_collapse(lvl + 1, v))
			end
		else
			buffer_add(bigbuf, fmt_add_sep(lvl, v) .. "\n")
		end
	end

	return buffer_tostring(bigbuf)
end

function tree_addnode(tree, value)
	tree[#tree + 1] = value
end

function tree_add_name(tree, name, value)
	if not (tree[name] == nil) then
		tree[name] = value
	end
end

function fmt_add_sep(lvl, string)
	local buf = buffer_get()
	local sep = " "
	if this_use_tabs then sep = "\t" end

	for i=1,lvl*this_num_sep do
		buffer_add(buf, sep)
	end
	buffer_add(buf, string)
	return buffer_tostring(buf)
end

-- auxillary table traversal function
-- returns either a scalar type or a 
-- table
function fmt_traverse_aux_data(tree)
	if tree == nil then
		return ""
	end
	
	if type(tree) == "string" then
		return tree
	elseif type(tree) == "table" then
		return fmt_traverse_data(tree)
	elseif type(tree) == "number" then
		return tostring(tree)
	elseif type(tree) == "function" then
		return fmt_traverse_data({tree()})
	elseif type(tree) == "boolean" then
		return tostring(tree)
	elseif type(tree) == "nil" then
		return "nil"
	elseif type(tree) == "userdata" then
		return "userdata"
	elseif type(tree) == "thread" then
		return "thread"
	end
end

-- collapses every table or evaluable function
-- to a single string
function fmt_traverse_aux_attr(tree)
	if tree == nil then
		return ""
	end
	
	if type(tree) == "string" then
		return tree
	elseif type(tree) == "table" then
		local buf = buffer_get()
		for k, v in pairs(tree) do
			buffer_add(buf, fmt_traverse_aux_attr(v))
		end
		return buffer_tostring(buf)
	elseif type(tree) == "number" then
		return tostring(tree)
	elseif type(tree) == "function" then
		return fmt_traverse_aux_attr(tree())
	elseif type(tree) == "boolean" then
		return tostring(tree)
	elseif type(tree) == "nil" then
		return "nil"
	elseif type(tree) == "userdata" then
		return "userdata"
	elseif type(tree) == "thread" then
		return "thread"
	end
end

-- queries all values with string keys and
-- folds the together to one single string
-- using fmt_traverse_aux_attr
function fmt_traverse_attr(tree)
	local attr = buffer_get()

	for k, v in pairs(tree) do
		if type(k) == "string" then
			buffer_add(attr, " " .. k .. "=\"")
			buffer_add(attr, fmt_traverse_aux_attr(v))
			buffer_add(attr, "\"")
		end
	end
	
	return buffer_tostring(attr)
end

-- ausillary table traversal function
function fast_traverse_aux(value)
	if value == nil then
		return ""
	end
	
	if type(value) == "string" then
		return value
	elseif type(value) == "table" then
		local buf = buffer_get()
		buffer_add(buf, fast_traverse_attr(value))
		buffer_add(buf, fast_traverse_data(value))
		return buffer_tostring(buf)
	elseif type(value) == "number" then
		return tostring(value)
	elseif type(value) == "function" then
		return fast_traverse_aux(value())
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
function fast_traverse_data(table)
	local data = buffer_get()

	for k, v in pairs(table) do
		if type(k) == "number" then
			buffer_add(data, fast_traverse_aux(v))
		end
	end
	
	return buffer_tostring(data)
end

-- queries all values with string keys
function fast_traverse_attr(table)
	local attr = buffer_get()

	for k, v in pairs(table) do
		if type(k) == "string" then
			buffer_add(attr, " " .. k .. "=\"")
			buffer_add(attr, fast_traverse_aux(v))
			buffer_add(attr, "\"")
		end
	end
	
	return buffer_tostring(attr)
end

function emit(tree)
	if this_format then
		return tree_collapse(0, tree)
	else
		return tree
	end
end

function fmt_traverse_data(source)
	local tree = tree_get()

	for k, v in pairs(source) do
		if type(k) == "number" then
			if type(v) == "table" and getmetatable(v) ~= nil then
				-- no traversal needed because it's the result of
				-- a h5tk function
				tree_addnode(tree, v)
			else
				tree_addnode(tree, fmt_traverse_aux_data(v))
			end
		end
	end

	return tree
end

function init(format, n_spaces, tabs)
	local meta = { __index = nil}

	if type(format) == "boolean" then this_format = format end
	if type(n_spaces) == "number" then this_num_sep = n_spaces end
	if type(tabs) == "boolean" then this_use_tabs = tabs end

	if format == true then
		-- meta table for package instance
		-- gets called if h5tk is accessed by a string key
		meta.__index = function(tab, sub)
			-- slower version. Correct formatting
			return function(html)
				local tree = tree_get()
				setmetatable(tree, {"h5tk"})

				tree_addnode(tree, "<" .. sub .. fmt_traverse_attr(html) .. ">")
				tree_addnode(tree, fmt_traverse_data(html))
				tree_addnode(tree, "</" .. sub .. ">")
			
				return tree
			end
		end
	else
		-- meta table for package instance
		meta.__index = function(tab, sub)
			-- gets called if h5tk is accessed by a string key
			return function(html)
				-- fast html generation
				local buf = buffer_get()
		
				buffer_add(buf, "<" .. sub)
				buffer_add(buf, fast_traverse_attr(html))
				buffer_add(buf, ">")
				buffer_add(buf, fast_traverse_data(html))
				buffer_add(buf, "</" .. sub .. ">")
		
				return buffer_tostring(buf)					
			end
		end
	end

	-- build package instance
	local h5tk = {
		emit = emit, 
		spaces = this_num_sep, 
		format = format_format,
		tabs = this_use_tabs
	}

	setmetatable(h5tk, meta)

	return h5tk
end

return {init = init}
