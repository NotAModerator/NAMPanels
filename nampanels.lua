--nampanels v0.1
local key, f3 = keybinds:fromVanilla("figura.config.action_wheel_button"), keybinds:newKeybind("f3", "key.keyboard.f3")
local api, elems, objects, cfg, actions = {}, {}, {}, {path = nil}, {}
models:newPart("gui", "Gui"):visible(false):light(15)

local function cloneTable(tbl)
	local clone = {}
	for k, v in pairs(tbl) do clone[k] = v end
	return clone
end

local function getAscendants(part, tbl)
	local tbl = tbl or {}
	if part:getParent() then
		tbl[part:getParent():getName()] = part:getParent()
		getAscendants(part:getParent(), tbl)
	end
	return tbl
end

local function getDescendants(obj, tbl)
	local tbl = tbl or {}
	for k, v in pairs((obj.part or obj):getChildren()) do
		local chld = objects[v:getName()] or v
		if chld then
			if type(chld) == "table" then table.insert(tbl, chld) end
			if #v:getChildren() > 0 then getDescendants(chld, tbl) end
		end
	end
	return tbl
end

local function addObject(name, obj, parent)
	local uuid = tostring(client:generateUUID())
	local part = (parent or models.gui):newPart(uuid)
	objects[uuid] = cloneTable(elems[obj.type].attr)
	objects[uuid].dat = {
		name = name, 
		obj = obj, 
		func = actions[obj.func],
		type = obj.type
	}
	objects[uuid].init(part, objects[uuid])
	if elems[obj.type].nestable then
		for k, v in pairs(obj) do 
			if type(v) ~= "string" then addObject(k, v, objects[uuid].anchor or objects[uuid].part) end
		end
	end
end

function api.config(path)
	if cfg.path == path then return end
	cfg, objects = {path = path, json = {parseJson(file:readString(path))}}, {}
	for _, v in pairs(models.gui:getChildren()) do v:remove() end
	for k, v in pairs(cfg.json) do addObject(k, v, nil) end
end

function api.addElementType(name, attr, nestable) elems[name] = {attr = attr, nestable = nestable} end

function api.newAction(name, func) actions[name] = func end

key.press = function()
	if f3:isPressed() then return false end
	models.gui:visible(true)
	host:setUnlockCursor(true)
	renderer:setRenderCrosshair(false)
	return true
end

key.release = function()
	models.gui:visible(false)
	host:setUnlockCursor(false)
	renderer:setRenderCrosshair(true)
end

local clickState, scroll = nil, 0
function events.mouse_press(_, action)
	if models.gui:getVisible() then clickState = action end
end

function events.mouse_scroll(delta)
	if models.gui:getVisible() then 
		scroll = delta 
		return true
	end
end

function events.render()
	if not models.gui:getVisible() then return end
	local coords = client:getMousePos() / client:getGuiScale()
	for _, v in pairs(objects) do
		local pos = vec(0, 0, 0)
		local descend = getDescendants(v)
		for _, d in pairs(getAscendants(v.part)) do pos = pos - d:getPos() end
		v.func(v, pos.xy - v.part:getPos().xy, descend, coords, clickState, scroll)
	end
	if clickState and clickState < 1 then clickState = nil end
	scroll = 0
end

return api