local storage = minetest.get_mod_storage()
function genlist()
    local fspec = "size[9,2.5]dropdown[0,0.1;5.3,1;list;"..storage:get_string('list').." ;]button_exit[5,0;2,1;load;Teleport]field[0.3,2;5,1;name;Name:;]button_exit[5,1.7;2,1;save;Save]button[7,0;2,1;del;Delete]button[7,1.7;2,1;delall;Clear list]"
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
      local pos = core.pos_to_string(vector.round(core.localplayer:get_pos())):gsub('[()]','')
        if fields.name then fields.name = fields.name:gsub('[;%]%[%%%%-%+%?%(%)]','') end --glitch protection!
		if fields.save then
            storage:set_string('list',storage:get_string('list')..fields.name..' at '..core.formspec_escape(pos)..',')
            minetest.display_chat_message('Saved "'..minetest.colorize('#FF0',fields.name)..'" at '..minetest.colorize('#FF0',pos))
        elseif fields.del then
            storage:set_string('list',storage:get_string('list'):gsub(core.formspec_escape(fields.list):gsub('([^%w])','%%%1')..',',''))
            core.show_formspec('tplist',genlist())
        elseif fields.delall then
            storage:set_string('list',nil)
            core.show_formspec('tplist',genlist())
        elseif fields.load then
             core.run_server_chatcommand('teleport',fields.list:gsub('.+at ',''))
	end
	end
end)
