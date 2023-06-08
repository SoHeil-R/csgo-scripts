local MT = {
    reference = {},
    data = {},
    ui_get = ui['get'],
    ui_set = ui['set'],
    ui_set_visible = ui['set_visible'],
    ui_reference = ui['reference'],
    ui_new_checkbox = ui['new_checkbox'],
    ui_new_hotkey = ui['new_hotkey'],
    ui_new_slider = ui['new_slider'],
    ui_new_combobox = ui['new_combobox'],
    ui_new_multiselect = ui['new_multiselect'],
    client_set_event_callback = client['set_event_callback'],
    tonumber = tonumber,
    tostring = tostring,
    pcall = pcall,
    unpack = unpack,
    entity = entity,
    globals = globals,
    client_latency = client['latency'],
    client_camera_angles = client['camera_angles'],
    client_userid_to_entindex = client['userid_to_entindex'],
    client_eye_position = client['eye_position'],
    client_trace_bullet = client['trace_bullet'],
    client_scale_damage = client['scale_damage'],
    client_random_int = client['random_int'],
    client_key_state = client['key_state'],
    client_screen_size = client['screen_size'],
    circle_outline = renderer['circle_outline'],
    globals_realtime = globals['realtime'],
    globals_curtime = globals['curtime'],
    circle = renderer['circle'],
    is_menu_open = ui['is_menu_open']
}
local menu_color = MT['ui_reference']("MISC", "Settings", "Menu color")

local indicator = {
    need_change_to = {
        red = {change = false, time = 0},
        menu_color = {change = false, time = 0},
    },
    changing = false,
    changed = false,
    last_body_yaw = 0,
    opc = 220,
    dt_fil = 1,
    fakelag_fil = 1,
    last_time = 0,
    color = 'menu_color',
    last_change = MT['globals_curtime'](),
    ['red'] = {213, 0, 0},
    ['menu_color'] = {MT['ui_get'](menu_color)},
    ['main_color'] = {MT['ui_get'](menu_color)}
}


local choked_cmds

