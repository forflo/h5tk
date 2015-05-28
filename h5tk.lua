local pkg_builder

local err_wrong_tag = "Wrong tag has been given!"
local err_twice_tag = "This bug could not have happened, please report it!"

local buffer_get, buffer_tostring, buffer_add
local is_html_normal, is_html_special
local tree_get, tree_addnode
local fmt_traverse_attr, fmt_traverse_data
local fmt_traverse_aux_data, fmt_traverse_aux_attr
local fast_traverse_aux, fast_traverse_attr, fast_traverse_data
local fmt_helper, fast_helper
	
local html_elements_special = 
    " area base br col embed track hr source param meta img link keygen input "

local html_elements_normal = 
    " a abbr address article aside audio b bdi bdo blockquote body button canvas caption" ..
    " code colgroup datalist dd del	details dfn dialog div dl dt em fieldset figcaption" ..
    " figure footer form h1 h2 h3 h4 h5 h6 head header html i iframe ins kbd label legend" ..
    " li main map mark menu menuitem meter nav noscript object ol optgroup option output" ..
    " p pre progress q rp rt ruby s samp script section select small span style sub summary" ..
    " sup table tbody td textarea tfoot th thead time title tr u ul var video wbr "

function buffer_get()
	return {""}
end

function buffer_tostring(buffer)
	return table.concat(buffer)
end

function buffer_add(buffer, string)
	buffer[#buffer + 1] = string
end

function is_html_normal(string)
	if string.find(html_elements_normal, " " .. string .. " ") then
		return true
    else
	    return false
    end
end

function is_html_special(string)
	if string.find(html_elements_special, " " .. string .. " ") then
		return true
	else
		return false
	end	
end

function tree_get()
	return {}
end

function tree_addnode(tree, value)
	tree[#tree + 1] = value
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
			buffer_add(attr, fast_traverse_aux(v) .. "\"")
		end
	end
	
	return buffer_tostring(attr)
end

function fmt_helper(sub, html)
	local tree = tree_get()
	local n, s = is_html_normal(sub), is_html_special(sub)
	setmetatable(tree, {"h5tk"})

	if not s and not n then error(err_wrong_tag .. " " .. sub) end
	if s and n then error(err_twice_tag .. " " .. sub) end
	
	tree_addnode(tree, "<" .. sub .. fmt_traverse_attr(html) .. ">")
	if n then
		tree_addnode(tree, fmt_traverse_data(html))
		tree_addnode(tree, "</" .. sub .. ">")
	end

	return tree
end

function fast_helper(sub, html)
	local buf = buffer_get()
	local n, s = is_html_normal(sub), is_html_special(sub)

	if not s and not n then error(err_wrong_tag .. " " .. sub) end
	if s and n then error(err_twice_tag .. " " .. sub) end

	buffer_add(buf, "<" .. sub)
	buffer_add(buf, fast_traverse_attr(html))
	buffer_add(buf, ">")

	if n then
		buffer_add(buf, fast_traverse_data(html))
		buffer_add(buf, "</" .. sub .. ">")
	end

	return buffer_tostring(buf)					
end
	
function emitter_builder(format, n_spaces, tabs)
	local emitter  = {}

	local this_format = format
	local this_num_sep = n_spaces
	local this_use_tabs = tabs 
	local this_lvl_sep = ""

	local tree_collapse
	local fmt_add_sep, fmt_calc_sep
	local emit

	if type(format) == "boolean" then this_format = format else
		this_format = true
	end
	if type(n_spaces) == "number" then this_num_sep = n_spaces else
		this_num_sep = 4
	end
	if type(tabs) == "boolean" then this_use_tabs = tabs else
		this_use_tabs = false
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
	
	
	function fmt_add_sep(lvl, string)
		local buf = buffer_get()
	
		for i=1,lvl do
			buffer_add(buf, this_lvl_sep)
		end
		buffer_add(buf, string)
		return buffer_tostring(buf)
	end
	
	function fmt_calc_sep()
		local sep = " "
		local buf = buffer_get()
		if this_use_tabs then sep = "\t" end
	
		for i=1,this_num_sep do
			buffer_add(buf, sep)
		end
		
		return buffer_tostring(buf)
	end
	
	function emit(tree)
		if this_format then
			return tree_collapse(0, tree)
		else
			return tree
		end
	end

	this_lvl_sep = fmt_calc_sep()
	emitter.emit = emit	
	return emitter
end

function init(format, n_spaces, tabs)
    local h5tk_instance
	local h5tk_meta = { __index = nil}
	local emitter = emitter_builder(format, n_spaces, tabs)

	if format then
		h5tk_meta.__index = function(tab, sub)
			return function(html)
				return fmt_helper(sub, html)
			end
		end
	else
		h5tk_meta.__index = function(tab, sub)
			return function(html)
				return fast_helper(sub, html)
			end
		end
	end

	h5tk_instance = { emit = emitter.emit }
	setmetatable(h5tk_instance, h5tk_meta)

	return h5tk_instance
end

return { init = init }
