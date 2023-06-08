local bit_band, bit_lshift, math_deg, math_abs, math_sqrt, math_floor, math_atan2 = bit.band, bit.lshift, math.deg, math.abs, math.sqrt, math.floor, math.atan2
local ui_set, ui_reference, ui_set_visible, globals_curtime, globals_tickcount = ui.set, ui.reference, ui.set_visible, globals.curtime, globals.tickcount
local entity_is_alive, entity_get_prop, entity_is_dormant, entity_get_origin, entity_get_esp_data, entity_get_player_name, entity_get_local_player = entity.is_alive, entity.get_prop, entity.is_dormant, entity.get_origin, entity.get_esp_data, entity.get_player_name, entity.get_local_player
local client_random_int, client_delay_call, client_eye_position, client_camera_angles, client_current_threat, client_set_event_callback = client.random_int, client.delay_call, client.eye_position, client.camera_angles, client.current_threat, client.set_event_callback
local base64 = require("gamesense/base64")
local g_entity = require("gamesense/entity")
local clipboard = require("gamesense/clipboard")
local genocide = {
    name = "Genocide",
    username = "Soheil",
    build = "BETA",
    version = "1.0.0",
    key = "genocide.cs",
    references = {},
    callbacks = {}
}

function string.random(length)
    local random = ""
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    for i=1, length do
        local char = client_random_int(1, #charset)
        random = random..charset:sub(char, char)
    end
    return random
end

function table.count(table)
    local count = 0
    for k,v in pairs(table) do
        count = count + 1
    end
    return count
end

function table.exist(table, value)
    for k,v in pairs(table) do
        if v == value then
            return true, k
        end
    end
    return false
end

function tickcount(value)
    return (math_floor(globals_curtime() * 100) % value) + 1
end

function math.tickcount(value)
    return (globals_tickcount() % value) + 1
end
function math.normalize(yaw)
    yaw = (yaw % 360 + 360) % 360
    return yaw > 180 and yaw - 360 or yaw
end

function math.calc_angle(start_pos, end_pos)
    if start_pos[1] == nil or end_pos[1] == nil then return {0, 0} end
    local delta_x, delta_y, delta_z = end_pos[1] - start_pos[1], end_pos[2] - start_pos[2], end_pos[3] - start_pos[3]
    if delta_x == 0 and delta_y == 0 then
        return {(delta_z > 0 and 270 or 90), 0}
    else
        local hyp = math_sqrt(delta_x * delta_x + delta_y * delta_y)
        local pitch = math_deg(math_atan2(-delta_z, hyp))
        local yaw = math_deg(math_atan2(delta_y, delta_x))
        return {pitch, yaw}
    end
end

function math.dist(start_pos, end_pos)
    local delta = {start_pos[1] - end_pos[1], start_pos[2] - end_pos[2]}
    return math_sqrt(delta[1] * delta[1] + delta[2] * delta[2])
end

function encode(value)
    return "GENOCIDE_GAMESENSE_"..base64.encode(value)
end

function decode(value)
    value = value:gsub("GENOCIDE_GAMESENSE_", "")
    return base64.decode(value)
end

local _animated = {}
function animated(name, number, scale, tick)
    local store_number = _animated[name]
    if store_number then
        if tickcount(tick) == tick then
            if number ~= store_number then
                print(number, " - ",store_number)
                if number > store_number then
                    if (store_number + scale) > number then
                        _animated[name] = number
                    else
                        _animated[name] = store_number + scale
                    end
                elseif number < store_number then
                    if (store_number - scale) < number then
                        _animated[name] = number
                    else
                        _animated[name] = store_number - scale
                    end
                end
            end
        end
    else
        _animated[name] = number
    end
    return _animated[name]
end

function genocide:reference_call(name)
    local data = self.references[name]
    self.references[name].history = {
        value = {},
        visibility = true
    }
    local history = self.references[name].history
    if not data then
        error(string.format("unknown reference %s", name))
    end
    return {
        get = function()
            if #data[1] > 1 then
                local items = {}
                for k,v in pairs(data[1]) do
                    items[k] = ui.get(v)
                end
                return items
            else
                return ui.get(data[1][1])
            end
        end,
        set = function(_, value, index)
            local index = index or 1
            if history.value[index] ~= value then
                history.value[index] = value
                local item = index and data[1][index] or data[1][1]
                pcall(ui_set, unpack({item, value}))
            end
        end,
        set_visible = function(_, visible, enable_loop)
            if not enable_loop then
                if history.visibility ~= visible then
                    history.visibility = visible
                    for k,v in pairs(data[1]) do
                        ui_set_visible(v, visible)
                    end
                end
            else
                for k,v in pairs(data[1]) do
                    ui_set_visible(v, visible)
                end
            end
        end,
        set_callback = function(_, callback, index)
            local item = index and data[1][index] or data[1][1]
            ui.set_callback(item, callback)
        end,
        update = function(_, value, index)
            local item = index and data[1][index] or data[1][1]
            ui.update(item, value)
        end,
        is_menu = function()
            return true
        end,
    }
end

function genocide:reference(data)
    local unique_name = string.random(8).."_"..table.count(self.references)
    local catch = {pcall(ui_reference, unpack(data))}
    if not catch[1] then
        error(string.format("%s cannot be defined (%s)", unique_name, catch[2]))
    end
    if self.references[unique_name] then
        error(string.format("%s is already taken in metatable", unique_name))
    end
    local n_catch = {}
    for k,v in pairs(catch) do
        if type(v) ~= "boolean" then
            table.insert(n_catch, v)
        end
    end
    self.references[unique_name] = {n_catch, data}
    return self:reference_call(unique_name)
end

function genocide:ui(new_item, data)
    local unique_name = string.random(8).."_"..table.count(self.references)
    local catch = {pcall(ui[new_item], unpack(data))}
    if not catch[1] then
        error(string.format("%s cannot be create", unique_name))
    end
    if self.references[unique_name] then
        error(string.format("%s is already taken in metatable", unique_name))
    end
    local n_catch = {}
    for k,v in pairs(catch) do
        if type(v) ~= "boolean" then
            table.insert(n_catch, v)
        end
    end
    self.references[unique_name] = {n_catch, data}
    return self:reference_call(unique_name)
end

function genocide.subscribe(event, callbacks)
    if not genocide.callbacks[event] then
        genocide.callbacks[event] = {}
    end
    for k,v in pairs(callbacks) do
        table.insert(genocide.callbacks[event], {callback = v})
    end
end

function genocide.launch()
    for k,v in pairs(genocide.callbacks) do
        for _,r in pairs(v) do
            client_set_event_callback(k, r.callback)
        end
    end
end

local reference = {
    antiaim = genocide:reference({"AA", "Anti-aimbot angles", "Enabled"}),
    pitch = genocide:reference({"AA", "Anti-aimbot angles", "Pitch"}),
    yawbase = genocide:reference({"AA", "Anti-aimbot angles", "Yaw base"}),
    yaw = genocide:reference({"AA", "Anti-aimbot angles", "Yaw"}),
    yawjitter = genocide:reference({"AA", "Anti-aimbot angles", "Yaw jitter"}),
    bodyyaw = genocide:reference({"AA", "Anti-aimbot angles", "Body yaw"}),
    fs_bodyyaw = genocide:reference({"AA", "Anti-aimbot angles", "Freestanding body yaw"}),
    edgeyaw = genocide:reference({"AA", "Anti-aimbot angles", "Edge yaw"}),
    freestanding = genocide:reference({"AA", "Anti-aimbot angles", "Freestanding"}),
    roll = genocide:reference({"AA", "Anti-aimbot angles", "Roll"}),
    doubletap = genocide:reference({"RAGE", "Aimbot", "Double tap"}),
    doubletap_limit = genocide:reference({"RAGE", "Aimbot", "Double tap fake lag limit"}),
    hideshot = genocide:reference({"AA", "Other", "On shot anti-aim"}),
    slowmotion = genocide:reference({"AA", "Other", "Slow motion"}),
    fakelag = genocide:reference({"AA", "Fake lag", "Enabled"}),
    fakelag_limit = genocide:reference({"AA", "Fake lag", "Limit"}),
    antiuntrusted = genocide:reference({"MISC", "Settings", "Anti-untrusted"}),
    fakeduck = genocide:reference({"RAGE", "Other", "Duck peek assist"}),
    quickpeek = genocide:reference({"RAGE", "Other", "Quick peek assist"}),
}

function is_exploit()
    return (reference.hideshot:get()[1] and reference.hideshot:get()[2]) or (reference.doubletap:get()[1] and reference.doubletap:get()[2]) 
end

function entity.velocity(self)
    if not self then return 0 end
    local x, y, z = entity_get_prop(self, "m_vecVelocity")
    return math_floor(math_sqrt(x*x + y*y + z*z))
end

function launch()
    local db = database.read(genocide.key) or {}
    if db.list == nil then
        db = {}
        db.startup = false
        db.list = {"Default"}
        db.last = ""
        database.write(genocide.key, db)
    end
    
    local mc = {"AntiAim", "AntiAim Builder", "Ragebot", "Visual", "Misc", "Config"}
    local antiaim_types = {"Exploit", "Fakelag"}
    local antiaim_states = {"Global", "Standing", "Moving", "Air", "Air-crouch", "Slowwalk", "Crouching", "On key"}
    local antiaim_preset = {}
    local dnsave = {"freestanding_key", "edge_key", "idealtick_key", "onkey"}
    local categorys = genocide:ui("new_combobox", {"AA", "Anti-aimbot angles", "              - GENOCIDE -", mc})
    local menu = {
        [mc[1]] = {
            antiuntrusted = genocide:ui("new_checkbox", {"AA", "Anti-aimbot angles", "Anti-untrusted"}),
            forcedefensive = genocide:ui("new_checkbox", {"AA", "Anti-aimbot angles", "Force defensive"}),
            freestanding = genocide:ui("new_checkbox", {"AA", "Anti-aimbot angles", "Freestanding"}),
            freestanding_key = genocide:ui("new_hotkey", {"AA", "Anti-aimbot angles", "\n", true}),
            freestanding_disbaler = genocide:ui("new_multiselect", {"AA", "Anti-aimbot angles", "Disabler", {"Yaw Jitter", "While InAir", "While Crouching", "While Slowwalk", "While Fakeduck"}}),
            edgeyaw = genocide:ui("new_checkbox", {"AA", "Anti-aimbot angles", "Edgeyaw"}),
            edge_key = genocide:ui("new_hotkey", {"AA", "Anti-aimbot angles", "\n", true}),
            edge_disbaler = genocide:ui("new_multiselect", {"AA", "Anti-aimbot angles", "Disabler", {"Yaw Jitter", "While InAir", "While Crouching", "While Slowwalk", "While Fakeduck"}}),
    
        },
        [mc[2]] = {
            enable = genocide:ui("new_checkbox", {"AA", "Anti-aimbot angles", "Enable Anti-aims"}),
            states = genocide:ui("new_combobox", {"AA", "Anti-aimbot angles", "States", antiaim_states}),
            builder = {}
        },
        [mc[3]] = {
            resolver = genocide:ui("new_checkbox", {"AA", "Anti-aimbot angles", "Resolver"}),
            resolver_key = genocide:ui("new_hotkey", {"AA", "Anti-aimbot angles", "\n", true}),
            idealtick = genocide:ui("new_checkbox", {"AA", "Anti-aimbot angles", "Idealtick"}),
            idealtick_key = genocide:ui("new_hotkey", {"AA", "Anti-aimbot angles", "\n", true}),
            idealtick_mode = genocide:ui("new_combobox", {"AA", "Anti-aimbot angles", "\n", {"Offensive", "Defensive"}}),
            idealtick_option = genocide:ui("new_multiselect", {"AA", "Anti-aimbot angles", "Options", {"Doubletap Fakelag Limit"}}),
            idealtick_limit = genocide:ui("new_slider", {"AA", "Anti-aimbot angles", "Doubletap Fakelag Limit", 1, 10, 1, true, "°"}),
        },
        [mc[4]] = {},
        [mc[5]] = {},
        [mc[6]] = {
            list = genocide:ui("new_listbox", {"AA", "Anti-aimbot angles", "\n", db.list}),
            name = genocide:ui("new_textbox", {"AA", "Anti-aimbot angles", "\n"}),
            startup = genocide:ui("new_checkbox", {"AA", "Anti-aimbot angles", "Load on startup"}),
            save = genocide:ui("new_button", {"AA", "Anti-aimbot angles", "Save", function()end}),
            load = genocide:ui("new_button", {"AA", "Anti-aimbot angles", "Load", function()end}),
            delete = genocide:ui("new_button", {"AA", "Anti-aimbot angles", "Delete", function()end}),
            export = genocide:ui("new_button", {"AA", "Anti-aimbot angles", "Export", function()end}),
            import = genocide:ui("new_button", {"AA", "Anti-aimbot angles", "Import", function()end}),
        }
    }
    
    menu[mc[6]].startup:set_callback(function()
        db.startup = menu[mc[6]].startup:get()
    end)
    
    menu[mc[6]].save:set_callback(function()
        local cfglist = menu[mc[6]].list:get() + 1
        local cfginput = menu[mc[6]].name:get()
        local config = save_config()
        local cfgname = db.list[cfglist]
        if #cfginput > 0 then
            if not table.exist(db.list, cfginput) then
                cfgname = cfginput
                table.insert(db.list, cfginput)
                menu[mc[6]].list:update(db.list)
                menu[mc[6]].name:set("")
                menu[mc[6]].list:set(#db.list - 1)
                database.write(cfginput, config)
            else
                database.write(cfgname, nil)
                database.write(cfgname, config)
            end
        else
            database.write(cfgname, nil)
            database.write(cfgname, config)
        end
        client.log(string.format("Config (%s) successfully saved!", cfgname))
    end)
    
    menu[mc[6]].load:set_callback(function()
        local cfglist = menu[mc[6]].list:get() + 1
        local cfgname = db.list[cfglist]
        local config = database.read(cfgname)
        if config then
            db.last = cfgname
            load_config(config)
            client.log(string.format("Config (%s) successfully loaded!", cfgname))
        else
            client.log(string.format("Failed to load config!"))
        end
    end)
    
    menu[mc[6]].delete:set_callback(function()
        local cfglist = menu[mc[6]].list:get() + 1
        local cfgname = db.list[cfglist]
        if cfgname ~= "Default" then
            table.remove(db.list, cfglist)
            database.write(cfgname, nil)
            menu[mc[6]].list:update(db.list)
            client.log(string.format("Config (%s) successfully removed!", cfgname))
        else
            client.log(string.format("You cant remove default config!"))
    
        end
    end)
    
    menu[mc[6]].export:set_callback(function()
        local cfglist = menu[mc[6]].list:get() + 1
        local cfgname = db.list[cfglist]
        local config = database.read(cfgname)
        if config then
            clipboard.set(encode(json.stringify(config)))
            client.log(string.format("Config (%s) successfully exported!", cfgname))
        else
            client.log(string.format("Failed to export config!"))
        end
    end)
    
    menu[mc[6]].import:set_callback(function()
        local cfglist = menu[mc[6]].list:get() + 1
        local cfgname = db.list[cfglist]
        local config = clipboard.get()
        if #config > 20 then
            load_config(json.parse(decode(config)))
            client.log(string.format("Config (%s) successfully imported!", cfgname))
        else
            client.log(string.format("Failed to import config!"))
        end
    end)
    
    menu[mc[6]].startup:set(db.startup)
    client_delay_call(2, function()
        if db.startup then
            local cfgname = db.last
            local config = database.read(cfgname)
            local exist, key = table.exist(db.list, cfgname)
            load_config(config)
            menu[mc[6]].list:set(key - 1)
            client.log(string.format("Config (%s) successfully loaded!", cfgname))
        end
    end)
    
    for k,v in pairs(antiaim_states) do
        local build = menu[mc[2]].builder
        build[v] = {}
        antiaim_preset[v] = {}
        build[v].type = genocide:ui("new_combobox", {"AA", "Anti-aimbot angles", v.." - Types", antiaim_types})
        for _, z in pairs(antiaim_types) do
            build[v][z] = {}
            antiaim_preset[v][z] = {}
            if v ~= "Global" then
                build[v][z].enable = genocide:ui("new_checkbox", {"AA", "Anti-aimbot angles", "["..z.."] Enable"})
            end
            if v == "On key" and z == "Exploit" then
                build[v][z].onkey = genocide:ui("new_hotkey", {"AA", "Anti-aimbot angles", "\n", true})
            end
            build[v][z].pitch = genocide:ui("new_combobox", {"AA", "Anti-aimbot angles", "Pitch", {"Off", "Default", "Up", "Down", "Minimal", "Random", "Defensive", "Custom"}})
            build[v][z].pitch_custom = genocide:ui("new_slider", {"AA", "Anti-aimbot angles", "\n", -89, 89, 0, true, "°"})
            build[v][z].yawbase = genocide:ui("new_combobox", {"AA", "Anti-aimbot angles", "Yaw base", {"Local view", "At targets"}})
            build[v][z].yaw = genocide:ui("new_combobox", {"AA", "Anti-aimbot angles", "Yaw", {"Off", "180", "Spin", "Static", "180 Z", "Crosshair"}})
            build[v][z].yawadd = genocide:ui("new_slider", {"AA", "Anti-aimbot angles", "\n", -180, 180, 0, true, "°"})
            build[v][z].yawjitter = genocide:ui("new_combobox", {"AA", "Anti-aimbot angles", "Yaw jitter", {"Off", "Offset", "Center", "Random", "Skitter", "Custom"}})
            build[v][z].yawoffset = genocide:ui("new_slider", {"AA", "Anti-aimbot angles", "\n", -180, 180, 0, true, "°"})
            build[v][z].leftoffset = genocide:ui("new_slider", {"AA", "Anti-aimbot angles", "Left Yaw", -180, 180, 0, true, "°"})
            build[v][z].rightoffset = genocide:ui("new_slider", {"AA", "Anti-aimbot angles", "Right Yaw", -180, 180, 0, true, "°"})
            build[v][z].jitterdelay = genocide:ui("new_slider", {"AA", "Anti-aimbot angles", "Delay", 4, 30, 0, true, "tk"})
            build[v][z].bodyyaw = genocide:ui("new_combobox", {"AA", "Anti-aimbot angles", "Body yaw", {"Off", "Static", "Jitter", "Opposite", "Custom Jitter"}})
            build[v][z].bodyoffset = genocide:ui("new_slider", {"AA", "Anti-aimbot angles", "\n", -180, 180, 0, true, "°"})
            build[v][z].leftlimit = genocide:ui("new_slider", {"AA", "Anti-aimbot angles", "Left Limit", -180, 180, 0, true, "°"})
            build[v][z].rightlimit = genocide:ui("new_slider", {"AA", "Anti-aimbot angles", "Right Limit", -180, 180, 0, true, "°"})
            build[v][z].limitdelay = genocide:ui("new_slider", {"AA", "Anti-aimbot angles", "Delay", 4, 30, 0, true, "tk"})
            if z == "Fakelag" then
                if (v == "Standing" or v == "Slowwalk" or v == "Crouching" or v == "On key") then
                    build[v][z].options = genocide:ui("new_multiselect", {"AA", "Anti-aimbot angles", "Options", {"Jitter", "Extended Desync"}})
                else
                    build[v][z].options = genocide:ui("new_multiselect", {"AA", "Anti-aimbot angles", "Options", {"Jitter"}})
                end
            else
                build[v][z].options = genocide:ui("new_multiselect", {"AA", "Anti-aimbot angles", "Options", {"Jitter", "Break LC"}})
                build[v][z].breaklc = genocide:ui("new_slider", {"AA", "Anti-aimbot angles", "Break LC", 1, 10, 1, true})
            end
            build[v][z].freestanding = genocide:ui("new_combobox", {"AA", "Anti-aimbot angles", "Freestanding", {"Off", "Peek Fake"}})
            build[v][z].roll = genocide:ui("new_combobox", {"AA", "Anti-aimbot angles", "Roll", {"Off", "Static", "Jitter", "Override", "Extended Angles"}})
            build[v][z].rolloffset = genocide:ui("new_slider", {"AA", "Anti-aimbot angles", "Offset", -45, 45, 0, true, "°"})
            build[v][z].rolloverride = genocide:ui("new_slider", {"AA", "Anti-aimbot angles", "Override Offset", -100, 100, 0, true, "°"})
            build[v][z].extendedpitch = genocide:ui("new_slider", {"AA", "Anti-aimbot angles", "Pitch", 0, 90, 0, true, "°"})
            build[v][z].extendedoffset = genocide:ui("new_slider", {"AA", "Anti-aimbot angles", "Roll", -180, 180, 0, true, "°"})
        end
    end
    
    local menu_history = {
        antiaim_tab = "",
        antiaim_type = ""
    }
    function menu_update()
        local selected = categorys:get()
        if selected == mc[1] then
            local freestanding = menu[mc[1]].freestanding:get()
            menu[mc[1]].freestanding_disbaler:set_visible(freestanding)
            local edgeyaw = menu[mc[1]].edgeyaw:get()
            menu[mc[1]].edge_disbaler:set_visible(edgeyaw)
        elseif selected == mc[2] then
            local enable = menu[mc[2]].enable:get()
            local state = menu[mc[2]].states:get()
            local antiaim_type = menu[mc[2]].builder[state].type:get()
            if menu_history.antiaim_tab ~= state or menu_history.antiaim_type ~= antiaim_type then
                menu_history.antiaim_tab = state
                menu_history.antiaim_type = antiaim_type
                for k,v in pairs(menu[mc[2]]) do
                    if k ~= "enable" then
                        if v.is_menu then
                            v:set_visible(enable)
                        else
                            for q,w in pairs(v) do
                                for r,t in pairs(antiaim_types) do
                                    local aatype = w.type:get()
                                    w.type:set_visible(enable and q == state)
                                    for a,s in pairs(w[t]) do
                                        if s.is_menu then
                                            s:set_visible(enable and q == state and aatype == t)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                client_delay_call(5, function()
                    menu_history = {antiaim_tab = "",antiaim_type = ""}
                end)
            end
            for k,v in pairs(menu[mc[2]].builder) do
                if state == k then
                    local aatype = v.type:get()
                    local enable_antiaim = k == "Global" and true or v[aatype].enable:get()
                    enable_antiaim = enable_antiaim and enable
                    v[aatype].pitch:set_visible(enable_antiaim)
                    local pitch = v[aatype].pitch:get()
                    v[aatype].pitch_custom:set_visible(enable_antiaim and pitch == "Custom")
                    v[aatype].yaw:set_visible(enable_antiaim)
                    v[aatype].yawbase:set_visible(enable_antiaim)
                    local yaw = v[aatype].yaw:get()
                    v[aatype].yawadd:set_visible(enable_antiaim and yaw ~= "Off")
                    v[aatype].yawjitter:set_visible(enable_antiaim)
                    local yawjitter = v[aatype].yawjitter:get()
                    v[aatype].yawoffset:set_visible(enable_antiaim and (yawjitter ~= "Off" and yawjitter ~= "Custom"))
                    v[aatype].leftoffset:set_visible(enable_antiaim and yawjitter == "Custom")
                    v[aatype].rightoffset:set_visible(enable_antiaim and yawjitter == "Custom")
                    v[aatype].jitterdelay:set_visible(enable_antiaim and yawjitter == "Custom")
                    v[aatype].bodyyaw:set_visible(enable_antiaim)
                    local bodyyaw = v[aatype].bodyyaw:get()
                    v[aatype].bodyoffset:set_visible(enable_antiaim and (bodyyaw ~= "Off" and bodyyaw ~= "Opposite" and bodyyaw ~= "Custom Jitter"))
                    v[aatype].leftlimit:set_visible(enable_antiaim and (bodyyaw == "Custom Jitter"))
                    v[aatype].rightlimit:set_visible(enable_antiaim and (bodyyaw == "Custom Jitter"))
                    v[aatype].limitdelay:set_visible(enable_antiaim and (bodyyaw == "Custom Jitter"))
                    v[aatype].options:set_visible(enable_antiaim)
                    local options = v[aatype].options:get()
                    if aatype == "Exploit" then
                        v[aatype].breaklc:set_visible(enable_antiaim and table.exist(options, "Break LC"))
                    end
                    v[aatype].freestanding:set_visible(enable_antiaim)
                    v[aatype].roll:set_visible(enable_antiaim)
                    local roll = v[aatype].roll:get()
                    v[aatype].rolloffset:set_visible(enable_antiaim and (roll == "Static" or roll == "Jitter"))
                    v[aatype].rolloverride:set_visible(enable_antiaim and roll == "Override")
                    v[aatype].extendedpitch:set_visible(enable_antiaim and roll == "Extended Angles")
                    v[aatype].extendedoffset:set_visible(enable_antiaim and roll == "Extended Angles")
                end
            end
        elseif selected == mc[3] then
            local idealtick = menu[mc[3]].idealtick:get()
            menu[mc[3]].idealtick_mode:set_visible(idealtick)
            menu[mc[3]].idealtick_option:set_visible(idealtick)
            local idealtick_option = menu[mc[3]].idealtick_option:get()
            menu[mc[3]].idealtick_limit:set_visible(idealtick and table.exist(idealtick_option, "Doubletap Fakelag Limit"))
        end
    end
    
    function save_config()
        local data = {}
        for k,v in pairs(menu) do
            if k ~= mc[6] then
                data[k] = {}
                for q,w in pairs(v) do
                    if w.is_menu then
                        if not table.exist(dnsave, q) then
                            data[k][q] = w:get()
                        end
                    else
                        data[k][q] = {}
                        for e,r in pairs(w) do
                            data[k][q][e] = {}
                            for t,y in pairs(r) do
                                if y.is_menu then
                                    if not table.exist(dnsave, t) then
                                        data[k][q][e][t] = y:get()
                                    end
                                else
                                    data[k][q][e][t] = {}
                                    for f,s in pairs(y) do
                                        if s.is_menu then
                                            if not table.exist(dnsave, f) then
                                                data[k][q][e][t][f] = s:get()
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return data
    end
    
    function load_config(data)
        for k,v in pairs(data) do
            for q,w in pairs(v) do
                if type(w) ~= "table" or (q == "freestanding_disbaler" or q == "edge_disbaler" or q == "idealtick_option") then
                    if menu[k][q] then
                        menu[k][q]:set(w)
                    end
                else
                    for e,r in pairs(w) do
                        for t,y in pairs(r) do
                            if type(y) ~= "table" then
                                if menu[k][q][e][t] then
                                    menu[k][q][e][t]:set(y)
                                end
                            else
                                for f,s in pairs(y) do
                                    if menu[k][q][e][t][f] then
                                        menu[k][q][e][t][f]:set(s)
                                        antiaim_preset[e][t][f] = s
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    _LAST_CATEGORY = nil
    function category_update()
        local selected = categorys:get()
        if selected ~= _LAST_CATEGORY then
            _LAST_CATEGORY = selected
            for k,v in pairs(mc) do
                for x,z in pairs(menu[v]) do
                    if z.is_menu then
                        z:set_visible(v == selected)
                    else
                        for j,o in pairs(z) do
                            for q,a in pairs(o) do
                                if a.is_menu then
                                    a:set_visible(v == selected)
                                else
                                    for h,b in pairs(a) do
                                        if b.is_menu then
                                            b:set_visible(v == selected)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    function get_preset()
        for k,v in pairs(menu[mc[2]].builder) do
            for a,s in pairs(antiaim_types) do
                for q,w in pairs(v[s]) do
                    antiaim_preset[k][s][q] = w:get()
                end
            end
        end
    end
    
    function antiaim_tab(visibility)
        reference.antiaim:set_visible(visibility, true)
        reference.pitch:set_visible(visibility, true)
        reference.yawbase:set_visible(visibility, true)
        reference.yaw:set_visible(visibility, true)
        reference.yawjitter:set_visible(visibility, true)
        reference.bodyyaw:set_visible(visibility, true)
        reference.fs_bodyyaw:set_visible(visibility, true)
        reference.edgeyaw:set_visible(visibility, true)
        reference.freestanding:set_visible(visibility, true)
        reference.roll:set_visible(visibility, true)
    end
    
    function get_state(cmd)
        local localplayer = entity_get_local_player()
        local velocity = entity.velocity(localplayer)
        local flags = entity_get_prop(localplayer, "m_fFlags")
        local in_air = bit_band(flags, 1) ~= 1
        local onkey, onkey_k = menu[mc[2]].builder['On key']['Exploit'].enable:get(), menu[mc[2]].builder['On key']['Exploit'].onkey:get()
        local slowmotion, slowmotion_key = reference.slowmotion:get()[1], reference.slowmotion:get()[2]
        if onkey and onkey_k then return "On key" end
        if (cmd.in_jump == 1 or in_air) and cmd.in_duck == 1 then return "Air-crouch" end
        if (cmd.in_jump == 1 or in_air) then return "Air" end
        if cmd.in_duck == 1 then return "Crouching" end
        if slowmotion and slowmotion_key then return "Slowwalk" end
        if velocity > 2 then
            return "Moving"
        else
            return "Standing"
        end
    end
    
    function freestanding(state)
        local disbaled = false
        local fs = reference.freestanding:get()
        local self_fs = menu[mc[1]].freestanding:get()
        local self_fs_key = menu[mc[1]].freestanding_key:get()
        local self_fs_disbaler = menu[mc[1]].freestanding_disbaler:get()
        if self_fs and self_fs_key then
            if table.exist(self_fs_disbaler, "While InAir") then
                if state == "Air" or state == "Air-crouch" then
                    disbaled = true
                end
            end
            if table.exist(self_fs_disbaler, "While Crouching") then
                if state == "Crouching" then
                    disbaled = true
                end
            end
            if table.exist(self_fs_disbaler, "While Slowwalk") then
                if state == "Slowwalk" then
                    disbaled = true
                end
            end
            if table.exist(self_fs_disbaler, "While Fakeduck") then
                if reference.fakeduck:get() then
                    disbaled = true
                end
            end
            if table.exist(self_fs_disbaler, "Yaw Jitter") then
                if state == "Standing" or state == "Moving" then
                    reference.yawjitter:set("Off")
                    reference.bodyyaw:set("Static")
                    reference.bodyyaw:set(0, 2)
                end
            end
        end
        reference.freestanding:set((self_fs and self_fs_key) and not disbaled)
        reference.freestanding:set("Always On", 2)
    end
    
    function edgeyaw(state)
        local disbaled = false
        local edge = reference.edgeyaw:get()
        local self_ey = menu[mc[1]].edgeyaw:get()
        local self_ey_key = menu[mc[1]].edge_key:get()
        local self_ey_disbaler = menu[mc[1]].edge_disbaler:get()
        if self_ey and self_ey_key then
            if table.exist(self_ey_disbaler, "While InAir") then
                if state == "Air" or state == "Air-crouch" then
                    disbaled = true
                end
            end
            if table.exist(self_ey_disbaler, "While Crouching") then
                if state == "Crouching" then
                    disbaled = true
                end
            end
            if table.exist(self_ey_disbaler, "While Slowwalk") then
                if state == "Slowwalk" then
                    disbaled = true
                end
            end
            if table.exist(self_ey_disbaler, "While Fakeduck") then
                if reference.fakeduck:get() then
                    disbaled = true
                end
            end
            if table.exist(self_ey_disbaler, "Yaw Jitter") then
                if state == "Standing" or state == "Moving" then
                    reference.yawjitter:set("Off")
                    reference.bodyyaw:set("Static")
                    reference.bodyyaw:set(0, 2)
                end
            end
        end
        reference.edgeyaw:set((self_ey and self_ey_key) and not disbaled)
    end
    
    function can_use()
        local can_use = true
        local entitylist = {"CPlantedC4", "CHostage", "CPropDoorRotating"}
        local localplayer = entity_get_local_player()
        if not localplayer then return can_use end
        local localorigin = {entity_get_origin(localplayer)}
        for k,v in pairs(entitylist) do
            local entity_prop = entity.get_all(v)
            if entity_prop[1] then
                for q,prop in pairs(entity_prop) do
                    if prop then
                        local entity_origin = {entity_get_origin(prop)}
                        local distance = math.dist(localorigin, entity_origin)
                        if distance <= 80 then
                            can_use = false
                        end
                    end
                end
    
            end
        end
        return can_use
    end
    
    function extended_desync(cmd)
        local localplayer = entity_get_local_player()
        local velocity = entity.velocity(localplayer)
        if velocity > 88 then return end
        if reference.fakeduck:get() then return end
        if (entity_get_prop(localplayer, "m_MoveType") or 0) == 9 then return end
        if cmd.in_forward ~= 0 or cmd.in_back ~= 0 then return end
        cmd.in_forward = 1
        cmd.forwardmove = 0.00000001
    end
    
    local ideal = {
        enable = false,
        mode = nil,
    }
    local STATES = ""
    function update_antiaim(cmd, data, state)
        if data then
            local target = client_current_threat()
            local exploit = is_exploit() and "Exploit" or "Fakelag"
            local is_enable = menu[mc[2]].builder[state][exploit].enable:get()
            data = is_enable and data[exploit] or antiaim_preset["Global"][exploit]
            if state == "On key" then
                if can_use() then
                    cmd.in_use = 0
                end
            end
            if not data.pitch then return end
            reference.antiaim:set(true)
            reference.antiuntrusted:set(menu[mc[1]].antiuntrusted:get())
            reference.pitch:set(data.pitch_custom, 2)
            reference.yawbase:set(target and data.yawbase or "Local view")
            reference.yaw:set(data.yaw)
            if data.yawjitter ~= "Custom" then
                reference.yaw:set(data.yawadd, 2)     
                reference.yawjitter:set(data.yawjitter)
                reference.yawjitter:set(data.yawoffset, 2)
            else
                reference.yawjitter:set("Off")
                reference.yaw:set(tickcount(data.jitterdelay) > data.jitterdelay / 2 and data.leftoffset or data.rightoffset, 2)
            end
            if data.pitch == "Defensive" then
                local esp_data = entity_get_esp_data(target or 0)
                if esp_data then
                    if bit_band(esp_data.flags, bit_lshift(1, 11)) == 0 then
                        reference.pitch:set(math.tickcount(10) >= 9 and "Up" or "Minimal")
                    else
                        reference.pitch:set("Minimal")
                        reference.yaw:set("180")
                        reference.yaw:set(0, 2)     
                    end
                end
            else
                if not menu[mc[1]].antiuntrusted:get() then
                    reference.pitch:set(data.pitch == "Down" and "Minimal" or data.pitch)
                else
                    reference.pitch:set(data.pitch)
                end
            end
            if table.exist(data.options, "Jitter") then
                local bodyvalue = math_abs(data.bodyoffset)
                reference.bodyyaw:set(tickcount(6) > 3 and -bodyvalue or bodyvalue, 2)
            else
                if data.bodyyaw == "Custom Jitter" then
                    reference.bodyyaw:set("Static")
                    reference.bodyyaw:set(tickcount(data.limitdelay) > data.limitdelay / 2 and data.leftlimit or data.rightlimit, 2)
                else
                    reference.bodyyaw:set(data.bodyyaw)
                    reference.bodyyaw:set(data.bodyoffset, 2)
                end
            end
            reference.fs_bodyyaw:set(data.freestanding == "Peek Fake")
            reference.roll:set(0)
            local idealoption = menu[mc[3]].idealtick_option:get()
            if ideal.enable and table.exist(idealoption, "Doubletap Fakelag Limit") then
                reference.doubletap_limit:set(menu[mc[3]].idealtick_limit:get())
            else
                reference.doubletap_limit:set(table.exist(data.options, "Break LC") and data.breaklc or 1)
            end
            cmd.force_defensive = menu[mc[1]].forcedefensive:get()
            if table.exist(data.options, "Extended Desync") then
                if cmd.chokedcommands >= reference.fakelag_limit:get() then
                    extended_desync(cmd)
                end
                if cmd.chokedcommands == 0 and cmd.in_attack ~= 1 then
                    cmd.allow_send_packet = false
                end
            end
            if data.roll == "Static" then
                cmd.roll = data.rolloffset
            elseif data.roll == "Jitter" then
                cmd.roll = tickcount(6) > 3 and data.rolloffset or -data.rolloffset
            elseif data.roll == "Override" then
                cmd.roll = data.rolloverride
            elseif data.roll == "Extended Angles" then
                local pitch, yaw = client_camera_angles()
                local baseyaw = yaw + 180
                if data.yawbase == "At targets" then
                    if target then
                        if entity_is_alive(target) then
                            local self_eyepostion = {client_eye_position()}
                            local target_origin = {entity_get_origin(target)}
                            if target_origin[1] then
                                local angle = math.calc_angle(self_eyepostion, target_origin)
                                if type(angle) == "table" then
                                    baseyaw = angle[2] + 180
                                end
                            end
                        end
                    end
                end
                local add_yaw = data.yaw ~= "Off" and data.yawadd or 0
                baseyaw = math.normalize(baseyaw + add_yaw)
                if exploit == "Fakelag" then
                    if cmd.chokedcommands >= reference.fakelag_limit:get() - 1 or cmd.chokedcommands == 1 then
                        if not menu[mc[1]].antiuntrusted:get() and data.extendedpitch ~= 0 then
                            cmd.pitch = 89 + data.extendedpitch
                            cmd.yaw = baseyaw
                        end
                        cmd.roll = data.extendedoffset
                    end
                    if cmd.chokedcommands == 0 and cmd.in_attack ~= 1 then
                        cmd.allow_send_packet = false
                    end
                else
                    if not menu[mc[1]].antiuntrusted:get() and data.extendedpitch ~= 0 then
                        cmd.pitch = 89 + data.extendedpitch
                        cmd.yaw = baseyaw
                    end
                    cmd.roll = data.extendedoffset
                end
            elseif data.roll == "Off" then 
                cmd.roll = 0
            end
            if reference.quickpeek:get()[2] and state == "Moving" then
                cmd.roll = 0
            end
            edgeyaw(state)
            freestanding(state)
        end
    end
    
    function idealtick(state)
        local idealkey = menu[mc[3]].idealtick_key:get()
        local idealmode = menu[mc[3]].idealtick_mode:get()
        local doubletap = reference.doubletap:get()
        if idealkey then
            if doubletap[1] and not ideal.enable then
                ideal.enable = true
                reference.doubletap:set("Always on", 2)
                if doubletap[3] ~= idealmode then
                    ideal.mode = doubletap[3]
                    reference.doubletap:set(idealmode, 3)
                end
            end
        end
        if ideal.enable and not idealkey then
            ideal.enable = false
            reference.doubletap:set("Toggle", 2)
            if ideal.mode ~= nil then
                reference.doubletap:set(ideal.mode, 3)
                ideal.mode = nil
            end
        end
    end
    
    function entity.get_player_state(self)
        local velocity = entity.velocity(self)
        local target = g_entity.new(self)
        local anim_state = target:get_anim_state()
        local pitch = anim_state.eye_angles_x
        if (pitch > 0 and pitch < 60) or (0 > pitch and pitch > -60) then return "Legit" end
        if not anim_state.on_ground and anim_state.duck_amount > 0.77 then return "Air-Crouch" end
        if not anim_state.on_ground then return "Air" end
        if anim_state.duck_amount > 0.77 then return "Crouching" end
        if velocity > 1 and velocity < 88 then
            return "Slowwalking"
        elseif velocity > 88 then
            return "Moving"
        else
            return "Standing"
        end
    end
    
    function entity.get_player_desync(self)
        local target = g_entity.new(self)
        local anim_state = target:get_anim_state()
        return math.normalize(anim_state.goal_feet_yaw - anim_state.eye_angles_y)
    end

    function entity.resolve(target, roll)
        local _,yaw = entity_get_prop(target, "m_angRotation");
        local pitch = 89 * ((2 * entity_get_prop(target, "m_flPoseParameter", 12)) -1);
        entity.set_prop(target, "m_angEyeAngles", pitch, yaw, roll);
    end

    local resolve_t = {
        is_hold = false,
        targets = {}
    }
    local Resolver_hold = false
    function resolver()
        menu[mc[3]].resolver_key:set("On hotkey")
        local resolver_key = menu[mc[3]].resolver_key:get()
        local target = client_current_threat()
        if resolver_key then
            if resolve_t.is_hold then return end
            if not target then return end
            if entity_is_dormant(target) then return end
            local target_name = entity_get_player_name(target)
            resolve_t.is_hold = true
            if resolve_t.targets[target] then
                resolve_t.targets[target] = nil
                client.log(string.format("Target (%s) removed from resolver!", target_name))
            else
                resolve_t.targets[target] = {entity = target, mode = "normal", bruteforce = false}
                client.log(string.format("Target (%s) added to resolver!", target_name))
            end
        else
            resolve_t.is_hold = false
        end
    end

    function resolver_loop()
        if table.count(resolve_t.targets) > 0 then
            local target = client_current_threat()
            if not target then return end
            if resolve_t.targets[target] then
                local desync = entity.get_player_desync(target)
                local get_state = entity.get_player_state(target)
                local bruteforce = resolve_t.targets[target].bruteforce
                if get_state == "Slowwalking" or get_state == "Standing" or get_state == "Air-Crouch" then
                    local roll = 35
                    entity.resolve(target, bruteforce and -roll or roll)
                else
                    entity.resolve(target, 0)
                end
            else
                entity.resolve(target, 0)
            end
        end
    end

    function resolver_reset()
        resolve_t.targets = {}
    end

    client.register_esp_flag("RESOLVER", 121, 245, 49, function(target)
        return resolve_t.targets[target]
    end)

    function ragebot(cmd)
        local state = get_state(cmd)
        local itick = menu[mc[3]].idealtick:get()
        local resolve = menu[mc[3]].resolver:get()
        if itick then
            idealtick(state)
        end
        if resolve then
            resolver()
        end
    end
    
    function antiaim(cmd)
        local localplayer = entity_get_local_player()
        if not localplayer then return end
        if antiaim then
            local state = get_state(cmd)
            update_antiaim(cmd, antiaim_preset[state], state)
        end
    end
    
    function resolver_e()
        local resolve = menu[mc[3]].resolver:get()
        if resolve then
            resolver_loop()
        end
    end
    
    function menu_stuff()
        if ui.is_menu_open() then
            antiaim_tab(false)
            get_preset()
            category_update()
            menu_update()
        end
    end

    function on_shutdown()
        antiaim_tab(true)
        resolver_reset()
    end
    
    function on_disconnect()
        resolver_reset()
    end

    function aim_miss(shot)
        local target = client_current_threat()
        if not target then return end
        if resolve_t.targets[target] then
            local bruteforce = resolve_t.targets[target].bruteforce
            resolve_t.targets[target].bruteforce = not bruteforce
        end
    end
    
    genocide.subscribe('paint_ui', {menu_stuff})
    genocide.subscribe('shutdown', {on_shutdown})
    genocide.subscribe('aim_miss', {aim_miss})
    genocide.subscribe('run_command', {ragebot, resolver_e})
    genocide.subscribe('setup_command', {antiaim})
    genocide.subscribe('cs_game_disconnected', {on_disconnect})
    genocide.launch()
end

launch()