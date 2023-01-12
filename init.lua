local s = core.get_mod_storage()
local F = core.formspec_escape
local selected = 1
local list = {}
local wps = {}

local function addwp(name, strpos)
	if not wps[name] then
		wps[name] = core.localplayer:hud_add({
			hud_elem_type = "waypoint",
			name = name,
			number = 0xFFFF00,
			text = " ("..strpos..")",
			world_pos = core.string_to_pos(strpos)})
	end
end
local function rmwp(name)
	core.localplayer:hud_remove(wps[name])
	wps[name] = nil
end

local function tpl_fs()
	list = {}
	local stable = s:to_table().fields
	local list_pos = {}
	for name,strpos in pairs(stable) do
		table.insert(list,name)
		table.insert(list_pos,F(name)..","..F(strpos)..(wps[name] and ", WP" or ","))
	end
	table.sort(list)
	table.sort(list_pos)
	local privs = core.get_privilege_list()
	local fs = "size[7,9]" ..
		"field[0.3,0.4;3.9,1;new;Name;]" ..
		"field[4,0.4;2.4,1;pos;pos (x y z);]" ..
		"button[5.9,0.1;1.2,1;save;Save]" ..
		"tablecolumns[text;text;text]" ..
		"table[0,1;5,8;list;"..table.concat(list_pos,",")..";]" ..
		"button[5.1,0.9;2,1;wp;Add WayPoint]" ..
		"button[5.1,1.7;2,1;rwp;Remove WP]" ..
		"button[5.1,2.5;2,1;rwps;Remove all WPs]" ..
		(privs.teleport and "button[5.1,3.3;2,1;tp;Teleport]" or "") ..
		"button[5.1,7;2,1;rm;Remove]" ..
		"button[5.1,8.2;2,1;purge;Purge list]"
	core.show_formspec("tplist",fs)
end
core.register_chatcommand("tpl", {
  description = "Open TPList",
  func = function(param)
	tpl_fs()
end})

core.register_on_inventory_open(function(inventory)
	local ctrl = core.localplayer:get_control()
	if ctrl and ctrl.aux1 and ctrl.sneak then
		core.after(0,function()
			tpl_fs()
		end)
	end
end)

core.register_on_formspec_input(function(formname, fields)
	if formname ~= "tplist" then return end
	if fields.list then
		local evnt = core.explode_table_event(fields.list)
		selected = tonumber(evnt.row) or 1
	end
	if fields.save and fields.new and fields.new ~= "" then
		local ppos = vector.round(core.localplayer:get_pos())
		local strpos = ppos.x.." "..ppos.y.." "..ppos.z
		if fields.pos and fields.pos ~= "" then
			local check = core.string_to_pos(fields.pos)
			if not check then
				core.display_chat_message("Invalid pos")
				return
			end
			strpos = fields.pos
		end
		if strpos then
			s:set_string(fields.new, strpos)
		end
	end
	if fields.rm and list[selected] then
		s:set_string(list[selected],"")
		if wps[list[selected]] then
			rmwp(list[selected])
		end
	end
	if fields.purge then
		local stable = s:to_table().fields
		for name,strpos in pairs(stable) do
			s:set_string(name,"")
		end
		if wps ~= {} then
			for name,id in pairs(wps) do
				if id then
					core.localplayer:hud_remove(id)
					wps[name] = nil
				end
			end
		end
	end
	if fields.tp and list[selected] then
		core.run_server_chatcommand("teleport",s:get_string(list[selected]))
	end
	if fields.wp and list[selected] then
		local strpos = s:get_string(list[selected])
		addwp(list[selected],strpos)
	end
	if fields.rwp and wps[list[selected]] then
		rmwp(list[selected])
	end
	if fields.rwps and wps ~= {} then
		for name,id in pairs(wps) do
			if id then
				core.localplayer:hud_remove(id)
				wps[name] = nil
			end
		end
	end
	tpl_fs()
end)