function MT:ui(name)
    local this = self['reference'][name]
    if not this then
        error(string.format("unknown reference %s", name))
    end
    return {
        call = function (_, value)
            if value then 
                local ui_value = self['ui_get'](this[1][1])
                return ui_value
            else
                local list = {}
                for i=1, #this[1] do
                    list[#list+1] = self['ui_get'](this[1][i])
                end
                return self['unpack'](list)
            end
        end,
        set = function (_, value, index)
            if not index then
                self['pcall'](self['ui_set'], this[1][1], value)
            else
                self['pcall'](self['ui_set'], this[1][index], value)
            end
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

--AntiAim

local antiaim_rf = {
    antiaim = MT:ui_register("antiaim", {"AA", "Anti-aimbot angles", "Enabled"}),
    pitch = MT:ui_register("pitch", {"AA", "Anti-aimbot angles", "pitch"}),
    yawbase = MT:ui_register("yawbase", {"AA", "Anti-aimbot angles", "Yaw base"}),
    yaw = MT:ui_register("yaw", {"AA", "Anti-aimbot angles", "Yaw"}),
    yawjitter = MT:ui_register("yawjitter", {"AA", "Anti-aimbot angles", "Yaw jitter"}),
    bodyyaw = MT:ui_register("bodyyaw", {"AA", "Anti-aimbot angles", "Body yaw"}),
    freestanding = MT:ui_register("freestanding", {"AA", "Anti-aimbot angles", "Freestanding body yaw"}),
    fakeyawlimit = MT:ui_register("fakeyawlimit", {"AA", "Anti-aimbot angles", "Fake yaw limit"}),
    edgeyaw = MT:ui_register("edgeyaw", {"AA", "Anti-aimbot angles", "Edge yaw"}),
    freestand = MT:ui_register("freestand", {"AA", "Anti-aimbot angles", "Freestanding"}),
    slowmotion = MT:ui_register("slowmotion", {"AA", "Other", "Slow motion"}),
    fakeduck = MT:ui_register("fakeduck", {"RAGE", "Other", "Duck peek assist"}),
    menu_color = MT:ui_register("menu_color", {"MISC", "Settings", "Menu color"}),
    doubletap = MT:ui_register("doubletap", {"RAGE", "OTHER", "Double tap"}),
    maxprocticks = MT:ui_register("maxprocticks", {"MISC", "Settings", "sv_maxusrcmdprocessticks"}),
    fakelag = MT:ui_register("fakelag", {"AA", "Fake lag", "Limit"}),

}
local MTlocation = {"AA", "Anti-aimbot angles"}
local legit_aa_type = {"Static", "Freestand", "Jitter"}
local base_yaw_mode = {"In air", "While slow walking", "While fakeducking"}
local body_yaw_mode = {"Off", "Freestand", "Movement", "Inverter", "Flip"}
local manual_aa_mode = {"Keys", "Circle"}

antiaim_rf['freestand']:set('On hotkey', 2)
antiaim_rf['edgeyaw']:set(false)

local aa_master_switch = MT:new_ui_register("ui_new_checkbox", "aa_master_switch", {MTlocation[1], MTlocation[2], "[madtech] Anti-aimbot angles"})

local body_yaw = MT:new_ui_register("ui_new_combobox", "body_yaw", {MTlocation[1], MTlocation[2], "Body yaw", body_yaw_mode})
local body_yaw_slider = MT:new_ui_register("ui_new_slider", "body_yaw_slider", {MTlocation[1], MTlocation[2], "\n", 0, 120, 90, true, '°'})
local body_yaw_invert = MT:new_ui_register("ui_new_hotkey", "body_yaw_invert", {MTlocation[1], MTlocation[2], "Inverter"})
local low_delta = MT:new_ui_register("ui_new_hotkey", "low_delta", {MTlocation[1], MTlocation[2], "Low delta", false, 0x10})


local legit_aa = MT:new_ui_register("ui_new_checkbox", "legit_aa", {MTlocation[1], MTlocation[2], "Legit antiaim"})
local legit_aa_key = MT:new_ui_register("ui_new_hotkey", "legit_aa_key", {MTlocation[1], MTlocation[2], "\nHotkey", true})
local legit_aa_options = MT:new_ui_register("ui_new_combobox", "legit_aa_options", {MTlocation[1], MTlocation[2], "\n", legit_aa_type})

local freestand = MT:new_ui_register("ui_new_checkbox", "freestand", {MTlocation[1], MTlocation[2], "Freestanding"})
local freestanding_key  = MT:new_ui_register("ui_new_hotkey", "freestanding_key", {MTlocation[1], MTlocation[2], "\nHotkey", true})
local freestanding_multiselect = MT:new_ui_register("ui_new_multiselect", "freestanding_multiselect", {MTlocation[1], MTlocation[2], "\n", base_yaw_mode})

local edgeyaw = MT:new_ui_register("ui_new_checkbox", "edgeyaw", {MTlocation[1], MTlocation[2], "Edge yaw"})
local edgeyaw_key  = MT:new_ui_register("ui_new_hotkey", "edgeyaw_key", {MTlocation[1], MTlocation[2], "\nHotkey", true})
local edgeyaw_multiselect = MT:new_ui_register("ui_new_multiselect", "edgeyaw_multiselect", {MTlocation[1], MTlocation[2], "\n", base_yaw_mode})

local manual_aa = MT:new_ui_register("ui_new_checkbox", "manual_aa", {MTlocation[1], MTlocation[2], "Manual antiaim"})
local manual_option = MT:new_ui_register("ui_new_combobox", "manual_option", {MTlocation[1], MTlocation[2], "Manual AA mode", manual_aa_mode})
local manual_circle_hotkey = MT:new_ui_register("ui_new_hotkey", "manual_hotkey", {MTlocation[1], MTlocation[2], "Manual circle"})
local manual_left = MT:new_ui_register("ui_new_hotkey", "manual_left", {MTlocation[1], MTlocation[2], "Manual Left"})
local manual_right = MT:new_ui_register("ui_new_hotkey", "manual_right", {MTlocation[1], MTlocation[2], "Manual Right"})


function MT.contains(table, value)
    for _, v in ipairs(table) do
        if v == value then return true end
    end
    return false
end

function MT.round(num, decimals)
	local mult = 10^(decimals or 0)
	return math['floor'](num * mult + 0.5) / mult
end

function MT.normalise_angle(angle)
	angle =  angle % 360 
	angle = (angle + 360) % 360
	if (angle > 180)  then
		angle = angle - 360
	end
	return angle
end

function MT.calculate_selection(x,y,z)
	if y < -5 then return 3 end
	if y > 5 then return 1 end
	return 2
end

local Madtech = renderer.load_svg([[
    <svg width="608" height="689" version="1.1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1080.000000 1080.000000"
    preserveAspectRatio="xMidYMid meet">
   <g transform="translate(0.000000,1080.000000) scale(0.100000,-0.100000)" stroke="none">
   <path d="M3033 7712 c-898 -1 -1633 -5 -1633 -9 0 -3 102 -179 227 -391 l227
   -384 1578 7 1578 8 1 -454 c1 -250 3 -488 5 -530 l3 -77 187 -351 c103 -193
   190 -351 194 -351 4 0 91 158 194 351 l187 351 3 77 c2 42 4 280 5 530 l1 454
   1578 -8 1578 -7 228 386 c126 213 227 388 225 390 -6 5 -4576 11 -6366 8z" fill="#ffffff" fill-rule="evenodd"/>
   <path d="M2538 6743 c-280 -2 -508 -6 -508 -8 0 -3 124 -169 275 -369 l276
   -363 181 -6 c100 -4 323 -7 496 -7 l314 0 -7 -1482 -7 -1483 392 -290 c216
   -159 489 -363 609 -452 119 -89 218 -158 221 -155 3 4 4 212 2 463 l-3 455
   -235 180 -234 179 0 995 c0 840 2 991 14 975 7 -11 136 -229 286 -485 150
   -256 312 -532 361 -615 49 -82 164 -279 256 -437 92 -158 170 -288 173 -288 3
   0 81 130 173 288 92 158 207 355 256 437 49 83 211 359 361 615 150 256 279
   474 286 485 12 16 14 -135 14 -975 l0 -995 -234 -179 -235 -180 -3 -455 c-2
   -251 -1 -459 2 -463 3 -3 102 66 221 155 120 89 393 293 609 452 l392 290 -7
   1483 -7 1482 314 0 c173 0 396 3 496 7 l181 6 277 364 c151 201 274 366 272
   368 -1 2 -523 7 -1158 11 l-1155 7 -96 -169 c-54 -93 -235 -410 -404 -704
   -169 -294 -362 -631 -428 -747 -67 -117 -124 -213 -127 -213 -3 0 -60 96 -127
   213 -66 116 -259 453 -428 747 -169 294 -350 610 -403 703 l-96 167 -650 -2
   c-358 -2 -879 -4 -1158 -5z" fill="#ffffff" fill-rule="evenodd"/>
   <path d="M5035 3048 c-4 -486 -6 -894 -4 -908 l4 -25 365 0 365 0 4 25 c6 45
   -11 1790 -18 1790 -4 0 -83 -148 -175 -330 -92 -181 -171 -330 -176 -330 -5 0
   -84 149 -176 330 -92 182 -171 330 -175 330 -3 0 -10 -397 -14 -882z" fill="#ffffff" fill-rule="evenodd"/>
   </g>
</svg>]], 45, 45)


function MT.SelectedColor()
    for k,v in pairs(indicator['need_change_to']) do
        if v['change'] then
            indicator['need_change_to'][k] = {change = false, time = 0}
            indicator['changed'] = true
            return k
        end
    end
end

function MT.nnc()
    for k,v in pairs(indicator['need_change_to']) do
        if v['change'] then
            local time_color = v['time'] - indicator['last_change']
            if time_color > 5 then
                return true
            end
        end
    end
    return false
end

function MT.gradient_text(r1, g1, b1, a1, r2, g2, b2, a2, text)
	local output = ''

	local len = #text-1

	local rinc = (r2 - r1) / len
	local ginc = (g2 - g1) / len
	local binc = (b2 - b1) / len
	local ainc = (a2 - a1) / len

	for i=1, len+1 do
		output = output .. ('\a%02x%02x%02x%02x%s'):format(r1, g1, b1, a1, text:sub(i, i))

		r1 = r1 + rinc

		g1 = g1 + ginc
		b1 = b1 + binc
		a1 = a1 + ainc
	end

	return output
end

function MT.can_fire()
    local me = MT['entity']['get_local_player']()
    local weapon = MT['entity']['get_prop'](me, "m_hActiveWeapon")
    if weapon == nil then return false end
    if not antiaim_rf['doubletap']:call() then return false end 
    local tickbase = MT['entity']['get_prop'](me, "m_nTickBase")
    local curtime = MT['globals']['tickinterval']() * (tickbase - 0)
    if antiaim_rf['fakeduck']:call() then return false end
    if curtime < MT['entity']['get_prop'](me, "m_flNextAttack") then return false end
    if MT['entity']['get_prop'](weapon, "m_flNextPrimaryAttack") then
        if curtime < MT['entity']['get_prop'](weapon, "m_flNextPrimaryAttack") then return false end
    end
    return true
end

function MT.get_aa_state(cm)
    local state = "standing"
    local me = MT['entity']['get_local_player']()
    local flags = MT['entity']['get_prop'](me, "m_fFlags")
    local x, y, z = MT['entity']['get_prop'](me, "m_vecVelocity")
    local velocity = math['floor'](math['min'](10000, math['sqrt'](x^2 + y^2) + 0.5))
    local slow_enable, slow_useing = antiaim_rf['slowmotion']:call()
    if bit['band'](flags, 1) ~= 1 or (cm and cm['in_jump'] == 1) then state = "Air" else
        if velocity > 1 or (cm['sidemove'] ~= 0 or cm['forwardmove'] ~= 0) then
            if slow_enable and slow_useing then 
                state = "Slow walk"
            else
                state = "Moving"
            end
        else
            state = "Standing"
        end
    end

    return {
        velocity = velocity,
        state = state
    }
end

function MT.handler_aa(data, is_else)
    if data then
        if data['pitch'] then
            antiaim_rf['pitch']:set(data['pitch'])
        elseif is_else then
            antiaim_rf['pitch']:set('Off')
        end
        if data['yawbase'] then
            antiaim_rf['yawbase']:set(data['yawbase'])
        elseif is_else then
            antiaim_rf['yawbase']:set('Local view')
        end
        if data['yaw'] then
            antiaim_rf['yaw']:set(data['yaw'])
        elseif is_else then
            antiaim_rf['yaw']:set('Off')
        end
        if data['yawvalue'] then
            antiaim_rf['yaw']:set(data['yawvalue'], 2)
        elseif is_else then
            antiaim_rf['yaw']:set(0, 2)
        end
        if data['yawjitter'] then
            antiaim_rf['yawjitter']:set(data['yawjitter'])
        elseif is_else then
            antiaim_rf['yawjitter']:set('Off')
        end
        if data['yawjittervalue'] then
            antiaim_rf['yawjitter']:set(data['yawjittervalue'], 2)
        elseif is_else then
            antiaim_rf['yawjitter']:set(0, 2)
        end
        if data['bodyyaw'] then
            antiaim_rf['bodyyaw']:set(data['bodyyaw'])
        elseif is_else then
            antiaim_rf['bodyyaw']:set('Off')
        end
        if data['bodyyawvalue'] then
            antiaim_rf['bodyyaw']:set(data['bodyyawvalue'], 2)
        elseif is_else then
            antiaim_rf['bodyyaw']:set(0, 2)
        end
        if data['freestanding_body'] then
            antiaim_rf['freestanding']:set(data['freestanding_body'])
        elseif is_else then
            antiaim_rf['freestanding']:set(false)
        end
        if data['fakeyawlimit'] then
            antiaim_rf['fakeyawlimit']:set(data['fakeyawlimit'])
        elseif is_else then
            antiaim_rf['fakeyawlimit']:set(60)
        end
    end
end

local AntiAims = {
    is_manual = false,
    last_press = 0,
    manual_dir = "none",
    manual_aa = {
        ['left'] = {
            pitch = 'Default',
            yawvalue = -90,
            yawbase = 'Local view',
            yaw = '180',
            bodyyaw = 'Static',
            bodyyawvalue = 0,
        },
        ['right'] = {
            pitch = 'Default',
            yawvalue = 90,
            yawbase = 'Local view',
            yaw = '180',
            bodyyaw = 'Static',
            bodyyawvalue = 0,
        }
    },
    legit_aa = {
        ['Static'] = {
            pitch = 'Off',
            yawbase = 'Local view',
            yawjitter = 'Off',
            bodyyaw = 'Static',
            bodyyawvalue = 58,
            fakeyawlimit = 58
        },
        ['Freestand'] = {
            pitch = 'Off',
            yawbase = 'Local view',
            yawjitter = 'Off',
            bodyyaw = 'Opposite',
            bodyyawvalue = 180,
            freestanding_body = true,
            fakeyawlimit = 58
        },
        ['Jitter'] = {
            pitch = 'Off',
            yawbase = 'Local view',
            yawjitter = 'Off',
            bodyyaw = 'Jitter',
            bodyyawvalue = 180,
            fakeyawlimit = 60
        },
    },
    base_aa = {
        ['Standing'] = {
            pitch = 'Default',
            yawbase = 'Local view',
            yaw = '180',
            yawvalue = 0,
            yawjitter = 'Off',
            yawjittervalue = 0,
            bodyyaw = 'Static',
            bodyyawvalue = 0,
            fakeyawlimit = 45
        },
        ['Moving'] = {
            pitch = 'Default',
            yawbase = 'Local view',
            yaw = '180',
            yawvalue = 0,
            yawjitter = 'Off',
            yawjittervalue = 0,
            bodyyaw = 'Static',
            bodyyawvalue = 0,
            fakeyawlimit = 25
        },
        ['Air'] = {
            pitch = 'Default',
            yawbase = 'At targets',
            yaw = '180',
            yawvalue = 0,
            yawjitter = 'Off',
            yawjittervalue = 0,
            bodyyaw = 'Static',
            bodyyawvalue = 0,
            fakeyawlimit = 32
        },
    },
}
-- antiaim_rf['freestand']:set('Always on', 2)
-- else
--     antiaim_rf['freestand']:set('On hotkey', 2)

--     antiaim_rf['edgeyaw']:set(true)
-- else
--     antiaim_rf['edgeyaw']:set(false)
-- While slow walking
function MT.base_yaw(e)
    local local_state = MT['get_aa_state'](e)
    local fakeducking = antiaim_rf['fakeduck']:call()
    local fs_options = freestanding_multiselect:call(true)
    local ey_options = edgeyaw_multiselect:call(true)
    local fs_enable = false
    local ey_enable = false
    if freestand:call() and freestanding_key:call() then
        fs_enable = true
    end
    if edgeyaw:call() and edgeyaw_key:call() then
        ey_enable = true
    end
    if local_state['state'] == "Air" then
        if MT['contains'](fs_options, "In air") then
            fs_enable = false
        end
        if MT['contains'](ey_options, "In air") then
            ey_enable = false
        end
    elseif local_state['state'] == "Slow walk" then
        if MT['contains'](fs_options, "While slow walking") then
            fs_enable = false
        end
        if MT['contains'](ey_options, "While slow walking") then
            ey_enable = false
        end
    elseif fakeducking then
        if MT['contains'](fs_options, "While fakeducking") then
            fs_enable = false
        end
        if MT['contains'](ey_options, "While fakeducking") then
            ey_enable = false
        end
    end
    if fs_enable then
        antiaim_rf['freestand']:set('Always on', 2)
    else
        antiaim_rf['freestand']:set('On hotkey', 2)
    end
    if ey_enable then
        antiaim_rf['edgeyaw']:set(true)
    else
        antiaim_rf['edgeyaw']:set(false)
    end
end

function MT.normalize_yaw(yaw)
	while yaw > 180 do yaw = yaw - 360 end
	while yaw < -180 do yaw = yaw + 360 end
	return yaw
end

function MT.calc_angle(local_x, local_y, enemy_x, enemy_y)
	local ydelta = local_y - enemy_y
	local xdelta = local_x - enemy_x
	local relativeyaw = math['atan']( ydelta / xdelta )
	relativeyaw = MT['normalize_yaw']( relativeyaw * 180 / math['pi'] )
	if xdelta >= 0 then
		relativeyaw = MT['normalize_yaw'](relativeyaw + 180)
	end
	return relativeyaw
end

function MT.calc(xdelta, ydelta)
    if xdelta == 0 and ydelta == 0 then
        return 0
	end
    return math['deg'](math['atan2'](ydelta, xdelta))
end

function MT.angle_vector(angle_x, angle_y)
	local sy = math['sin'](math['rad'](angle_y))
	local cy = math['cos'](math['rad'](angle_y))
	local sp = math['sin'](math['rad'](angle_x))
	local cp = math['cos'](math['rad'](angle_x))
	return cp * cy, cp * sy, -sp
end

function MT.get_nearest_enemy(plocal, enemies)
	local lx, ly, lz = MT['client_eye_position']()
	local view_x, view_y, roll = MT['client_camera_angles']()
	local bestenemy = nil
    local fov = 180
    for i=1, #enemies do
        local cur_x, cur_y, cur_z = MT['entity']['get_prop'](enemies[i], "m_vecOrigin")
        local cur_fov = math['abs'](MT['normalize_yaw'](MT['calc'](lx - cur_x, ly - cur_y) - view_y + 180))
        if cur_fov < fov then
			fov = cur_fov
			bestenemy = enemies[i]
		end
	end
	return bestenemy
end


function MT.get_damage(plocal, enemy, x, y,z)
	local ex = { }
	local ey = { }
	local ez = { }
	ex[0], ey[0], ez[0] = MT['entity']['hitbox_position'](enemy, 1)
	ex[1], ey[1], ez[1] = ex[0] + 40, ey[0], ez[0]
	ex[2], ey[2], ez[2] = ex[0], ey[0] + 40, ez[0]
	ex[3], ey[3], ez[3] = ex[0] - 40, ey[0], ez[0]
	ex[4], ey[4], ez[4] = ex[0], ey[0] - 40, ez[0]
	ex[5], ey[5], ez[5] = ex[0], ey[0], ez[0] + 40
	ex[6], ey[6], ez[6] = ex[0], ey[0], ez[0] - 40
	local ent, dmg = 0
	for i=0, 6 do
		if dmg == 0 or dmg == nil then
			ent, dmg = MT['client_trace_bullet'](enemy, ex[i], ey[i], ez[i], x, y, z)
		end
	end
	return ent == nil and MT['client_scale_damage'](plocal, 1, dmg) or dmg
end

function MT.get_desync()
    local localPlayer = MT['entity']['get_local_player']()
    local lx, ly, lz = MT['client_eye_position']()
    local enemies = MT['entity']['get_players'](true)
    local body_yaw = body_yaw:call()
    local body_yaw_slider = body_yaw_slider:call()

    local best_desync = 0
    if #enemies == 0 then
        return body_yaw_slider
    end
    local best_enemy = MT['get_nearest_enemy'](localPlayer, enemies)
    if best_enemy ~= nil and best_enemy ~= 0 and MT['entity']['is_alive'] then
        local e_x, e_y, e_z = MT['entity']['hitbox_position'](best_enemy, 0)

        local yaw = MT['calc_angle'](lx, ly, e_x, e_y)
        local rdir_x, rdir_y, rdir_z = MT['angle_vector'](0, (yaw + 90))
        local rend_x = lx + rdir_x * 10
        local rend_y = ly + rdir_y * 10
        
        local ldir_x, ldir_y, ldir_z = MT['angle_vector'](0, (yaw - 90))
        local lend_x = lx + ldir_x * 10
        local lend_y = ly + ldir_y * 10
        
        local r2dir_x, r2dir_y, r2dir_z = MT['angle_vector'](0, (yaw + 90))
        local r2end_x = lx + r2dir_x * 100
        local r2end_y = ly + r2dir_y * 100

        local l2dir_x, l2dir_y, l2dir_z = MT['angle_vector'](0, (yaw - 90))
        local l2end_x = lx + l2dir_x * 100
        local l2end_y = ly + l2dir_y * 100      
        
        local ldamage = MT['get_damage'](localPlayer, best_enemy, rend_x, rend_y, lz)
        local rdamage = MT['get_damage'](localPlayer, best_enemy, lend_x, lend_y, lz)

        local l2damage = MT['get_damage'](localPlayer, best_enemy, r2end_x, r2end_y, lz)
        local r2damage = MT['get_damage'](localPlayer, best_enemy, l2end_x, l2end_y, lz)
        
        if body_yaw == 'Freestand' or body_yaw == 'Movement' then
            if l2damage > r2damage or ldamage > rdamage or l2damage > ldamage then
                best_desync = -body_yaw_slider
            elseif r2damage > l2damage or rdamage > ldamage or r2damage > rdamage then
                best_desync = body_yaw_slider
            end
        end
        return best_desync
    end
end

function MT.Flipdesync()
    local body_yaw_slider = body_yaw_slider:call()
    local flip_value = {-body_yaw_slider, body_yaw_slider}
    return flip_value[math.random(#flip_value)]
end

function MT.Invertdesync()
    local body_yaw_slider = body_yaw_slider:call()
    local is_inverted = body_yaw_invert:call()
    if is_inverted then
        return body_yaw_slider
    else
        return -body_yaw_slider
    end
end

function MT.Movementdesync()
    local a_desync = MT['client_key_state'](0x41)
    local d_desync = MT['client_key_state'](0x44)
    local body_yaw_slider = body_yaw_slider:call()
    if a_desync then
        return -body_yaw_slider
    elseif d_desync then
        return body_yaw_slider
    end
end

function MT.Desync_handler()
    local body_yaw = body_yaw:call()
    if body_yaw == 'Freestand' then
        local best_desync = MT['get_desync']()
        AntiAims['base_aa']['Moving']['bodyyawvalue'] = best_desync
        AntiAims['base_aa']['Standing']['bodyyawvalue'] = best_desync
    elseif body_yaw == 'Flip' then
        local Flip_desync = MT['Flipdesync']()
        AntiAims['base_aa']['Moving']['bodyyawvalue'] = Flip_desync
        AntiAims['base_aa']['Standing']['bodyyawvalue'] = Flip_desync
    elseif body_yaw == 'Inverter' then
        local Invert_desync = MT['Invertdesync']()
        AntiAims['base_aa']['Moving']['bodyyawvalue'] = Invert_desync
        AntiAims['base_aa']['Standing']['bodyyawvalue'] = Invert_desync
    elseif body_yaw == 'Movement' then
        local Movement_desync = MT['Movementdesync']()
        AntiAims['base_aa']['Moving']['bodyyawvalue'] = Movement_desync
        AntiAims['base_aa']['Standing']['bodyyawvalue'] = Movement_desync
    end
end

function MT.Legitaa(e)
    local local_weapon = MT['entity']['get_player_weapon']()
    if local_weapon and MT['entity']['get_classname'](local_weapon) == "CC4" then
        if e['in_attack'] == 1 then
            e['in_attack'] = 0
            e['in_use'] = 1
        end
    else
        if e['chokedcommands'] == 0 then
            e['in_use'] = 0
            MT['handler_aa'](AntiAims['legit_aa'][legit_aa_options:call()], true)
        end
    end
end

function MT.Lowdelta()
    local fakerr = MT['client_random_int'](0,35)
    MT['handler_aa']({
        pitch = 'Default',
        yawbase = 'At targets',
        yaw = '180',
        yawvalue = 0,
        yawjitter = 'Offset',
        yawjittervalue = -7,
        bodyyaw = 'Jitter',
        bodyyawvalue = 0,
        fakeyawlimit = fakerr
    })
end

function MT.Antiaim_pr(e)
    local aa_switch = aa_master_switch:call()
    if not aa_switch then return end
    if freestand:call() or edgeyaw:call() then MT['base_yaw'](e) end
    local local_state = MT['get_aa_state'](e)['state']
    if legit_aa:call() and legit_aa_key:call() then
        MT['Legitaa'](e)
    else
        if low_delta:call() then
            MT['Lowdelta']()
        else
            if not AntiAims['is_manual'] then
                MT['Desync_handler']()
                MT['handler_aa'](AntiAims['base_aa'][local_state])
            else
                local manual_state = AntiAims['manual_dir']
                MT['handler_aa'](AntiAims['manual_aa'][manual_state])
            end
        end
    end
    choked_cmds = e.chokedcommands
end

local manualcircle_state = false
local manualcircle_toggle_time = 0
function MT.Manualcircle()
    if MT['is_menu_open']() then return end
    local alphaPercent = 0
    local r, g, b = 20,20,20
    local fadetime = 0.2
    local screen = {MT['client_screen_size']()}
    local center = {screen[1] / 2, screen[2] / 2}
    local realtime = MT['globals_realtime']()
    local is_toggled = manual_circle_hotkey:call()
    if is_toggled ~= manualcircle_state then
        manualcircle_state = is_toggled
        manualcircle_toggle_time = realtime
        if is_toggled then
            open_x, open_y, open_z = MT['client_camera_angles']()
        else
            local close_x,close_y,close_z = MT['client_camera_angles']()
			selection =  MT['calculate_selection'](MT['normalise_angle'](open_x - close_x), MT['normalise_angle'](open_y - close_y), MT['normalise_angle'](open_z - close_z))
			if selection == 1 then
                AntiAims['is_manual'] = true
                AntiAims['manual_dir'] = "right"
                MT['handler_aa'](AntiAims['manual_aa']['right'])
            elseif selection == 3 then
                AntiAims['is_manual'] = true
                AntiAims['manual_dir'] = "left"
                MT['handler_aa'](AntiAims['manual_aa']['left'])
            else
                AntiAims['is_manual'] = false
                AntiAims['manual_dir'] = "none"
                MT['handler_aa']({yawvalue = 0,bodyyawvalue = 0})
            end
        end
    end
    if not manualcircle_toggle_time then return end
    local delta = realtime - manualcircle_toggle_time
    if delta <= fadetime then
        alphaPercent = is_toggled and (delta / fadetime) or 1-(delta/fadetime)
    elseif is_toggled then
        alphaPercent = 1
    end
    if open_x then
        local cur_x,cur_y,cur_z = MT['client_camera_angles']()
        local selection = MT['calculate_selection'](MT['normalise_angle'](open_x - cur_x), MT['normalise_angle'](open_y - cur_y), MT['normalise_angle'](open_z - cur_z))
        if alphaPercent > 0 then
            if selection == 1 then 
                MT['circle'](center[1], center[2], r+1, g+1, b+1, 230*alphaPercent, 150, 30, 0.16666)
            else
                MT['circle'](center[1], center[2], r, g, b, 170*alphaPercent, 150, 30, 0.16666)
            end
                
            if selection == 2 then
                MT['circle'](center[1], center[2], r+1, g+1, b+1, 230*alphaPercent, 150, -30, 0.16666)
            else 
                MT['circle'](center[1], center[2], r, g, b, 170*alphaPercent, 150, -30, 0.16666)
            end
                
            if selection == 3 then
                MT['circle'](center[1], center[2], r+1, g+1, b+1, 230*alphaPercent, 150, -90, 0.16666)
            else
                MT['circle'](center[1], center[2], r, g, b, 170*alphaPercent, 150, -90, 0.16666)
            end
        end
    end
end


function MT.manualKeys()
    local is_left_key = manual_left:call()
    local is_right_key = manual_right:call()
    if is_left_key and AntiAims['last_press'] + 0.2 < MT['globals_curtime']() then
        AntiAims['last_press'] = MT['globals_curtime']()
        if not AntiAims['is_manual'] then
            AntiAims['is_manual'] = true
            AntiAims['manual_dir'] = "left"
            MT['handler_aa'](AntiAims['manual_aa']['left'])
        else
            AntiAims['is_manual'] = false
        end
    elseif is_right_key and AntiAims['last_press'] + 0.2 < MT['globals_curtime']() then
        AntiAims['last_press'] = MT['globals_curtime']()
        if not AntiAims['is_manual'] then
            AntiAims['is_manual'] = true
            AntiAims['manual_dir'] = "right"
            MT['handler_aa'](AntiAims['manual_aa']['right'])
        else
            AntiAims['is_manual'] = false
            AntiAims['manual_dir'] = "none"
            MT['handler_aa']({yawvalue = 0,bodyyawvalue = 0})
        end
    end
end


local madtech = MT.gradient_text(indicator['main_color'][1], indicator['main_color'][2]+ 50, indicator['main_color'][3], 255, indicator['main_color'][1], indicator['main_color'][2], indicator['main_color'][3], 255, "MADTECH")

function MT.Indicator()
    local localPlayer = MT['entity']['get_local_player']()
	if not MT['entity']['is_alive'](localPlayer) then return end
    local desync = MT['entity']['get_prop'](localPlayer, "m_flPoseParameter", 11) * 116 - 58
	local body_yaw = math['max'](-60, math['min'](60, MT['round']((MT['entity']['get_prop'](localPlayer, "m_flPoseParameter", 11) or 0)*120-60+0.5, 1)))
    local screen = {MT['client_screen_size']()}
    local center = {screen[1] / 2, screen[2] / 2}
    local desync_plus = math['abs'](body_yaw)
    if desync_plus >= 20 and desync_plus <= 60 and indicator['last_change'] + 4 < MT['globals_curtime']() and indicator['color'] ~= 'menu_color' then
        indicator['changing'] = true
        indicator['need_change_to']['menu_color'] = {change = true, time = MT['globals_curtime']()}
    elseif desync_plus <= 19 and desync_plus >= 0 and indicator['last_change'] + 4 < MT['globals_curtime']() and indicator['color'] ~= 'red' then
        indicator['changing'] = true
        indicator['need_change_to']['red'] = {change = true, time = MT['globals_curtime']()}
    end
    if indicator['changing'] then
        indicator['opc'] = math.floor(math.sin(MT['globals_realtime']() * 1) * (220/2-1) + 220/2) or 220
        if indicator['opc'] == 1 and not indicator['changed'] then
            local this_color = MT['SelectedColor']()
            if this_color then
                indicator['color'] = this_color
                indicator['main_color'] = indicator[this_color]
                indicator['last_change'] = MT['globals_curtime']()
            end
        elseif indicator['opc'] == 218 and indicator['changed'] then
            indicator['changed'] = false
            indicator['changing'] = false
        end
    end
    if indicator['changing'] then
        renderer.texture(Madtech, center[1]-20, screen[2] - 40, 45, 45, indicator['main_color'][1], indicator['main_color'][2], indicator['main_color'][3], indicator['opc'])
    else
        renderer.texture(Madtech, center[1]-20, screen[2] - 40, 45, 45, indicator['main_color'][1], indicator['main_color'][2], indicator['main_color'][3], 220)
    end

    renderer.text(center[1], center[2] - 3, 255, 255, 255, 255, "cb", nil, madtech)
    local this_body = math.abs(body_yaw)
    if this_body < 2 then
        this_body = 25
    end

    renderer.rectangle(center[1], center[2]+5, -this_body - 2, 8, 38, 38, 38, 200)
    renderer.rectangle(center[1], center[2]+5, this_body + 2, 8, 38, 38, 38, 200)
	renderer.gradient(center[1], center[2]+7, -this_body, 3, indicator['menu_color'][1], indicator['menu_color'][2]+ 50, indicator['menu_color'][3], 255, indicator['menu_color'][1], indicator['menu_color'][2], indicator['menu_color'][3], 255, true)
	renderer.gradient(center[1], center[2]+7, this_body, 3, indicator['menu_color'][1], indicator['menu_color'][2]+ 50, indicator['menu_color'][3], 255, indicator['menu_color'][1], indicator['menu_color'][2], indicator['menu_color'][3], 255, true)
    local dt_enable, useing = antiaim_rf['doubletap']:call()
    if useing then
        renderer.text(center[1], center[2]+22, indicator['menu_color'][1], indicator['menu_color'][2], indicator['menu_color'][3], 255, "-c", nil, "DOUBLETAP")
        renderer.rectangle(center[1]-40, center[2]+30, 80, 8, 38, 38, 38, 200)
        renderer.gradient(center[1]-38, center[2]+32, indicator['dt_fil'], 4, indicator['menu_color'][1], indicator['menu_color'][2]+ 50, indicator['menu_color'][3], 255, indicator['menu_color'][1], indicator['menu_color'][2], indicator['menu_color'][3], 255, true)
        if MT['can_fire']() then
            MT['dtprocessbar']()
        else
            indicator['dt_fil'] = 1
        end
        renderer.text(center[1], center[2]+45, indicator['menu_color'][1], indicator['menu_color'][2], indicator['menu_color'][3], 255, "-c", nil, "FAKE LAG")
        renderer.rectangle(center[1]-40, center[2]+52, 80, 8, 38, 38, 38, 200)
        renderer.gradient(center[1]-38, center[2]+54, indicator['fakelag_fil'], 4, indicator['menu_color'][1], indicator['menu_color'][2]+ 50, indicator['menu_color'][3], 255, indicator['menu_color'][1], indicator['menu_color'][2], indicator['menu_color'][3], 255, true)
        if choked_cmds then
            MT['flprocessbar']()
        end
    else
        renderer.text(center[1], center[2]+22, indicator['menu_color'][1], indicator['menu_color'][2], indicator['menu_color'][3], 255, "-c", nil, "FAKE LAG")
        renderer.rectangle(center[1]-40, center[2]+30, 80, 8, 38, 38, 38, 200)
        renderer.gradient(center[1]-38, center[2]+32, indicator['fakelag_fil'], 4, indicator['menu_color'][1], indicator['menu_color'][2]+ 50, indicator['menu_color'][3], 255, indicator['menu_color'][1], indicator['menu_color'][2], indicator['menu_color'][3], 255, true)
        if choked_cmds then
            MT['flprocessbar']()
        end
    end

end

function MT.dtprocessbar()
    local timetick = math.floor(5 / globals.tickinterval() + 0.5) + globals.tickcount()
    if indicator['dt_fil'] < 75 then
        local this_time = timetick - indicator['last_time']
        if this_time >= 1 then
            indicator['dt_fil'] = indicator['dt_fil'] + 2
            indicator['last_time'] = timetick
        end
    end
end

function MT.flprocessbar()
    local timetick = math.floor(5 / globals.tickinterval() + 0.5) + globals.tickcount()
    local choke = choked_cmds
    local fakelag_limit = antiaim_rf['fakelag']:call()
    local chocked = 75 / fakelag_limit
    indicator['fakelag_fil'] = chocked * choke
end

function MT.Roundstart()
    indicator['last_time'] = 0
end

function MT.Antiaim()
    local aa_switch = aa_master_switch:call()
    antiaim_rf['antiaim']:set_visible(not aa_switch)
    antiaim_rf['pitch']:set_visible(not aa_switch)
    antiaim_rf['yawbase']:set_visible(not aa_switch)
    antiaim_rf['yaw']:set_visible(not aa_switch)
    antiaim_rf['yawjitter']:set_visible(not aa_switch)
    antiaim_rf['bodyyaw']:set_visible(not aa_switch)
    antiaim_rf['freestanding']:set_visible(not aa_switch)
    antiaim_rf['fakeyawlimit']:set_visible(not aa_switch)
    antiaim_rf['edgeyaw']:set_visible(not aa_switch)
    antiaim_rf['freestand']:set_visible(not aa_switch)
    legit_aa:set_visible(aa_switch)
    freestand:set_visible(aa_switch)
    freestanding_key:set_visible(aa_switch)
    edgeyaw:set_visible(aa_switch)
    edgeyaw_key:set_visible(aa_switch)
    body_yaw:set_visible(aa_switch)
    manual_aa:set_visible(aa_switch)
    low_delta:set_visible(aa_switch)
    ------
    local legit_aa = legit_aa:call()
    legit_aa_key:set_visible(aa_switch and legit_aa or false)
    legit_aa_options:set_visible(aa_switch and legit_aa or false)
    ------
    local freestand = freestand:call()
    freestanding_key:set_visible(aa_switch and freestand or false)
    freestanding_multiselect:set_visible(aa_switch and freestand or false)
    ------
    local edgeyaw = edgeyaw:call()
    edgeyaw_key:set_visible(aa_switch and edgeyaw or false)
    edgeyaw_multiselect:set_visible(aa_switch and edgeyaw or false)
    -----
    local body_yaw = body_yaw:call()
    if body_yaw ~= 'Off' then
        body_yaw_slider:set_visible(aa_switch and true or false)
    end
    if body_yaw == 'Inverter' then
        body_yaw_invert:set_visible(aa_switch and true or false)
    else
        body_yaw_invert:set_visible(false)
    end
    if body_yaw == 'Off' then
        body_yaw_slider:set_visible(false)
    end
    ------
    local manual_aa = manual_aa:call()
    local manual_options = manual_option:call()
    manual_option:set_visible(aa_switch and manual_aa or false)
    if manual_options == "Keys" then
        manual_circle_hotkey:set_visible(false)
        manual_left:set_visible((aa_switch and manual_aa) and true or false)
        manual_right:set_visible((aa_switch and manual_aa) and true or false)
    else
        manual_left:set_visible(false)
        manual_right:set_visible(false)
        manual_circle_hotkey:set_visible((aa_switch and manual_aa) and true or false)
    end
    if manual_aa then
        if manual_options == "Keys" then
            MT['manualKeys']()
        else
            MT['Manualcircle']()
        end
    end
end

function MT.Indcators()
    local aa_switch = aa_master_switch:call()
    if not aa_switch then return end
    MT['Indicator']()
end

MT['client_set_event_callback']("paint", MT['Indcators'])
MT['client_set_event_callback']("paint_ui", MT['Antiaim'])
MT['client_set_event_callback']("setup_command", MT['Antiaim_pr'])
MT['client_set_event_callback']("round_prestart", MT['Roundstart'])
