--NAMPanels v0.0.0
local api, list, actions, objects = {}, parseJson(file:readString("./host/config/panels.json")), {}, {}
local key, f3 = keybinds:fromVanilla("figura.config.action_wheel_button"), keybinds:newKeybind("f3", "key.keyboard.f3")
models:newPart("gui"):setParentType("Gui"):visible(false)

--element types
local function createElement(attr, parent)
	local obj = (parent or models.gui):newPart(client:intUUIDToString(client:generateUUID()))
	table.insert(objects, {obj = obj, attr = attr})
	return obj, attr
end

local function getRenderTaskDescendants(part, tbl)
	local _tbl = tbl or {}
	for k, v in pairs(part:getTask()) do _tbl[k] = v end
	for _, v in pairs(part:getChildren()) do getRenderTaskDescendants(v, _tbl) end
	return _tbl
end

local function createButton(x, y, w, h, text, func)
	local elem, _attr = createElement({
		scale = vec(w, h),
		region = vec(200, 20),
		offset = {40, 60},
		action = func,
		func = function(action, coords, obj, attr, hover, ren)
			ren.btn:region(attr.region):size(attr.scale)
				:uvPixels(0, attr.offset[hover and 2 or 1])
			ren.text:pos(attr.scale.x * -1 / 2, (attr.scale.y * -1 / 2) + client:getTextHeight(attr.text) / 2)
			if hover and action == 0 then 
				attr.action()
			end
		end
	})
	elem:pos(x * -1, y * -1):newSprite("btn"):setTexture("textures/gui/slider.png", 256, 256)
	elem:newText("text"):setText(text):alignment("CENTER")
	return _attr
end

local function createSlider(x, y, w, h, text, func, range)
	local elem, _attr = createElement({
		value = 0,
		scale = vec(w, h),
		region = vec(200, 20),
		offset = {40, 60},
		bounds = vec(range[1], range[2]),
		action = func,
		text = text,
		func = function(action, coords, obj, attr, hover, ren)
			ren.sliderBg:region(attr.region)
				:size(attr.scale)
			ren.btn:region(attr.region)
				:size(attr.scale.x / (attr.bounds.y - attr.bounds.x), attr.scale.y)
				:uvPixels(0, attr.offset[hover and 2 or 1])
			ren.text:pos(attr.scale.x * -1 / 2, (attr.scale.y * -1 / 2) + client:getTextHeight(attr.text) / 2)
				:setText(attr.text .. " (" .. math.round(attr.value) .. ")")
			if hover and action == 1 then
				local btnPos = math.clamp(coords.x - ren.btn:getSize().x / -2, attr.scale.x * -1 + ren.btn:getSize().x, 0)
				if attr.value ~= math.map(btnPos, 0, attr.scale.x * -1 + ren.btn:getSize().x, attr.bounds.x, attr.bounds.y) then
					attr.value = math.map(btnPos, 0, attr.scale.x * -1 + ren.btn:getSize().x, attr.bounds.x, attr.bounds.y)
					attr.action(attr.value)
				end
				ren.btn:pos(btnPos, 0)
			end
		end
	})
	elem:pos(x * -1, y * -1):newSprite("sliderBg"):setTexture("textures/gui/slider.png", 256, 256)
	elem:newSprite("btn"):setTexture("textures/gui/slider.png", 256, 256)
	elem:newText("text"):alignment("CENTER")
	return _attr
end

local function createRadio(x, y, w, h, text, func, _, options)
	local elem, _attr = createElement({
		value = 0,
		options = options,
		scale = vec(w, #options * h + 20),
		action = func,
		func = function(action, coords, obj, attr, hover, ren)
			ren.radioBg:size(attr.scale)
			ren.title:pos(attr.scale.x * -1 / 2, -10)
		end
	})
	elem:pos(x * -1, y * -1):newSprite("radioBg"):setTexture("textures/gui/advancements/widgets.png", 256, 256)
		:region(24, 24)
		:uvPixels(1, 155)
	elem:newText("title"):alignment("CENTER"):text(text)
	for i, v in ipairs(options) do
		local obj, option = createElement({
			value = v,
			scale = vec(_attr.scale.x, 20),
			region = vec(200, 20),
			offset = {40, 60},
			func = function(action, coords, obj, attr, hover, ren)
				ren.btn:region(attr.region):size(attr.scale)
					:uvPixels(0, attr.offset[hover and 2 or 1])
				if hover and action == 0 then
					_attr.action(attr.value)
				end
			end
		}, elem)
		obj:pos(0, i * -20)
		obj:newSprite("btn"):setTexture("textures/gui/slider.png", 256, 256)
		obj:newText("text"):alignment("CENTER"):text(option.value)
			:pos(option.scale.x * -1 / 2, (option.scale.y * -1 / 2) + client:getTextHeight(option.value) / 2)
	end
	return _attr
end

local previousPage, currentPage = nil, false
local function createPage(page)
	previousPage = currentPage
	local offset, presetTbl = 0, {
		button = createButton,
		slider = createSlider,
		radio = createRadio
	}
	for i, v in ipairs(objects) do
		v.obj:remove()
		objects[i] = nil
	end
	for k, v in pairs(page) do
		local width, elem = client:getTextWidth(k) + 40, nil
		if presetTbl[v.type] then
			elem = presetTbl[v.type](0, offset, width, 20, k, actions[v.func], v.range, v.options)
		else
			elem = createButton(0, offset, width, 20, k, function() currentPage = k end)
		end
		offset = offset + elem.scale.y
	end
	presetTbl["button"](0, offset, 20, 20, ":cancel:", function() currentPage = nil end)
end

--api
function api.newAction(name, func)
	actions[name] = func
end

--controls
key.press = function()
	if f3:isPressed() then return false end
	models.gui:visible(true)
	host:setUnlockCursor(true)
	return true
end

key.release = function()
	models.gui:visible(false)
	host:setUnlockCursor(false)
end

local clickState = nil
function events.mouse_press(_, action)
	if models.gui:getVisible() then clickState = action end
end

--main render loop
function events.render()
	local coords = client:getMousePos() / 2
	if previousPage ~= currentPage then
		previousPage = currentPage
		createPage(list[currentPage] or list) 
	end
	for _, v in pairs(objects) do
		local parentPos = v.obj:getParent():getPos()
		local pos = vec(v.obj:getPos().x + parentPos.x, v.obj:getPos().y + parentPos.y) * -1
		local isHovering = coords > pos and coords < pos + v.attr.scale
		v.attr.func(clickState, coords * -1, v.obj, v.attr, isHovering, getRenderTaskDescendants(v.obj))
	end
	if clickState and clickState < 1 then clickState = nil end
end

return api