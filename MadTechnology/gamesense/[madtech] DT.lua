local MT = {
    reference = {},
    data = {},
    ui_get = ui['get'],
    ui_set = ui['set'],
    ui_set_visible = ui['set_visible'],
    ui_reference = ui['reference'],
    ui_new_checkbox = ui['new_checkbox'],
    ui_new_slider = ui['new_slider'],
    ui_new_combobox = ui['new_combobox'],
    ui_new_multiselect = ui['new_multiselect'],
    client_set_event_callback = client['set_event_callback'],
    chock = cvar['cl_clock_correction'],
    tonumber = tonumber,
    tostring = tostring,
    pcall = pcall,
    unpack = unpack,
    entity = entity,
    globals = globals,
    client_latency = client['latency'],
    client_camera_angles = client['camera_angles'],
    client_userid_to_entindex = client['userid_to_entindex'],
}

local vector = require "vector"


function MT:ui(name)
    local this = self['reference'][name]
    if not this then
        error(string.format("unknown reference %s", name))
    end
    return {
        call = function ()
            local list = {}
            for i=1, #this[1] do
                list[#list+1] = self['ui_get'](this[1][i])
            end
            return self['unpack'](list)
        end,
        set = function (_, value)
            self['pcall'](self['ui_set'], this[1][1], value)
        end,
        set_visible = function (_, stats)
            for i=1, #this[1] do
                self['ui_set_visible'](this[1][i], stats)
            end
        end
    }
end

function MT:ui_register(name, data)
    local reference_list = {}
    local cache = {self['pcall'](self['ui_reference'], self['unpack'](data))}
    if not cache[1] then
        error(string.format("%s cannot be defined (%s)", name, cache[2]))
    end
    if self['reference'][name] then
        error(string.format("%s is already taken in metatable", name))
    end
    for i=2, #cache do
        reference_list[#reference_list+1] = cache[i]
    end
    self['reference'][name] = {reference_list, data}
    return self:ui(name)
end

function MT:new_ui_register(element, name, data)
    local reference_list = {}
    local cache = {self['pcall'](self[element], self['unpack'](data))}
    if not cache[1] then
        error(string.format("%s cannot be create", name))
    end
    if cache[3] then
        for i=2, #cache do
            reference_list[#reference_list+1] = cache[i]
        end
    else
        reference_list[1] = cache[2]
    end
    self['reference'][name] = {reference_list}
    return self:ui(name)
end

local fakeduck = MT:ui_register("fakeduck", {"RAGE", "OTHER", "Duck peek assist"})
local doubletap = MT:ui_register("doubletap", {"RAGE", "OTHER", "Double tap"})
local doubletap_mode = MT:ui_register("doubletap_mode", {"RAGE", "OTHER", "Double tap mode"})
local doubletap_hitchance = MT:ui_register("doubletap_hitchance", {"RAGE", "OTHER", "Double tap hit chance"})
local doubletap_fakelaglimit = MT:ui_register("doubletap_fakelaglimit", {"RAGE", "OTHER", "Double tap fake lag limit"})
local fakelag_limit = MT:ui_register("fakelag_limit", {"AA", "Fake lag", "Limit"})
local maxprocticks = MT:ui_register("maxprocticks", {"MISC", "Settings", "sv_maxusrcmdprocessticks"})

local _doubletap_speed_values = {[1] = "Minimum", [2] = "Low", [3] = "Medium", [4] = "High", [5] = "Maximum"}
local _doubletap_modifier_values = {"Fast", "Fastest", "Break shift", "Adaptive"}
local _doubletap_options_values = {"Boost Accuracy", "Refresh on kill"}
local MTlocation = {"RAGE", "Other"}

local dt_master_switch = MT:new_ui_register("ui_new_checkbox", "dt_master_switch", {MTlocation[1], MTlocation[2], "[madtech] Double tap"})
local doubletap_modifier = MT['ui_new_combobox'](MTlocation[1], MTlocation[2], "Doubletap Modifier", _doubletap_modifier_values)
local doubletap_options = MT['ui_new_multiselect'](MTlocation[1], MTlocation[2], "Doubletap Options", _doubletap_options_values)
local doubletap_speed = MT:new_ui_register("ui_new_slider", "doubletap_speed", {MTlocation[1], MTlocation[2], "Doubletap Speed", 1, 5, 2, true, "", 1, _doubletap_speed_values})

function MT.contains(table, value)
    for _, v in ipairs(MT['ui_get'](table)) do
        if v == value then return true end
    end
    return false
end

function MT.doubletap_menu()
    local dt_stats = dt_master_switch:call()
    if dt_stats then
        doubletap:set(true)
    end
    if doubletap:call() then
        doubletap_mode:set_visible(not dt_stats)
        doubletap_hitchance:set_visible(not dt_stats)
        doubletap_fakelaglimit:set_visible(not dt_stats)
        maxprocticks:set_visible(not dt_stats)
    end
    MT['ui_set_visible'](doubletap_modifier, dt_stats)
    MT['ui_set_visible'](doubletap_options, dt_stats)
    doubletap_speed:set_visible(dt_stats)
end


MT['data'] = {
    base_tick = maxprocticks:call(),
    latency = 0,
    adaptive_tick = 19,
    old_command_number = 0,
    cmd_is_safe = true
}

function MT.Getfakelimit()
    local a, b = doubletap_speed:call(), 1
    if a == 1 then b = 9
    elseif a == 2 then b = 6
    elseif a == 3 then b = 4
    elseif a == 4 then b = 2
    elseif a == 5 then b = 1 end
    return b
end

function MT.SetDoubleTap(tickbase, chock)
    maxprocticks:set(tickbase)
    MT['chock']:set_int(chock)
end

function MT.table_contains(table, value)
    for _, v in ipairs(MT['ui_get'](table)) do
        if v == value then return true end
    end
    return false
end

function MT.AdaptiveDT()
    local a, b = MT['data']['latency'] , 16
    if a <= 20 then b = 19
    elseif a > 20 and a <= 30 then b = 18
    elseif a > 30 and a <= 40 then b = 17
    elseif a > 40 and a <= 50 then b = 16
    elseif a > 70 then b = 15 end
    return b
end

function MT.localPlayer()
    local localplayer = MT['entity']['get_local_player']()
    if MT['entity']['is_alive'](localplayer) then
        return localplayer
    else
        local obvserver = MT['entity']['get_prop'](localplayer, "m_hObserverTarget")
        return obvserver ~= nil and obvserver <= 64 and obvserver or nil
    end
end

function MT.Normalize_yaw(angle)
    angle = (angle % 360 + 360) % 360
    return angle > 180 and angle - 360 or angle
end

function MT.Worldtoscreen(xdelta, ydelta)
    if xdelta == 0 and ydelta == 0 then
        return 0
    end
    return math['deg'](math['atan2'](ydelta, xdelta))
end

function MT.Predictdistance(value)
    local value = value * 0.0254
    return value * 3.281
end

function MT.GetTarget()
    local idx, close = nil , math.huge
    local localPlayer = {MT['entity']['get_origin'](MT['localPlayer']())}
    local localview = {MT['client_camera_angles']()}
    local enemies = MT['entity']['get_players'](true)
    for k,v in pairs(enemies) do
        if MT['entity']['is_alive'](k) and MT['entity']['is_enemy'](k) and MT['entity']['is_dormant'](k) then
            local origin = {MT['entity']['get_origin'](k)}
            if origin[1] then
                local fov = math['abs'](MT['Normalize_yaw'](MT['Worldtoscreen'](origin[1] - localPlayer[1], origin[2] - localPlayer[2]) - localview[2]))
                if fov < close then
                    idx = k
                    close = fov
                end
            end
        end
    end
    return idx
end

function MT.vec_distance(x1, y1, z1, x2, y2, z2)
	return math.sqrt((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2)
end

function MT.get_closest_entity()
	local me = MT['entity']['get_local_player']()
	local entities = MT['entity']['get_players'](true)
	local lx, ly, lz = MT['entity']['get_prop'](me, "m_vecOrigin")
	local closest_ent, closest_distance = nil, math.huge
	local distance
	for i=1, #entities do
		local ex, ey, ez = MT['entity']['get_prop'](entities[i], "m_vecOrigin")
		distance = MT['vec_distance'](lx, ly, lz, ex, ey, ez)
		if distance <= closest_distance then
			closest_ent = entities[i]
			closest_distance = distance
		end
	end
	return distance
end

function MT.PredictmodeDT()
    local distance = MT.get_closest_entity()
    if not distance then doubletap_mode:set("Offensive") return end
    local distance = MT['Predictdistance'](distance)
    if distance < 60 then
        doubletap_mode:set("Defensive")
    elseif distance > 61 then
        doubletap_mode:set("Offensive")
    end
end

function MT.can_fire(me, weapon, shift_time)
    if weapon == nil then return false end
    if not doubletap:call() or not dt_master_switch:call() then return false end 
    local tickbase = MT['entity']['get_prop'](me, "m_nTickBase")
    local curtime = MT['globals']['tickinterval']() * (tickbase - shift_time)
    if fakeduck:call() then return false end
    if curtime < MT['entity']['get_prop'](me, "m_flNextAttack") then return false end
    if curtime < MT['entity']['get_prop'](weapon, "m_flNextPrimaryAttack") then return false end
    return true
end

function MT.refreshDT()
    if not doubletap:call() or not dt_master_switch:call() then return false end 
    if doubletap:call() then
        doubletap:set(false)
    end
    doubletap:set(true)
    print("refreshing dt")
end

function MT.doubletap_predict(player)
    local next_shift_amount = 0
    local local_player = MT['entity']['get_local_player']()
    local local_weapon = MT['entity']['get_player_weapon'](local_player)
    local local_weapon_id = MT['entity']['get_prop'](local_weapon, "m_iItemDefinitionIndex")
    local weapon_ready = MT['can_fire'](local_player, local_weapon, math['abs'](-1 - next_shift_amount))
    if weapon_ready then
        local latency = math['floor'](math['min'](1000, MT['client_latency']() * 1000) + 0.5)
        local latency_value = math['floor'](latency - 10)
        local command = player['command_number'] - MT['data']['old_command_number']
        MT['data']['latency'] = latency_value
        if command >= 11 and command <= maxprocticks:call() then
            MT['data']['cmd_is_safe'] = command > 3 and math['abs'](maxprocticks:call() - command) <= 3
        end
        if MT['table_contains'](doubletap_options, "Boost Accuracy") then
            MT['PredictmodeDT']()
        end
    end
end

function MT.doubletap_run()
    local dt_enable, key_enable = doubletap:call()
    if not dt_enable or not key_enable or not dt_master_switch:call() or fakeduck:call() then return end
    local doubletap_speed_fl = MT['Getfakelimit']()
    local doubletap_modifier = MT['ui_get'](doubletap_modifier)
    doubletap_fakelaglimit:set(doubletap_speed_fl)
    if doubletap_modifier == "Fast" then
        MT['SetDoubleTap'](16, MT['data']['cmd_is_safe'] and 0 or 1)
    elseif doubletap_modifier == "Fastest" then
        MT['SetDoubleTap'](17, MT['data']['cmd_is_safe'] and 1 or 2)
    elseif doubletap_modifier == "Break shift" then
        MT['SetDoubleTap'](18, MT['data']['cmd_is_safe'] and 1 or 2)
    elseif doubletap_modifier == "Adaptive" then
        local Tickbase = MT['AdaptiveDT']()
        MT['SetDoubleTap'](Tickbase, MT['data']['cmd_is_safe'] and 0 or 1)
    end

end

function MT.onPlayerdeath(e)
    if MT['table_contains'](doubletap_options, "Refresh on kill") then
        local local_player = MT['entity']['get_local_player']()
        local attacker_entindex = MT['client_userid_to_entindex'](e['attacker'])
        if attacker_entindex == local_player then
            MT['refreshDT']()
        end
    end
end

function MT.shutdown()
    --MT['ui_set'](gs_reference['maxprocticks'], MT['tonumber']("16"))
    MT['chock']:set_int(1)
end

MT['client_set_event_callback']("predict_command", MT['doubletap_predict'])
MT['client_set_event_callback']("paint_ui", MT['doubletap_menu'])
MT['client_set_event_callback']("run_command", MT['doubletap_run'])
MT['client_set_event_callback']("player_death", MT['onPlayerdeath'])
MT['client_set_event_callback']("round_prestart", MT['refreshDT'])
MT['client_set_event_callback']("shutdown", MT['shutdown'])

