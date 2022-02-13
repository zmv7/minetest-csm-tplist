local storage = minetest.get_mod_storage()
function genlist()
    local fspec = "size[10,5]field[0.3,0.5;3,1;name;Name:;]button_exit[0.5,1;2,1;load;Teleport]button_exit[0.5,2;2,1;save;Save]button[0.5,3;2,1;del;Delete]button[0.5,4;2,1;delall;Clear list]textarea[3.5,0;7,6;;List of saved coords:;"..storage:get_string('list').."]"
    return fspec
end
minetest.register_chatcommand("tpl", {
    description = "Open TPList",
    func = function(param)
core.show_formspec('tplist',genlist())
end})

core.register_on_inventory_open(function(inventory)
if core.localplayer:get_control().aux1 and core.localplayer:get_control().sneak then
    core.show_formspec('tplist',genlist())
end
end)

core.register_on_formspec_input(function(formname, fields)
	if formname == "tplist" then
           if fields.name then fields.name = fields.name:gsub('[;%]%[%%%%-%+%?%(%)]','') end --glitch protection!
        local pos = core.pos_to_string(vector.round(core.localplayer:get_pos())):gsub('[()]','')
		if fields.save then
		    storage:set_string(fields.name,pos)
            storage:set_string('list',storage:get_string('list')..fields.name..' at '..pos..'\n')
            minetest.display_chat_message('Saved "'..minetest.colorize('#FF0',fields.name)..'" at '..minetest.colorize('#FF0',pos))
        elseif fields.del then
            storage:set_string('list',storage:get_string('list'):gsub(fields.name..' at %-?%d+%p%-?%d+%p%-?%d+\n',''))
            storage:set_string(fields.name,nil)
            core.show_formspec('tplist',genlist())
        elseif fields.delall then
            storage:set_string('list',nil)
            core.show_formspec('tplist',genlist())
        elseif fields.load or fields.name then
		    storage:get_string(fields.name)
            core.run_server_chatcommand('teleport',storage:get_string(fields.name))
		end
	end
end)
