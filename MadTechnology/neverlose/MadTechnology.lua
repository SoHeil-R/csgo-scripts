local version = "2"
local ffi = require("ffi")

local MT = {
    ui = ui,
    bit = bit,
    json = json,
    files = files,
    utils = utils,
    color = color,
    render = render,
    common = common,
    globals = globals,
    tostring = tostring,
}

ffi.cdef[[
    typedef struct
    {
        uint8_t r;
        uint8_t g;
        uint8_t b;
        uint8_t a;
    } color_struct_t;
    typedef void (__cdecl* color_log)(void*, color_struct_t&, const char* text, ...);
]]

local uintptr_t = ffi.typeof("uintptr_t**")
local color_struct_t = ffi.typeof("color_struct_t")
local create_interface = ffi.cast(uintptr_t, MT.utils.create_interface("vstdlib.dll", "VEngineCvar007"))
local color_log = ffi.cast("color_log", create_interface[0][25])

local username = MT.common.get_username()
local Charset = 'ASDFGHJKLQWERTYUIOPZXCVBNM'
local CharTable = {}

for c in Charset:gmatch"." do
    table.insert(CharTable, c)
end

function MT.random(length)
    local randomString = ""
    for i = 1, length do
      randomString = randomString .. CharTable[math.random(1, #CharTable)]
    end
    return randomString
end

function MT.gradient_text(color_1, color_2, text)
    local output = ''
    local len = #text-1
    local r1, g1, b1, a1 = color_1:unpack()
    local r2, g2, b2, a2 = color_2:unpack()
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

function MT.gradient_console(color_1, color_2, text)
    local output = ''
    local len = #text-1
    local r1, g1, b1, a1 = color_1:unpack()
    local r2, g2, b2, a2 = color_2:unpack()
    local rinc = (r2 - r1) / len
    local ginc = (g2 - g1) / len
    local binc = (b2 - b1) / len
    local ainc = (a2 - a1) / len
    for i=1, len+1 do
        color_log(create_interface, color_struct_t(r1, g1, b1, a1), text:sub(i, i))
        r1 = r1 + rinc
        g1 = g1 + ginc
        b1 = b1 + binc
        a1 = a1 + ainc
    end
end

function MT.console(text, color)
    MT.gradient_console(MT.color(0, 191, 255, 255), MT.color(40, 100, 252, 255), '[MADTECH]')
    color_log(create_interface, color_struct_t(color.r, color.g, color.b, color.a), string.format(' %s\n', text))
end

local config_manager = {
    ["active_config"] = 0,
    ['configlist'] = {"default"}
}

function MT.directory()
    return MT.common.get_game_directory():gsub('csgo', ''):sub(1, -2)..'/nl/madtechnology'
end

local IsDirectory = MT.files.read(MT.directory()..'/main.mt')
if not IsDirectory then
    MT.files.create_folder(MT.directory())
    MT.files.write(string.format('%s/main.mt', MT.directory()), MT.json.stringify(config_manager))
end

local sleep_table = {}
function MT.sleep(time, callback)
    table.insert(sleep_table, {livetime = MT.globals.curtime, time = time, callback = callback})
end

function MT.sleep_while()
    for k,v in pairs(sleep_table) do
        local predict_time = MT.globals.curtime - v.livetime
        if predict_time >= v.time then
            v.callback()
            sleep_table[k] = nil
        end
    end
end

function MT.build_tag(tag)
    local ret = { ' ' }
    for i = 1, #tag do
        table['insert'](ret, tag:sub(1, i))
    end
    for i = #ret - 1, 1, -1 do
        table['insert'](ret, ret[i])
    end
    return ret
end

function MT.load()
    MT.utils.console_exec('clear')
    MT.common.add_event(string.format("Welcome back, %s.", username))
    MT.console(string.format("Welcome back, %s.", username), MT.color(0, 255, 0, 255))
    local avatar_url = string.format("https://neverlose.cc/static/avatars/%s.png", username)
    local madtech_black = "https://cdn.discordapp.com/attachments/820336313680396299/879637219223175218/Untitled-1.png"
    local madtech_white = "https://cdn.discordapp.com/attachments/820336313680396299/879637225879511060/Untitled-2.png"
    local neverlose_logo = "https://cdn.discordapp.com/attachments/820336313680396299/883013021050499142/download.png"
    local Tahoma = MT.render.load_font('Tahoma', 16, 'b')
    MT.ui.sidebar(MT.gradient_text(MT.color(0, 191, 255, 255), MT.color(40, 100, 252, 255), 'Madtechnology'), 'hand-middle-finger')
    local madtechnology = MT.ui.create('Madtechnology')
    local refrence = {
        antiaim = {
            pitch = MT.ui.find('aimbot', 'anti aim', 'angles', 'pitch'),
            yaw = MT.ui.find('aimbot', 'anti aim', 'angles', 'yaw'),
            base = MT.ui.find('aimbot', 'anti aim', 'angles', 'yaw', 'base'),
            yaw_offset = MT.ui.find('aimbot', 'anti aim', 'angles', 'yaw', 'offset'),
            avoidbackstab = MT.ui.find('aimbot', 'anti aim', 'angles', 'yaw', 'avoid backstab'),
            yaw_modifier = MT.ui.find('aimbot', 'anti aim', 'angles', 'yaw modifier'),
            yaw_modifier_offset = MT.ui.find('aimbot', 'anti aim', 'angles', 'yaw modifier', 'offset'),
            bodyyaw = MT.ui.find('aimbot', 'anti aim', 'angles', 'body yaw'),
            inverter = MT.ui.find('aimbot', 'anti aim', 'angles', 'body yaw', 'inverter'),
            leftlimit = MT.ui.find('aimbot', 'anti aim', 'angles', 'body yaw', 'left limit'),
            rightlimit = MT.ui.find('aimbot', 'anti aim', 'angles', 'body yaw', 'right limit'),
            lby_option = MT.ui.find('aimbot', 'anti aim', 'angles', 'body yaw', 'options'),
            lby_freestanding = MT.ui.find('aimbot', 'anti aim', 'angles', 'body yaw', 'freestanding'),
            lby_onshot = MT.ui.find('aimbot', 'anti aim', 'angles', 'body yaw', 'on shot'),
            lby_mode = MT.ui.find('aimbot', 'anti aim', 'angles', 'body yaw', 'lby mode'),
            freestanding = MT.ui.find('aimbot', 'anti aim', 'angles', 'freestanding'),
            fs_disableyaw = MT.ui.find('aimbot', 'anti aim', 'angles', 'freestanding', 'disbale yaw modifiers'),
            fs_body = MT.ui.find('aimbot', 'anti aim', 'angles', 'freestanding', 'body freestanding'),
            extended_angles = MT.ui.find('aimbot', 'anti aim', 'angles', 'extended angles'),
            extended_angles_pitch = MT.ui.find('aimbot', 'anti aim', 'angles', 'extended angles', 'extended pitch'),
            extended_angles_roll = MT.ui.find('aimbot', 'anti aim', 'angles', 'extended angles', 'extended roll'),
            fakeduck = MT.ui.find('aimbot', 'anti aim', 'misc', 'fake duck'),
            slowwalk = MT.ui.find('aimbot', 'anti aim', 'misc', 'slow walk'),
            leg_movement = MT.ui.find('aimbot', 'anti aim', 'misc', 'leg movement'),
        },
        fakelag = {
            enable = MT.ui.find('aimbot', 'anti aim', 'fake lag', 'enabled'),
            limit = MT.ui.find('aimbot', 'anti aim', 'fake lag', 'limit'),
            variability = MT.ui.find('aimbot', 'anti aim', 'fake lag', 'variability'),
        },
        ragebot = {
            
        }

    }
    local menu = {}
    local categorysnames = {'AntiAim'}
    local antiaim_mods = {"Global", "Standing", "Moving", "Slow motion", "Air", "Crouching", "Onkey"}
    local categorys = madtechnology:combo('tab selection', categorysnames)
    local group_antiaim = MT.ui.create('AntiAim')
    local menu_elements = {
        ['AntiAim'] = {
            group_antiaim:label('test')
        }
    }

    -- --custom aa
    for k,v in pairs(antiaim_mods) do
        menu_elements['AntiAim'][v] = {}
        if v ~= "Global" then
            menu_elements['AntiAim'][v]['enable_aa'] = MT['Menu']['Switch']("Custom AA", "["..v.."] Enable", false, "")
        end
        if v == "Onkey" then
            menu_elements['AntiAim'][v]['Hotkey'] = MT['Menu']['Switch']("Custom AA", "["..v.."] Hotkey", false, "")
        end
        menu_elements['AntiAim'][v]['type'] = MT['Menu']['Combo']("Custom AA", "AA Type", {"Neverlose", "Custom"}, 0, "", function ()
            MT.typeOfAA()
        end)
        menu_elements['AntiAim'][v]['yaw_base'] = MT['Menu']['Combo']("Custom AA", "Yaw Base", {"Forward", "Backward", "Right", "Left", "At Target", "Freestanding"}, 0, "")
        --CM
        menu_elements['AntiAim'][v][1] = {}
        menu_elements['AntiAim'][v][1]['c_pitch'] = MT['Menu']['SliderInt']("Custom AA", "Pitch", 0, -90, 90, "")
        menu_elements['AntiAim'][v][1]['yaw_offset'] = MT['Menu']['SliderInt']("Custom AA", "Yaw offset", 0, -180, 180, "")
        menu_elements['AntiAim'][v][1]['lby_offset'] = MT['Menu']['SliderInt']("Custom AA", "LBY offset", 0, -58, 58, "")
        menu_elements['AntiAim'][v][1]['c_desync_onshot'] = MT['Menu']['Combo']("Custom AA", "Desync On Shot", {"Disabled", "Left", "Right", "Overlap on shot", "Oppostie"}, 0, "")
        menu_elements['AntiAim'][v][1]['desync_limit'] = MT['Menu']['SliderInt']("Custom AA", "Desync limit", 0, 0, 58, "")
        --NL
        menu_elements['AntiAim'][v][0] = {}
        menu_elements['AntiAim'][v][0]['pitch'] = MT['Menu']['Combo']("Custom AA", "Pitch", {"Disabled", "Down", "Fake Down", "Fake Up"}, 0, "")
        menu_elements['AntiAim'][v][0]['yaw_add'] = MT['Menu']['SliderInt']("Custom AA", "Yaw Add", 0.0, -180.0, 180.0, "")
        menu_elements['AntiAim'][v][0]['yaw_modifier'] = MT['Menu']['Combo']("Custom AA", "Yaw Modifier", {"Disabled", "Center", "Offset", "Random", "Spin"}, 0, "")
        menu_elements['AntiAim'][v][0]['modifire_degree'] = MT['Menu']['SliderInt']("Custom AA", "Modifier Degree", 0.0, -180.0, 180.0, "")
        menu_elements['AntiAim'][v][0]['jitter'] = MT['Menu']['Switch']("Custom AA", "Jitter", false, "")
        menu_elements['AntiAim'][v][0]['yawleft'] = MT['Menu']['SliderInt']("Custom AA", "Yaw Add Left", 0, 0, 180, "")
        menu_elements['AntiAim'][v][0]['yawright'] = MT['Menu']['SliderInt']("Custom AA", "Yaw Add Right", 0, 0, 180, "")
        menu_elements['AntiAim'][v][0]['inverter'] = MT['Menu']['Switch']("Custom AA", "Inverter", false, "")
        menu_elements['AntiAim'][v][0]['bodyyaw'] = MT['Menu']['Combo']("Custom AA", "Body Yaw", {"Disabled", "Freestanding", "Reversed freestand", "Movement", "Flick"}, 0, "")
        menu_elements['AntiAim'][v][0]['fakeoption'] = MT['Menu']['MultiCombo']("Custom AA", "Fake Options", {"Avoid Overlap", "Jitter", "Randomize Jitter", "Anti bruteforce"}, 0, "")
        menu_elements['AntiAim'][v][0]['lby_mode'] = MT['Menu']['Combo']("Custom AA", "LBY Mode", {"Disabled", "Oppostie", "Sway"}, 0, "")
        menu_elements['AntiAim'][v][0]['freestanding_desync'] = MT['Menu']['Combo']("Custom AA", "Freestanding Desync", {"Off", "Peek Fake", "Peek Real"}, 0, "")
        menu_elements['AntiAim'][v][0]['desync_onshot'] = MT['Menu']['Combo']("Custom AA", "Desync On Shot", {"Disabled", "Oppostie", "Freestanding", "Switch"}, 0, "")
        menu_elements['AntiAim'][v][0]['fakeyaw_type'] = MT['Menu']['Combo']("Custom AA", "Fake modes", {"Disabled", "Static", "Jitter", "Random"}, 0, "")
        menu_elements['AntiAim'][v][0]['fakeleft'] = MT['Menu']['SliderInt']("Custom AA", "Fake left", 0, 0, 60, "")
        menu_elements['AntiAim'][v][0]['fakeright'] = MT['Menu']['SliderInt']("Custom AA", "Fake right", 0, 0, 60, "")
        menu_elements['AntiAim'][v][0]['leanmodes'] = MT['Menu']['Combo']("Custom AA", "Lean modes", {"Disabled", "Static", "Jitter", "Freestanding"}, 0, "")
        menu_elements['AntiAim'][v][0]['leanamount_left'] = MT['Menu']['SliderInt']("Custom AA", "Lean amount left", 0, 0, 80, "")
        menu_elements['AntiAim'][v][0]['leanamount_right'] = MT['Menu']['SliderInt']("Custom AA", "Lean amount right", 0, 0, 80, "")
        if v == "Slow motion" then
            menu_elements['AntiAim'][v]['walkspeed'] = MT['Menu']['Switch']("Custom AA", "Custom Walk Speed", false, "")
            menu_elements['AntiAim'][v]['speed'] = MT['Menu']['SliderInt']("Custom AA", "Speed", 15, 0, 60, "")
        end
    end

    function MT.setAAType(table, atype)
        local n_type = atype == 1 and 0 or 1
        for k,v in pairs(table[atype]) do
            v:SetVisible(true)
        end
        for k,v in pairs(table[n_type]) do
            v:SetVisible(false)
        end
    end

    function MT.typeOfAA()
        local live_custom_mode = custom_modes[categorys['Anti-Aim']['custom_mode']:Get() + 1]
        local toa = categorys['Anti-Aim'][live_custom_mode]['type']:Get()
        local nga = toa == 1 and 0 or 1
        for k,v in pairs(categorys['Anti-Aim'][live_custom_mode]) do
            if k == toa then
                for x,z in pairs(v) do
                    z:SetVisible(true)
                end
            elseif k == nga then
                for x,z in pairs(v) do
                    z:SetVisible(false)
                end
            end
        end
    end

    function MT.UpdateCustomAA()
        if categorys['Anti-Aim']['custom_aa_enable']:Get() then
            local live_custom_mode = custom_modes[categorys['Anti-Aim']['custom_mode']:Get() + 1]
            for _, b in pairs(custom_modes) do
                local is_match = live_custom_mode == b and true or false
                for k, item in pairs(categorys['Anti-Aim'][b]) do
                    if type(item) == "table" then
                        for x, z in pairs(item) do
                            z:SetVisible(is_match)
                        end
                    else
                        item:SetVisible(is_match)
                    end
                end
            end
            MT.typeOfAA()
        end
    end

    function MT.UpdateMenu()
        local cate = category:Get()
        for k, tables in pairs(categorys) do
            if k ~= categorysnames[cate] then
                for _, items in pairs(tables) do
                    if type(items) == "table" then
                        for a, x in pairs(items) do
                            if type(x) == "table" then
                                for q, b in pairs(x) do
                                    b:SetVisible(false)
                                end
                            else
                                x:SetVisible(false)
                            end
                        end
                    else
                        items:SetVisible(false)
                    end
                end
            end
        end
    end

    MT['UpdateCustomAA']()
    MT['UpdateMenu']()

    if categorys['Misc']['anti_Defensive']:Get() then
        MT['Anti_Defensive'](true)
    end

    function MT.GetConfigData()
        configs = {}
        for k,v in pairs(categorys) do
            if k ~= "Indicators" then
                configs[k] = {}
                for name, tables in pairs(v) do
                    if type(tables) == "table" then
                        configs[k][name] = {}
                        for n,m in pairs(tables) do
                            if type(m) == "table" then
                                configs[k][name][tostring(n)] = {}
                                for z,x in pairs(m) do
                                    configs[k][name][tostring(n)][z] = x:Get()
                                end
                            else
                                configs[k][name][n] = m:Get()
                            end
                        end
                    else
                        configs[k][name] = tables:Get()
                    end
                end
            end
        end
        return configs
    end
    
    function MT.SetConfig(config)
        if type(config) == "table" and config['RageBot'] and config['Anti-Aim'] and config['Misc'] then
            for k,v in pairs(config) do
                for x,z in pairs(v) do
                    if type(z) == "table" then
                        for n,m in pairs(z) do
                            if type(m) == "table" then
                                for c,q in pairs(m) do
                                    local typeofaa = tonumber(n)
                                    categorys[k][x][typeofaa][c]:Set(q)
                                end
                            else
                                if categorys[k][x][n] then
                                    categorys[k][x][n]:Set(m)
                                end
                            end
                        end
                    else
                        if categorys[k][x] then
                            categorys[k][x]:Set(z)
                        end
                    end
                end
            end
            MT['UpdateCustomAA']()
            MT['UpdateMenu']()
        else
            MT['Cheat']['AddNotify']("MadTechnology", "Error! invaild config.")
        end
    end

    local AntiAims = {
        freestanding = false,
        desyncside = false,
        last_perss = false,
        is_manual = false,
        brute = 0,
        last_brute = 0,
        cache = {},
        autopeek_pos = {},
        roll_value = 0,
        roll_timer = 0,
        fastswitch = true,
        Legit_aa = {
            [0] = { --Static
                override_aa = true,
                yaw_base = 0,
                desynclimit = 58,
                YawOffset = 1,
                LBYOffset = -58,
                Overridepitch = 0,
                Desync_onshot = 4,
                inverteroverride = true
            },
            [1] = { --Freestand
                override_aa = false,
                pitch = 0,
                yaw_base = 0,
                yaw_add = 0,
                yaw_modifier = 0,
                modifier_degree = 0,
                inverter = false,
                left_limit = 59,
                right_limit = 59,
                fakeoption = {
                    [1] = false,
                    [2] = false,
                    [3] = false,
                    [4] = false
                },
                lby_mode = 0,
                freestanding_desync = 1,
                desync_on_shot = 1
            },
            [2] = { --Jitter
                override_aa = false,
                pitch = 0,
                yaw_base = 0,
                yaw_add = 0,
                yaw_modifier = 0,
                modifier_degree = 0,
                inverter = false,
                left_limit = 59,
                right_limit = 59,
                fakeoption = {
                    [1] = false,
                    [2] = true,
                    [3] = false,
                    [4] = false
                },
                lby_mode = 2,
                freestanding_desync = 0,
                desync_on_shot = 0
            },
        },
        base_aa = {
            ['standing'] = {
                override_aa = false,
                pitch = 1,
                yaw_base = 4,
                yaw_add = 1,
                yaw_modifier = 4,
                modifier_degree = -3,
                inverter = false,
                left_limit = 36,
                right_limit = 34,
                fakeoption = {
                    [1] = true,
                    [2] = false,
                    [3] = false,
                    [4] = true
                },
                lby_mode = 1,
                freestanding_desync = 0,
                desync_on_shot = 3
            },
            ['moving'] = {
                override_aa = false,
                pitch = 1,
                yaw_base = 4,
                yaw_add = 6,
                yaw_modifier = 1,
                modifier_degree = -2,
                inverter = false,
                left_limit = 56,
                right_limit = 54,
                fakeoption = {
                    [1] = true,
                    [2] = false,
                    [3] = false,
                    [4] = true
                },
                lby_mode = 1,
                freestanding_desync = 1,
                desync_on_shot = 3
            },
            ['slowwalk'] = {
                override_aa = false,
                pitch = 1,
                yaw_base = 1,
                yaw_add = 1,
                yaw_modifier = 2,
                modifier_degree = -1,
                inverter = true,
                left_limit = 34,
                right_limit = 34,
                fakeoption = {
                    [1] = true,
                    [2] = false,
                    [3] = false,
                    [4] = true
                },
                lby_mode = 1,
                freestanding_desync = 0,
                desync_on_shot = 0
            },
            ['air'] = {
                override_aa = false,
                pitch = 1,
                yaw_base = 4,
                yaw_add = 1,
                yaw_modifier = 0,
                modifier_degree = 0,
                inverter = false,
                left_limit = 44,
                right_limit = 44,
                fakeoption = {
                    [1] = false,
                    [2] = true,
                    [3] = false,
                    [4] = false
                },
                lby_mode = 1,
                freestanding_desync = 0,
                desync_on_shot = 0
            },
            ['crouching'] = {
                override_aa = false,
                pitch = 1,
                yaw_base = 4,
                yaw_add = -7,
                yaw_modifier = 4,
                modifier_degree = -7,
                inverter = true,
                left_limit = 48,
                right_limit = 48,
                fakeoption = {
                    [1] = true,
                    [2] = false,
                    [3] = false,
                    [4] = true
                },
                lby_mode = 2,
                freestanding_desync = 1,
                desync_on_shot = 0 
            },
        }
    }

    function MT.get_velocity(player)
        x = player:GetProp("DT_BasePlayer", "m_vecVelocity[0]")
        y = player:GetProp("DT_BasePlayer", "m_vecVelocity[1]")
        z = player:GetProp("DT_BasePlayer", "m_vecVelocity[2]")
        if x == nil then return end
        return math.sqrt(x*x + y*y + z*z)
    end

    function MT.get_aa_state(entity)
        local velocity = math['floor'](MT['get_velocity'](entity))
        local slowwalk = AntiAim_rf['slow_walk']:Get()
        local flags = entity:GetProp("m_fFlags")
        if MT['bit']['band'](flags, 1) == 0 or MT['Cheat']['IsKeyDown'](32) then return "air" end
        if MT['bit']['band'](flags, 2) ~= 0 then return "crouching" end
        if slowwalk then return "slowwalk" end
        local state = "standing"
        if velocity > 1 then
            state = "moving"
        else
            state = "standing"
        end
        return state
    end

    function MT.normalize_yaw(yaw)
        while yaw > 180 do yaw = yaw - 360 end
        while yaw < -180 do yaw = yaw + 360 end
        return yaw
    end

    function MT.world2scren(xdelta, ydelta)
        if xdelta == 0 and ydelta == 0 then
            return 0
        end
        return math['deg'](math['atan2'](ydelta, xdelta))
    end

    function MT.calcangle(local_pos, enemy_pos)
        local ydelta = local_pos['y'] - enemy_pos['y']
        local xdelta = local_pos['x'] - enemy_pos['x']
        local relativeyaw = math['atan']( ydelta / xdelta )
        relativeyaw = MT['normalize_yaw']( relativeyaw * 180 / math['pi'] )
        if xdelta >= 0 then
            relativeyaw = MT['normalize_yaw'](relativeyaw + 180)
        end
        return relativeyaw
    end

    function MT.extend_vector(pos,length,angle) 
        local rad = angle * math.pi / 180
        return pos + MT['Vector']['new']((math['cos'](rad) * length),(math['sin'](rad) * length),0)
    end

    function MT.get_damage(enemy, vec_end)
        local e = {}
        e[0] = enemy:GetHitboxCenter(5)
        e[1] = e[0] + MT['Vector']['new'](40,0,0)
        e[2] = e[0] + MT['Vector']['new'](0,40,0)
        e[3] = e[0] + MT['Vector']['new'](-40,0,0)
        e[4] = e[0] + MT['Vector']['new'](0,-40,0)
        e[5] = e[0] + MT['Vector']['new'](0,0,40)
        e[6] = e[0] + MT['Vector']['new'](0,0,-40)
        local best_fraction = 0
        for i = 0, 6 do
            local trace = MT['Cheat']['FireBullet'](enemy, e[i], vec_end)
            if trace['damage'] > best_fraction then
                best_fraction = trace['damage']
            end
        end
        return best_fraction
    end

    function MT.get_nearest_enemy()
        local local_player = MT['EntityList']['GetLocalPlayer']()
        if not local_player then return nil end
        local lpos = local_player:GetrenderOrigin()
        local viewangles = MT['EngineClient']['GetViewAngles']()
        local players = MT['EntityList']['GetPlayers']()
        if players == nil or #players == 0 then return nil end
        local data = {}
        local fov = 180
        for i = 1, #players do
            if players[i] == nil or players[i]:IsTeamMate() or players[i] == local_player or players[i]:IsDormant() or players[i]:GetProp("m_iHealth") <= 0 then goto skip end
            local epos = players[i]:GetProp("m_vecOrigin")
            local cur_fov = math['abs'](MT['normalize_yaw'](MT['world2scren'](lpos['x'] - epos['x'], lpos['y'] - epos['y']) - viewangles['yaw'] + 180))
            if cur_fov <= fov then
                data = {
                    id = players[i],
                    fov = cur_fov
                }
                fov = cur_fov
            end
            ::skip::
        end
        if data['id'] ~= nil then
            local epos = data['id']:GetProp("m_vecOrigin")
            data['yaw'] = MT['calcangle'](lpos, epos)
        end
        return data
    end

    function MT.get_desync()
        local none = false
        local localplayer = MT['EntityList']['GetLocalPlayer']()
        if not localplayer then return end
        local c_hitbox = localplayer:GetHitboxCenter(3)
        local viewangles = MT['EngineClient']['GetViewAngles']()
        local angles = {a_l = 0, a_r = 0, d_l = 0, d_r = 0}
        for i=20, 120, 10 do
            local angle_l = c_hitbox + MT['Cheat']['AngleToForward'](MT['QAngle']['new'](0, i + viewangles['yaw'], 0)) * 100
            local trace_l = MT['EngineTrace']['TraceRay'](c_hitbox, angle_l, localplayer, 0xFFFFFFFF)
            local dist_l = c_hitbox:DistTo(trace_l['endpos'])
            local angle_r = c_hitbox + MT['Cheat']['AngleToForward'](MT['QAngle']['new'](0, (-i) + viewangles['yaw'], 0)) * 100
            local trace_r = MT['EngineTrace']['TraceRay'](c_hitbox, angle_r, localplayer, 0xFFFFFFFF)
            local dist_r = c_hitbox:DistTo(trace_r['endpos'])
            if angles['d_l'] == 0 or dist_l - 1 > angles['d_l'] then
                angles['d_l'] = dist_l
                angles['a_l'] = i
            end
            if angles['d_r'] == 0 or dist_r - 1 > angles['d_r'] then
                angles['d_r'] = dist_r
                angles['a_r'] = -i
            end
        end
        if math['abs'](angles['a_l']) < math['abs'](angles['a_r']) then
            AntiAims['desyncside'] = true
        elseif math['abs'](angles['a_l']) > math['abs'](angles['a_r']) then
            AntiAims['desyncside'] = false
        else
            none = true
        end
        return AntiAims['desyncside'], none
    end

    function MT.set_prop(localplayer, layer, min_val, max_val)
        local localplayer = ffi['cast']("unsigned int", localplayer)
        if localplayer == 0x0 then return end
        local offsets = ffi['cast']("void**", localplayer + 0x2950)[0]
        if not offsets then return false end
        local get_layers = get_pose_params(offsets, layer)
        if get_layers == 0x0 then return end
        if not AntiAims['cache'][layer] then
            AntiAims['cache'][layer] = {}
            AntiAims['cache'][layer] = {
                m_flStart = get_layers['m_flStart'],
                m_flEnd = get_layers['m_flEnd'],
                m_flState = get_layers['m_flState'],
                applied = false
            }
            return true
        end
        if not AntiAims['cache'][layer]['applied'] and min_val then
            get_layers['m_flStart'] = min_val
            get_layers['m_flEnd'] = max_val
            get_layers['m_flState'] = (get_layers['m_flStart'] + get_layers['m_flEnd']) / 2
            AntiAims['cache'][layer]['applied'] = true
            return true
        end
        if AntiAims['cache'][layer]['applied'] then
            get_layers['m_flStart'] = AntiAims['cache'][layer]['m_flStart']
            get_layers['m_flEnd'] = AntiAims['cache'][layer]['m_flEnd']
            get_layers['m_flState'] = AntiAims['cache'][layer]['m_flState']
            AntiAims['cache'][layer]['applied'] = false
            return true
        end
        return false
    end

    function MT.AAHandler(data, is_else)
        if data then
            local brute_nm = AntiAims['brute']
            local fakelimit = 0
            local can_brute = false
            local brute_invert = false
            if brute_nm ~= 0 then
                fakelimit = categorys['Antibruteforce']['brute'][brute_nm]:Get()
                if fakelimit > 0 then
                    brute_invert = true
                else
                    brute_invert = false
                end
                can_brute = true
                fakelimit = math['abs'](fakelimit)
            end
            if data['override_aa'] then
                if data['inverteroverride'] then
                    MT['AntiAim']['OverrideInverter'](true)
                else
                    MT['AntiAim']['OverrideInverter'](false)
                end
                if data['desynclimit'] then
                    MT['AntiAim']['OverrideLimit'](data['desynclimit'])
                elseif is_else then
                    MT['AntiAim']['OverrideLimit'](0)
                end
                if data['YawOffset'] then
                    MT['AntiAim']['OverrideYawOffset'](data['YawOffset'])
                elseif is_else then
                    MT['AntiAim']['OverrideYawOffset'](0)
                end
                if data['LBYOffset'] then
                    if can_brute then
                        MT['AntiAim']['OverrideLBYOffset'](fakelimit)
                    else
                        MT['AntiAim']['OverrideLBYOffset'](data['LBYOffset'])
                    end
                elseif is_else then
                    MT['AntiAim']['OverrideLBYOffset'](0)
                end
                if data['Overridepitch'] then
                    MT['AntiAim']['OverridePitch'](data['Overridepitch'])
                elseif is_else then
                    MT['AntiAim']['OverridePitch'](0)
                end
                if data['Desync_onshot'] then
                    MT['AntiAim']['OverrideDesyncOnShot'](data['Desync_onshot'])
                elseif is_else then
                    MT['AntiAim']['OverrideDesyncOnShot'](0)
                end
            end
            if data['pitch'] then
                AntiAim_rf['pitch']:Set(data['pitch'])
            elseif is_else then
                AntiAim_rf['pitch']:Set(0)
            end
            if data['yaw_base'] then
                AntiAim_rf['yaw_base']:Set(AntiAims['freestanding'] and 5 or data['yaw_base'])
            elseif is_else then
                AntiAim_rf['yaw_base']:Set(0)
            end
            if data['yaw_add'] then
                AntiAim_rf['yaw_add']:Set(data['yaw_add'])
            elseif is_else then
                AntiAim_rf['yaw_add']:Set(0)
            end
            if data['yaw_modifier'] then
                AntiAim_rf['yaw_modifier']:Set(data['yaw_modifier'])
            elseif is_else then
                AntiAim_rf['yaw_modifier']:Set(0)
            end
            if data['modifier_degree'] then
                AntiAim_rf['modifier_degree']:Set(data['modifier_degree'])
            elseif is_else then
                AntiAim_rf['modifier_degree']:Set(0)
            end
            if data['inverter'] then
                if can_brute then
                    AntiAim_rf['inverter']:Set(brute_invert)
                else
                    AntiAim_rf['inverter']:Set(data['inverter'])
                end
            else
                AntiAim_rf['inverter']:Set(false)
            end
            if data['left_limit'] then
                if can_brute then
                    AntiAim_rf['left_limit']:Set(fakelimit)
                else
                    AntiAim_rf['left_limit']:Set(data['left_limit'])
                end
            elseif is_else then
                AntiAim_rf['left_limit']:Set(0)
            end
            if data['right_limit'] then
                AntiAim_rf['right_limit']:Set(not can_brute and data['right_limit'] or fakelimit)
            elseif is_else then
                AntiAim_rf['right_limit']:Set(0)
            end
            if data['fakeoption'] then
                if type(data['fakeoption']) == "table" then
                    for k,v in pairs(data['fakeoption']) do
                        AntiAim_rf['fakeoption']:SetBool(k, v)
                    end
                else
                    for k,v in pairs(data['fakeoption']) do
                        AntiAim_rf['fakeoption']:SetBool(k, false)
                    end
                end
            end
            if data['lby_mode'] then
                AntiAim_rf['lby_mode']:Set(data['lby_mode'])
            elseif is_else then
                AntiAim_rf['lby_mode']:Set(0)
            end
            if data['freestanding_desync'] then
                AntiAim_rf['freestanding_desync']:Set(data['freestanding_desync'])
            elseif is_else then
                AntiAim_rf['freestanding_desync']:Set(0)
            end
            if data['desync_on_shot'] then
                AntiAim_rf['desync_on_shot']:Set(data['desync_on_shot'])
            elseif is_else then
                AntiAim_rf['desync_on_shot']:Set(0)
            end
        end
    end

    function MT.legit_aa(cmd, localplayer, custom_AA)
        local bomb, hostage, doors = MT['EntityList']['GetEntitiesByClassID'](129), MT['EntityList']['GetEntitiesByClassID'](97), MT['EntityList']['GetEntitiesByClassID'](143)
        local class_name_weapon = localplayer:GetActiveWeapon():GetClassName()   
        if class_name_weapon and class_name_weapon == "CC4" then return end
        local final_dist = math.huge
        for k, v in pairs(doors) do 
            local curr_dist = math.abs(localplayer:GetrenderOrigin():Length() - v:GetrenderOrigin():Length()) 
            if  curr_dist <= final_dist then final_dist = curr_dist end
        end
        if final_dist <= 55 then return end       
        if bomb[1] ~= nil or bomb[0] ~= nil then
            for i = 1, #bomb do
                local position = bomb[i]:GetProp("DT_BaseEntity", "m_vecOrigin")
                local origin = localplayer:GetPlayer():GetEyePosition()
                local vec = MT['Vector']['new'](origin['x'], origin['y'], origin['z'])
                local distance = vec:DistTo(position)
                local backward_Def = categorys['Anti-Aim']['Legit_aa_backward']:Get()
                if distance and distance <= 120 then 
                    if backward_Def then
                        return MT['AAHandler'](AntiAims['base_aa']['standing'], false) 
                    else
                        return
                    end
                end
            end
        elseif hostage[1] ~= nil then
            for f = 1, #hostage do
                if f > 1 then
                    local position = hostage[f]:GetProp("DT_BaseEntity", "m_vecOrigin")
                    local position2 = hostage[f-1]:GetProp("DT_BaseEntity", "m_vecOrigin")
                    local origin = localplayer:GetPlayer():GetEyePosition()
                    local vec = MT['Vector']['new'](origin['x'], origin['y'], origin['z'])
                    local distance = vec:DistTo(position)
                    local distance2 = vec:DistTo(position2)
                    if distance > 100 and distance2 > 100 then
                        cmd['buttons'] = MT['bit']['band'](cmd['buttons'], MT['bit']['bnot'](32))
                    end
                end
            end
        else
            cmd['buttons'] = MT['bit']['band'](cmd['buttons'], MT['bit']['bnot'](32))
        end
        if not custom_AA then
            if categorys['Anti-Aim']['Legit_aa_modes']:Get() == 1 then
                AntiAims['Legit_aa'][categorys['Anti-Aim']['Legit_aa_modes']:Get()]['inverter'] = MT['get_desync']()
                MT['AAHandler'](AntiAims['Legit_aa'][categorys['Anti-Aim']['Legit_aa_modes']:Get()], false)
            else
                MT['AAHandler'](AntiAims['Legit_aa'][categorys['Anti-Aim']['Legit_aa_modes']:Get()], false)
            end
        else
            local typeofaa = categorys['Anti-Aim']["Onkey"]['type']:Get()
            local yaw_base = categorys['Anti-Aim']['Onkey']['yaw_base']:Get()
            if typeofaa == 0 then
                local bodyyaw = MT['BodyYawHandler']("Onkey")
                local inverter = false
                local fake_option = {}
                local get_desync = MT['get_desync']()
                local pitch = categorys['Anti-Aim']["Onkey"][0]['pitch']:Get()
                local yaw_add = categorys['Anti-Aim']["Onkey"][0]['yaw_add']:Get()
                local yaw_modifier = categorys['Anti-Aim']["Onkey"][0]['yaw_modifier']:Get()
                local modifire_degree = categorys['Anti-Aim']["Onkey"][0]['modifire_degree']:Get()
                if bodyyaw == "Disabled" then
                    inverter = categorys['Anti-Aim']["Onkey"][0]['inverter']:Get()
                else
                    inverter = bodyyaw
                end
                local fakeoption = categorys['Anti-Aim']["Onkey"][0]['fakeoption']
                fake_option = {
                    [1] = fakeoption:GetBool(1),
                    [2] = fakeoption:GetBool(2),
                    [3] = fakeoption:GetBool(3),
                    [4] = fakeoption:GetBool(4)
                }
                local lby_mode = categorys['Anti-Aim']["Onkey"][0]['lby_mode']:Get()
                local freestanding_desync = categorys['Anti-Aim']["Onkey"][0]['freestanding_desync']:Get()
                local desync_onshot = categorys['Anti-Aim']["Onkey"][0]['desync_onshot']:Get()
                local fakemodes = categorys['Anti-Aim']["Onkey"][0]['fakeyaw_type']:Get()
                local fakeleft = categorys['Anti-Aim']["Onkey"][0]['fakeleft']:Get()
                local fakeright = categorys['Anti-Aim']["Onkey"][0]['fakeright']:Get()
                if fakemodes == 2 then
                    inverter = AntiAims['fastswitch'] and true or false
                elseif fakemodes == 3 then
                    fakeleft = math.random(1, fakeleft)
                    fakeright = math.random(1, fakeright)
                end
                local leanamount = 0
                local leanmodes = categorys['Anti-Aim']["Onkey"][0]['leanmodes']:Get()
                local leanamount_left = categorys['Anti-Aim']["Onkey"][0]['leanamount_left']:Get()
                local leanamount_right = categorys['Anti-Aim']["Onkey"][0]['leanamount_right']:Get()
                if leanmodes == 1 then
                    leanamount = leanamount_right or leanamount_left
                elseif leanmodes == 2 then
                    leanamount = AntiAims['fastswitch'] and leanamount_left or leanamount_right
                elseif leanmodes == 3 then
                    leanamount = get_desync and leanamount_left or leanamount_right
                end
                MT['AAHandler']({
                    override_aa = false,
                    pitch = pitch,
                    yaw_base = yaw_base,
                    yaw_add = yaw_add,
                    yaw_modifier = yaw_modifier,
                    modifier_degree = modifire_degree,
                    inverter = inverter,
                    left_limit = fakeleft,
                    right_limit = fakeright,
                    fakeoption = fake_option,
                    lby_mode = lby_mode,
                    freestanding_desync = freestanding_desync,
                    desync_on_shot = desync_onshot
                }, false)
                cmd['viewangles']['roll'] = leanamount
            else
                local pitch = categorys['Anti-Aim']['Onkey'][1]['c_pitch']:Get()
                local yaw_offset = categorys['Anti-Aim']['Onkey'][1]['yaw_offset']:Get()
                local lby_offset = categorys['Anti-Aim']['Onkey'][1]['lby_offset']:Get()
                local desync_shot = categorys['Anti-Aim']['Onkey'][1]['c_desync_onshot']:Get()
                local desync_limit = categorys['Anti-Aim']['Onkey'][1]['desync_limit']:Get()
                MT['AAHandler']({
                    override_aa = true,
                    yaw_base = yaw_base,
                    yaw_add = 0,
                    desynclimit = desync_limit,
                    YawOffset = yaw_offset,
                    LBYOffset = lby_offset,
                    Overridepitch = pitch,
                    Desync_onshot = desync_shot,
                    inverteroverride = true
                }, false)
            end
        end

    end

    local clantag = MT['build_tag']('MadTechnology ')
    function MT.clantag_animation()
        if not MT['EngineClient']['IsConnected']() then return end
        local netchann_info = MT['EngineClient']['GetNetChannelInfo']()
        if netchann_info == nil then return end
        local latency = netchann_info:GetLatency(0) / MT['GlobalVars']['interval_per_tick']
        local tickcount_pred = MT['GlobalVars']['tickcount'] + latency
        local iter = math['floor'](math['fmod'](tickcount_pred / 40, #clantag + 1) + 1)
        MT['set_clantag'](clantag[iter])
    end

    local ragebot_data = {
        active_weapon = "",
        last_tick = false,
        last_dt_state = ragebot_rf['Doubletap']:Get(),
        can_tick = false,
        recharge = true,
        recharge_t = 0,
        last_time = 0,
        shot_time = 0,
        lagging = false,
        Modes_fl = {
            [0] = 0.02,
            [1] = 0.05,
            [2] = 0.1,
        },
        forcetp_wp = {
            [42] = 1,
            [31] = 2,
            [40] = 3,
            [9] = 4,
            [64] = 5
        },
        recharge_time = {
            [0.1] = 0.04,
            [0.2] = 0.05,
            [0.3] = 0.06,
            [0.4] = 0.07,
            [0.5] = 0.08,
            [0.6] = 0.09,
        },
        weapon_need_charge = {
            [38] = "Auto CT",
            [11] = "Auto TR",
            [1] = "Desert",
            [2] = "Dual berettas",
            [30] = "Tec-9",
        },
        idealtick = {
            [40] = 1,
            [9] = 2,
            [64] = 3
        },
        onshot = {},
        onshot_fire = false,
        forcebaim_wp = {
            [40] = 1,
            [9] = 2,
            [11] = 3,
            [38] = 3,
            [64] = 4,
            [1] = 5
        },
        defualt_bodyaim = ragebot_rf['bodyaim']:Get(),
        defualt_bodyaim_disabler = {
            [1] = ragebot_rf['bodyaim_db']:GetBool(1),
            [2] = ragebot_rf['bodyaim_db']:GetBool(2),
            [3] = ragebot_rf['bodyaim_db']:GetBool(3),
        },
        last_teleport = 0,
        teleport_delay = 2
    }
    function MT.round(num, numDecimalPlaces)
        return tonumber(string['format']("%." .. (numDecimalPlaces or 0) .. "f", num))
    end

    function MT.roundnm(x)
        return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
    end

    function MT.VectorLerp(vecSource, vecDestination, flPercentage)
        return vecSource + (vecDestination - vecSource) * flPercentage
    end

	function MT.ShouldRecharge()
		local mode = categorys['RageBot']['Doubletap_recharge_t']:Get();
		local hitboxes = { 0, 5, 6 };
		function MT.CanShoot()
			local me = MT['EntityList']['GetLocalPlayer']()
			if not me then
				return false
			end
			local eye_pos = me:GetEyePosition()
			local players = MT['EntityList']['GetPlayers']()
			if not players then
				return false
			end
			for _, player in pairs(players) do
				if player:IsDormant() or player:IsTeamMate() then
				goto continue end
				for i = 1, #hitboxes do
					local hitbox_pos = player:GetHitboxCenter(hitboxes[i]);
					local bullet = MT['Cheat']['FireBullet'](me, eye_pos, hitbox_pos);
					if not bullet then
						goto continue
					end
					if bullet.damage >= 5 then
						return false
					end
				end
				::continue::
			end
			return true
		end
		if mode == 0 then
			return true
        elseif mode == 1 then
			return MT['CanShoot']()
		elseif mode == 2 then
			if ragebot_data['recharge_t'] > 0 then
				local target = MT['EntityList']['GetClientEntity'](ragebot_data['recharge_t']):GetPlayer();
				if not target then
					return MT['CanShoot']()
				end
				if target:IsAlive() then
					return MT['CanShoot']()
				else
					ragebot_data['recharge_t'] = -1
					return true;
				end
			else
				ragebot_data['recharge_t'] = -1;
				return true;
			end
		end
		return false
	end
    
    function MT.forceonshot(live_t, old_t, player)
        local predict = MT['round'](live_t - old_t, 2)
        local onshot_time = MT['round'](categorys['RageBot']['onshot_time']:Get(), 2)
        if predict >= onshot_time then
            ragebot_rf['ragebot']:Set(true)
            ragebot_data['onshot_fire'] = true
            ragebot_data['onshot'][player] = nil
        end
    end
    
    MT['ESP']['CustomText']("Lethal", "enemies", "lethal", function(ent)
        local forcebaim = categorys['RageBot']['Forcebaim']:Get()
        if forcebaim then
            local can_lethal = MT['Is_lethal'](ent, ragebot_data['active_weapon'])
            if can_lethal then
                return "lethal"
            end
        end
    end)

    function MT.Is_lethal(player, weapon)
        local localplayer = MT['EntityList']['GetLocalPlayer']()
        local origin = localplayer:GetEyePosition()
        local vec = MT['Vector']['new'](origin['x'], origin['y'], origin['z'])
		local enemy_hp = player:GetProp("m_iHealth")
		local enemy_am = player:GetProp("m_ArmorValue")
        local damage = ragebot_rf['minimum_damage']:Get()
        damage = damage == 0 and 50 or damage
        local predict_damage = enemy_hp + enemy_am * 0.05
        local weapon_rg = ragebot_data['forcebaim_wp'][weapon]
        if damage >= predict_damage then
            if weapon_rg then
                if categorys['RageBot']['Forcebaim_weapons']:GetBool(weapon_rg) then
                    return true
                else
                    return false
                end
            else
                if categorys['RageBot']['Forcebaim_weapons']:GetBool(6) then
                    return true
                else
                    return false
                end
            end
        else
            return false
        end
    end

    function C_BasePlayer:CanHit()
        local localplayer = MT['EntityList']['GetLocalPlayer']()
        local TraceInfo = MT['Cheat']['FireBullet'](self, self:GetEyePosition(), localplayer:GetEyePosition())
        if (TraceInfo['damage'] > 0 and ((TraceInfo['trace']['hit_entity'] and TraceInfo['trace']['hit_entity']:GetPlayer() == localplayer) or false)) then
            return true
        end
        return false
    end


    function MT.force_teleport()
        local localplayer = MT['EntityList']['GetLocalPlayer']()
        local Player = MT['get_nearest_enemy']()
        if not Player['id'] then return end
        local origin = localplayer:GetEyePosition()
        local vec = MT['Vector']['new'](origin['x'], origin['y'], origin['z'])
        local distance = vec:DistTo(Player['id']:GetProp("m_vecOrigin")) * 0.002
        local main_dist = categorys['RageBot']['force_tp_dist']:Get()
        if distance < main_dist and Player['id']:CanHit() and not Player['id']:IsDormant() and (MT['GlobalVars']['realtime'] - ragebot_data['last_teleport'] > ragebot_data['teleport_delay']) then
            MT['Exploits']['ForceTeleport']()
            ragebot_data['last_teleport'] = MT['GlobalVars']['realtime']
        end
    end

    function MT.baimlethal(weapon)
        local data = MT['get_nearest_enemy']()
        local weapon_rg = ragebot_data['forcebaim_wp'][weapon]
        if data['id'] == nil then return end
        if weapon_rg then
            if categorys['RageBot']['Forcebaim_weapons']:GetBool(weapon_rg) then
                local can_lethal = MT['Is_lethal'](data['id'], weapon)
                if can_lethal then
                    ragebot_rf['bodyaim']:Set(2)
                    for i=1 ,3 do 
                        ragebot_rf['bodyaim_db']:SetBool(i, false)
                    end
                else
                    ragebot_rf['bodyaim']:Set(ragebot_data['defualt_bodyaim'])
                    for k,v in pairs(ragebot_data['defualt_bodyaim_disabler']) do
                        ragebot_rf['bodyaim_db']:SetBool(k, v)
                    end
                end
            end
        else
            if categorys['RageBot']['Forcebaim_weapons']:GetBool(6) then
                local can_lethal = MT['Is_lethal'](data['id'], weapon)
                if can_lethal then
                    ragebot_rf['bodyaim']:Set(2)
                    for i=1 ,3 do 
                        ragebot_rf['bodyaim_db']:SetBool(i, false)
                    end
                else
                    ragebot_rf['bodyaim']:Set(ragebot_data['defualt_bodyaim'])
                    for k,v in pairs(ragebot_data['defualt_bodyaim_disabler']) do
                        ragebot_rf['bodyaim_db']:SetBool(k, v)
                    end
                end
            end
        end
    end

    function MT.get_latency()
        local netchann_info = MT['EngineClient']['GetNetChannelInfo']()
        if netchann_info == nil then return "0" end
        local latency = netchann_info:GetLatency(0)
        return string['format']("%1.f", math['max'](0.0, latency) * 1000.0)
    end

    function MT.AdaptiveDT()
        local a, b = MT['get_latency']() - 8, 13
        if a <= 25 then b = 15
        elseif a > 25 and a <= 50 then b = 14
        elseif a > 50 and a <= 60 then b = 13
        elseif a > 60 then b = 12 end
        return b
    end

    function MT.Ragebot()
        local localplayer = MT['EntityList']['GetLocalPlayer']()
        local getplayer = localplayer:GetPlayer()
        local active_weapon = getplayer:GetActiveWeapon()
        if not active_weapon then return end
        local ticks = MT['CVar']['FindVar']("sv_maxusrcmdprocessticks")
        local weapon_id = active_weapon:GetProp("m_iItemDefinitionIndex")
        local dt_master = ragebot_rf['Doubletap']:Get()
        local get_adaptivelag = categorys['Anti-Aim']['a_lag']:Get()
        local timer = MT['GlobalVars']['curtime']
        ragebot_data['active_weapon'] = weapon_id
        local aa_state = MT['get_aa_state'](localplayer)
        if categorys['RageBot']['force_tp']:Get() and ragebot_data['forcetp_wp'][weapon_id] then
            local force_tp_wp = ragebot_data['forcetp_wp'][weapon_id]
            if categorys['RageBot']['force_tp_wp']:GetBool(force_tp_wp) and aa_state == "air" then
                MT['force_teleport']()
            end
        end
        if dt_master then
            local mt_dt = categorys['RageBot']['Doubletap']:Get()
            local clock_correction = MT['CVar']['FindVar']("cl_clock_correction")
            if mt_dt then
                local dt_fl = categorys['RageBot']['Doubletap_standby_chock']:Get()
                local dt_rc = categorys['RageBot']['Doubletap_recharge']:Get()
                local dt_sp = categorys['RageBot']['Doubletap_speed']:Get()
                if dt_rc then
                    if MT['ShouldRecharge']() then
                        MT['Exploits']['ForceCharge']()
                    end
                end
                if dt_fl then
                    local fakelag_modes = categorys['RageBot']['Doubletap_standby_chock_modes']:Get()
                    if (timer - ragebot_data['Modes_fl'][fakelag_modes] > ragebot_data['last_time']) then
                        ragebot_data['lagging'] = not ragebot_data['lagging'] and true or false
                        ragebot_data['last_time'] = timer
                    end
                    MT['FakeLag']['SetState'](ragebot_data['lagging'])
                end
                if categorys['RageBot']['Doubletap_chock_cr']:Get() then
                    clock_correction:SetInt(1)
                else
                    clock_correction:SetInt(0)
                end
                if dt_sp == 3 then
                    MT['Exploits']['OverrideDoubleTapSpeed'](MT['AdaptiveDT']())
                else
                    MT['Exploits']['OverrideDoubleTapSpeed'](13 + dt_sp)
                end
            else
                clock_correction:SetInt(1)
                MT['Exploits']['OverrideDoubleTapSpeed'](13)
            end
        end
        local itick = categorys['RageBot']['idealtick']:Get()
        if itick then
            local enable_tick
            local can_tick = ragebot_data['idealtick'][weapon_id]
            local idealtick_op = categorys['RageBot']['idealtick_option']:Get()
            if idealtick_op == 0 then
                enable_tick = categorys['RageBot']['idealtick_hotkey']:Get()
            else
                enable_tick = ragebot_rf['autopeek']:Get()
            end
            if can_tick then
                MT['Exploits']['OverrideDoubleTapSpeed'](13)
                local getfakelag = categorys['RageBot']['idealtick_fakelag']:Get()
                if get_adaptivelag == 0 then
                    AntiAim_rf['limit']:Set(getfakelag)
                end
                ragebot_data['can_tick'] = categorys['RageBot']['idealtick_weapons']:GetBool(can_tick)
                if categorys['RageBot']['idealtick_weapons']:GetBool(can_tick) and enable_tick then
                    if categorys['RageBot']['idealtick_modes']:Get() == 0 then
                        if not dt_master then
                            ragebot_rf['Doubletap']:Set(true)
                            ragebot_data['last_dt_state'] = true
                        end
                        if not ragebot_data['last_tick'] then
                            ragebot_data['last_tick'] = true
                            MT['Exploits']['ForceTeleport']()
                        end
                    elseif categorys['RageBot']['idealtick_modes']:Get() == 1 then
                        if not dt_master then
                            ragebot_rf['Doubletap']:Set(true)
                            ragebot_data['last_dt_state'] = true
                        end
                    end
                else
                    ragebot_data['last_tick'] = false
                    if ragebot_data['last_dt_state'] then
                        ragebot_rf['Doubletap']:Set(false)
                        ragebot_data['last_dt_state'] = false
                    end
                end
            end
        end
        local onshot = categorys['RageBot']['Forceonshot']:Get()
        if onshot then
            local onshot_key = categorys['RageBot']['onshot_hotkey']:Get()
            local can_onshot = ragebot_data['onshot']
            if onshot_key then
                for k,v in pairs(can_onshot) do
                    MT['forceonshot'](timer, v['time'], k)
                end
            else
                ragebot_rf['ragebot']:Set(true)
            end
        end
        local forcebaim = categorys['RageBot']['Forcebaim']:Get()
        if forcebaim then
            MT['baimlethal'](weapon_id)
        end
        local extended = categorys['RageBot']['extended_backtrack']:Get()
        if extended then
            MT['FakeLag']['SentPackets']()
        end
        
        local fakelag = categorys['Anti-Aim']['a_limit']:Get()
        if get_adaptivelag == 1 then
            if not ragebot_rf['hideshot']:Get() then
                AntiAim_rf['limit']:Set(AntiAims['fastswitch'] and 1 or fakelag)
            end
        elseif get_adaptivelag == 2 then
            if dt_master then
                ticks:SetInt(16)
            else
                local _ticks = categorys['Anti-Aim']['a_ticks']:Get()
                ticks:SetInt(_ticks)
                MT['FakeLag']['SetState'](AntiAims['fastswitch'])
                AntiAim_rf['limit']:Set(fakelag)
            end
        end
    end

    function MT.edge_yaw(cmd, enable)
        if enable then
            local localplayer = MT['EngineClient']['GetLocalPlayer']()
            if not localplayer then return end
            local localplayer_entity = MT['EntityList']['GetClientEntity'](localplayer)
            local getplayer = localplayer_entity:GetPlayer()
            local velocity = getplayer:GetProp('m_vecVelocity[2]')
            local in_jump = MT['bit']['band'](cmd['buttons'], 2) == 2
            if velocity ~= 0 or in_jump then return end
            if MT['ClientState']['m_choked_commands'] == 0 then GetEyePostion = getplayer:GetEyePosition() end
            local vecotr_trace = {}
            local angViewAngles = MT['EngineClient']['GetViewAngles']()
            for i = 18, 360, 18 do
                i = MT['normalize_yaw'](i)
                local angEdge = MT['QAngle']['new'](0, i, 0)
                if not GetEyePostion then return end
                local edge_angle = GetEyePostion + MT['Cheat']['AngleToForward'](angEdge) * 198
                local traceInfo = MT['EngineTrace']['TraceRay'](GetEyePostion, edge_angle, getplayer, 0x46004003)
                local trace_fraction = traceInfo['fraction']
                local trace_hit_entity = traceInfo['hit_entity']
                if trace_hit_entity and trace_hit_entity:GetClassName() == 'CWorld' and trace_fraction < 0.3 then vecotr_trace[#vecotr_trace+1] = { edge_yaw = traceInfo['endpos'], yaw = i } end
            end
            table['sort'](vecotr_trace, function(a, b) return a['yaw'] < b['yaw'] end)
            local angEdge
            if #vecotr_trace >= 2 then
                local vector_trace = MT['VectorLerp'](vecotr_trace[1]['edge_yaw'], vecotr_trace[#vecotr_trace]['edge_yaw'], 0.5)
                angEdge = MT['Cheat']['VectorToAngle'](GetEyePostion - vector_trace)
            end
            if angEdge then
                local yaw = angViewAngles['yaw']
                local edge_yaw = angEdge['yaw']
                local normalize_yaw = MT['normalize_yaw'](edge_yaw - yaw)
                if math['abs'](normalize_yaw) < 90 then
                    normalize_yaw = 0
                    yaw = MT['normalize_yaw'](edge_yaw + 180)
                end
                local flNewYaw = -yaw
                flNewYaw = MT['normalize_yaw'](flNewYaw + edge_yaw + 180)
                flNewYaw = MT['normalize_yaw'](flNewYaw + normalize_yaw)
                MT['AntiAim']['OverrideYawOffset'](flNewYaw)
            end
        end
    end

    function MT.Movementdesync()
        local leftdesync = MT['Cheat']['IsKeyDown'](0x41)
        local rightdesync = MT['Cheat']['IsKeyDown'](0x44)
        if leftdesync then
            AntiAims['last_perss'] = true
            return true
        end
        if rightdesync then
            AntiAims['last_perss'] = false
            return false
        end
        return AntiAims['last_perss']
    end

    function MT.Flipdesync()
        local flip_r = {false, true}
        local flip_desync = flip_r[math['random'](#flip_r)]
        return flip_desync
    end

    function MT.base_yaw(state)
        local fakeduck = AntiAim_rf['fakeduck']:Get()
        local is_fs = categorys['Anti-Aim']['freestanding']:Get()
        local fs_key = categorys['Anti-Aim']['freestanding_hotkey']:Get()
        local fs_enable = false
        if is_fs and fs_key then
            fs_enable = true
        end
        if state == "air" then
            if categorys['Anti-Aim']['freestanding_modes']:GetBool(1) then
                fs_enable = false
            end
        elseif state == "crouching" then
            if categorys['Anti-Aim']['freestanding_modes']:GetBool(2) then
                fs_enable = false
            end
        elseif state == "slowwalk" then
            if categorys['Anti-Aim']['freestanding_modes']:GetBool(3) then
                fs_enable = false
            end
        elseif fakeduck then
            if categorys['Anti-Aim']['freestanding_modes']:GetBool(4) then
                fs_enable = false
            end
        end
        return {fs = fs_enable}
    end

    function MT.can_edge(state)
        local fakeduck = AntiAim_rf['fakeduck']:Get()
        local is_ey = categorys['Anti-Aim']['edge']:Get()
        local ey_key = categorys['Anti-Aim']['edge_hotkey']:Get()
        local ey_enable = false
        if is_ey and ey_key then
            ey_enable = true
        end
        if state == "air" then
            if categorys['Anti-Aim']['edge_modes']:GetBool(1) then
                ey_enable = false
            end
        elseif state == "crouching" then
            if categorys['Anti-Aim']['edge_modes']:GetBool(2) then
                ey_enable = false
            end
        elseif state == "slowwalk" then
            if categorys['Anti-Aim']['edge_modes']:GetBool(3) then
                ey_enable = false
            end
        elseif fakeduck then
            if categorys['Anti-Aim']['edge_modes']:GetBool(4) then
                ey_enable = false
            end
        end
        return {ey = ey_enable}
    end

    function MT.walkspeed(cmd, speed)
        local localplayer = MT['EntityList']['GetLocalPlayer']()
        local velocity = math['floor'](MT['get_velocity'](localplayer))
        local ld_speed = speed / 2
        local speed = 5
        if(velocity > 1) then
            cmd.forwardmove = (cmd.forwardmove * speed) / ld_speed
            cmd.sidemove = (cmd.sidemove * speed) / ld_speed
            cmd.upmove = (cmd.sidemove * speed) / ld_speed
        end
    end

    function MT.lowdelta()
        local ld_desync = categorys['Anti-Aim']['Lowdelta_desync']:Get()
        local lm_desync = 0
        if (ld_desync - 10) >= 0 then
            lm_desync = ld_desync - 10
        else
            lm_desync = 0
        end
        local random_desync = MT['utils']['RandomInt'](lm_desync, ld_desync)
        MT['AAHandler']({
            override_aa = false,
            pitch = 1,
            yaw_base = 4,
            yaw_add = 0,
            yaw_modifier = 0,
            modifier_degree = 0,
            inverter = true,
            left_limit = random_desync,
            right_limit = random_desync,
            fakeoption = {
                [1] = true,
                [2] = false,
                [3] = false,
                [4] = true
            },
            lby_mode = 1,
            freestanding_desync = 0,
            desync_on_shot = 3
        }, false)
    end

    function MT.DesyncHandler(state)
        local bodyyaw = categorys['Anti-Aim']['body_yaw']:Get()
        local GetDesync = MT['get_desync']()
        local Desyncvalue = categorys['Anti-Aim']['body_yow_slider']:Get()
        if state ~= "slowwalk" and state ~= "air" and state ~= "crouching" then
            if bodyyaw == 1 then
                AntiAims['base_aa'][state]['inverter'] = GetDesync
                AntiAims['base_aa'][state]['left_limit'] = Desyncvalue
                AntiAims['base_aa'][state]['right_limit'] = Desyncvalue - 2
            elseif bodyyaw == 2 then
                local MovementDesync = MT['Movementdesync']()
                AntiAims['base_aa'][state]['inverter'] = MovementDesync
                AntiAims['base_aa'][state]['left_limit'] = Desyncvalue
                AntiAims['base_aa'][state]['right_limit'] = Desyncvalue - 2 
            elseif bodyyaw == 3 then
                local Inverter = categorys['Anti-Aim']['body_yow_inverter']:Get()
                AntiAims['base_aa'][state]['inverter'] = Inverter
                AntiAims['base_aa'][state]['left_limit'] = Desyncvalue
                AntiAims['base_aa'][state]['right_limit'] = Desyncvalue - 2 
            elseif bodyyaw == 4 then
                local filpdesync = MT['Flipdesync']()
                AntiAims['base_aa'][state]['inverter'] = filpdesync
                AntiAims['base_aa'][state]['left_limit'] = Desyncvalue
                AntiAims['base_aa'][state]['right_limit'] = Desyncvalue - 2 
            end
        else
            if state == "crouching" then
                if categorys['Misc']['anti_Defensive']:Get() then
                    AntiAims['base_aa']['crouching']['fakeoption'] = {
                        [1] = true,
                        [2] = false,
                        [3] = false,
                        [4] = true
                    }
                    AntiAims['base_aa']['crouching']['left_limit'] = 48
                    AntiAims['base_aa']['crouching']['right_limit'] = 48
                else
                    AntiAims['base_aa']['crouching']['fakeoption'] = {
                        [1] = true,
                        [2] = false,
                        [3] = false,
                        [4] = true
                    }
                    AntiAims['base_aa']['crouching']['left_limit'] = 48
                    AntiAims['base_aa']['crouching']['right_limit'] = 48
                end
            end
        end
        MT['AAHandler'](AntiAims['base_aa'][state], false)
    end

    local hitgroups = {
        [0] = "head",
        [1] = "neck",
        [2] = "pelvis",
        [3] = "stomach",
        [4] = "lower chest",
        [5] = "chest",
        [6] = "upper chest",
        [7] = "right thigh",
        [8] = "left thigh",
        [9] = "right calf",
        [10] = "left calf",
        [11] = "right foot",
        [12] = "left foot",
        [13] = "right hand",
        [14] = "left hand",
        [15] = "right upper arm",
        [16] = "right forearm",
        [17] = "left upper arm",
        [18] = "left forear"
    }

    local reasons = {
        [0] = "Hit",
        [1] = "Resolver",
        [2] = "Spread",
        [3] = "Occlusion",
        [4] = "Prediction error"
    }

    function MT.HMLog(name, reason, hitbox, damage, hitchance, backtrack)
        local missing = ""
        if reason == "Hit" then
            missing = string['format']("%s %s %s(%s)(%sHC) BT: %s", reason, name, hitbox, damage, hitchance, backtrack)
        else
            missing = string['format']("%s %s %s(%s)(%sHC) due to %s BT: %s", "Missed", name, hitbox, damage, hitchance, reason, backtrack)
        end
        if categorys['Misc']['event_box']:GetBool(1) then
            MT['console'](missing, MT['color'](255, 255, 255, 255))
        end
        if categorys['Misc']['event_box']:GetBool(2) then
            MT['Cheat']['AddEvent'](missing)
        end
        if categorys['Misc']['event_box']:GetBool(3) then
            MT['Cheat']['AddNotify'](reason, missing)
        end
    end

    function MT.changeset(is_left, is_right)
        if is_left then
            if is_right then
                categorys['Anti-Aim']['manual_right']:Set(false)
            end
        end
        if is_right then
            if is_left then
                categorys['Anti-Aim']['manual_left']:Set(false)
            end
        end
    end

    function MT.manualKeys()
        local manual_lefts = categorys['Anti-Aim']['manual_left']:Get()
        local manual_rights = categorys['Anti-Aim']['manual_right']:Get()
        if manual_lefts then
            if manual_rights then
                categorys['Anti-Aim']['manual_right']:Set(false)
            end
            MT['AAHandler']({
                override_aa = false,
                pitch = 1,
                yaw_base = 3,
                yaw_add = 0,
                yaw_modifier = 0,
                modifier_degree = 0,
                inverter = false,
                left_limit = 30,
                right_limit = 30,
                fakeoption = {
                    [1] = true,
                    [2] = false,
                    [3] = false,
                    [4] = false
                },
                lby_mode = 2,
                freestanding_desync = 0,
                desync_on_shot = 0
            }, false)
            AntiAims['is_manual'] = true
        end
        if manual_rights then
            if manual_lefts then
                categorys['Anti-Aim']['manual_left']:Set(false)
            end
            MT['AAHandler']({
                override_aa = false,
                pitch = 1,
                yaw_base = 2,
                yaw_add = 0,
                yaw_modifier = 0,
                modifier_degree = 0,
                inverter = false,
                left_limit = 30,
                right_limit = 30,
                fakeoption = {
                    [1] = true,
                    [2] = false,
                    [3] = false,
                    [4] = false
                },
                lby_mode = 2,
                freestanding_desync = 0,
                desync_on_shot = 0
            }, false)
            AntiAims['is_manual'] = true
        end
        if manual_lefts then
            AntiAims['is_manual'] = true
        elseif manual_rights then
            AntiAims['is_manual'] = true
        else
            AntiAims['is_manual'] = false
        end
    end

    function MT.onshot(cmd)
        if cmd:GetName() == "weapon_fire" then
            local user_id = cmd:GetInt("userid", 0)
            local user = MT['EntityList']['GetPlayerForUserID'](user_id)
            local player = MT['EntityList']['GetLocalPlayer']()
            local Is_alive = player:GetProp("m_iHealth") ~= 0 and true or false
            if Is_alive then
                local data = MT['get_nearest_enemy']()
                if data['id'] ~= nil and user:EntIndex() == data['id']:EntIndex() then
                    if not ragebot_data['onshot'][user_id] then
                        ragebot_data['onshot'][user_id] = {}
                        ragebot_data['onshot'][user_id]['time'] = MT['GlobalVars']['curtime']
                    end
                end
            else
                ragebot_rf['ragebot']:Set(false)
            end
        end
    end

    function MT.AntiBrute(cmd)
        if cmd:GetName() == "weapon_fire" then
            local user_id = cmd:GetInt("userid", 0)
            local user = MT['EntityList']['GetPlayerForUserID'](user_id)
            if not user then return end
            local player = MT['EntityList']['GetLocalPlayer']()
            local Is_alive = player:GetProp("m_iHealth") ~= 0 and true or false
            if Is_alive then
                local data = MT['get_nearest_enemy']()
                if not data['id'] then return end
                local origin = player:GetEyePosition()
                local vec = MT['Vector']['new'](origin['x'], origin['y'], origin['z'])
                local distance = vec:DistTo(data['id']:GetProp("m_vecOrigin")) * 0.002
                if data['id'] ~= nil and user:EntIndex() == data['id']:EntIndex() and distance < 3.0 then
                    local last_brute = AntiAims['brute']
                    if categorys['Antibruteforce']['brute'][last_brute + 1] then
                        AntiAims['brute'] = last_brute + 1
                    else
                        AntiAims['brute'] = 1
                    end
                    AntiAims['last_brute'] = MT['GlobalVars']['curtime']
                    MT['Cheat']['AddEvent'](string['format']("Anti-bruteforce angle set to (%s)", categorys['Antibruteforce']['brute'][AntiAims['brute']]:Get()))
                end
            end
        end
    end

    function MT.setMovement(cmd, xz, yz)
        local localplayer = MT['EntityList']['GetLocalPlayer']()
        localplayer = localplayer:GetPlayer()
        local current_pos = localplayer:GetProp("m_vecOrigin")
        local yaw = MT['EngineClient']['GetViewAngles']()['yaw']
        local vector_forward = {
            x = current_pos['x'] - xz,
            y = current_pos['y'] - yz,
        }   
        local velocity = {
            x = -(vector_forward['x'] * math['cos'](yaw / 180 * math['pi']) + vector_forward['y'] * math['sin'](yaw / 180 * math['pi'])),
            y = vector_forward['y'] * math['cos'](yaw / 180 * math['pi']) - vector_forward['x'] * math['sin'](yaw / 180 * math['pi']),
        }
        cmd['forwardmove'] = velocity['x'] * 15
        cmd['sidemove'] = velocity['y'] * 15
    end
    

    MT['Cheat']['RegisterCallback']("events", function(shot)
        local onshot = categorys['RageBot']['Forceonshot']:Get()
        local onshot_key = categorys['RageBot']['onshot_hotkey']:Get()
        if onshot and onshot_key then
            MT['onshot'](shot)
        end
        local bruteforce = categorys['Antibruteforce']['anti_bruteforce']:Get()
        if bruteforce then
            MT['AntiBrute'](shot)
        end
    end)

    MT['Cheat']['RegisterCallback']("registered_shot", function(shot)
        local target = MT['EntityList']['GetClientEntity'](shot['target_index'])
        if not target then return end
        local ham = categorys['Misc']['hitandmiss']:Get()
        if ham then
            if categorys['Misc']['hitandmiss_box']:Get() ~= 0 and categorys['Misc']['event_box']:Get() ~= 0 then
                local id = shot['reason']
                local reason = reasons[id]
            	local target = target:GetPlayer()
                local name = target:GetName()
                local hitbox = hitgroups[shot.hitgroup] or "unknown"
                local damage = tostring(shot.damage or 0)
                local hitchance = tostring(shot.hitchance or 0)
                local backtrack = tostring(shot.backtrack or 0)
                for k,v in pairs(hit_miss) do
                    if categorys['Misc']['hitandmiss_box']:GetBool(k) and reason == v then
                        MT['HMLog'](name, reason, hitbox, damage, hitchance, backtrack)
                    end
                end
            end
        end
    end)

    MT['Cheat']['RegisterCallback']("ragebot_shot", function(shot)
        local itick = categorys['RageBot']['idealtick']:Get()
        local timer = MT['GlobalVars']['curtime']
        if itick then
            local enable_tick
            local idealtick_op = categorys['RageBot']['idealtick_option']:Get()
            if idealtick_op == 0 then
                enable_tick = categorys['RageBot']['idealtick_hotkey']:Get()
            else
                enable_tick = ragebot_rf['autopeek']:Get()
            end
            if ragebot_data['can_tick'] and enable_tick then
                if categorys['RageBot']['idealtick_modes']:Get() == 2 then
                    ragebot_rf['Doubletap']:Set(true)
                    MT['Exploits']['ForceTeleport']()
                    MT['sleep'](0.5, function()
                        ragebot_rf['Doubletap']:Set(false)
                    end)
                end
                if ragebot_data['shot_time'] == 0 then
                    ragebot_data['shot_time'] = timer
                end
                if ragebot_data['shot_time'] > timer - 1 then
                    MT['Exploits']['ForceTeleport']()
                else
                    ragebot_data['shot_time'] = 0
                end
            end
        end
        if ragebot_data['onshot_fire'] then
            ragebot_rf['ragebot']:Set(false)
            ragebot_data['onshot_fire'] = false
        end
        if categorys['Anti-Aim']['antionshot']:Get() then
            MT['FakeLag']['ForceSend']()
        end
    end)

    function MT.animation_handler(cmd)
        local localplayer = get_client_entity(MT['EntityList']['GetLocalPlayer']():EntIndex())
        if not localplayer then return end
        local localplayer_offset = ffi['cast']("unsigned int", localplayer)
        if localplayer_offset == 0x0 and not localplayer_offset then return end
        local animation = ffi['cast']("void**", localplayer_offset + 0x9960)[0]
        if not animation then return end
        animation = ffi['cast']("unsigned int", animation)
        if animation == 0x0 and not animation then return end
        local on_land = ffi['cast']("bool*", animation + 0x109)[0]
        if on_land == nil then return end
        if categorys['Misc']['anim_breaker']:GetBool(1) and on_land and MT['bit']['band'](cmd['buttons'], 2) == 0 then
            MT['set_prop'](localplayer, 12, 0.999, 1)
        end
        if categorys['Misc']['anim_breaker']:GetBool(2) then
            MT['set_prop'](localplayer, 6, 0.9, 1)
        end
        if categorys['Misc']['anim_breaker']:GetBool(3) then
            MT['set_prop'](localplayer, 0, -180, -179)
        end
    end

    MT['Cheat']['RegisterCallback']("prediction", function(e)
        MT['Ragebot']()
        MT['animation_handler'](e)
    end)

    function MT.BodyYawHandler(state)
        local bodyyaw = categorys['Anti-Aim'][state][0]['bodyyaw']:Get()
        if bodyyaw == 0 then return "Disabled" end
        local GetDesync = MT['get_desync']()
        if bodyyaw == 1 then
            return GetDesync
        elseif bodyyaw == 2 then
            return GetDesync and false or true
        elseif bodyyaw == 3 then
            local MovementDesync = MT['Movementdesync']()
            return MovementDesync
        else
            return AntiAims['fastswitch']
        end
    end

    math.pi_divided = math.pi / 180
    local actual_mov = Vector2.new(0, 0)
    function MT.angle_vec(QAngle)
        local forward, right = Vector.new(), Vector.new()
        local pitch, yaw, roll = math.rad(QAngle.pitch), math.rad(QAngle.yaw), math.rad(QAngle.roll)
        local cp, sp = math.cos(pitch), math.sin(pitch)
        local cy, sy = math.cos(yaw), math.sin(yaw)
        local cr, sr = math.cos(roll), math.sin(roll)
        forward.x = cp * cy
        forward.y = cp * sy
        forward.z = -sp
        right.x = (-1 * sr * sp * cy) + (-1 * cr * -sy)
        right.y = (-1 * sr * sp * sy) + (-1 * cr * cy)
        right.z = -1 * sr * cp
        return forward, right
    end

    function MT.cr_movement(cmd)
        local frL, riL = MT.angle_vec(QAngle.new(0, cmd.viewangles.yaw, 0))
        local frC, riC = MT.angle_vec(cmd.viewangles)
        frL.z = 0
        riL.z = 0
        frC.z = 0
        riC.z = 0
        frL = frL / frL:Length()
        riL = riL / riL:Length()
        frC = frC / frC:Length()
        riC = riC / riC:Length()

        local worldCoords = frL * actual_mov.x + riL * actual_mov.y;
        cmd.sidemove = (frC.x * worldCoords.y - frC.y * worldCoords.x) / (riC.y * frC.x - riC.x * frC.y)
        cmd.forwardmove = (riC.y * worldCoords.x - riC.x * worldCoords.y) / (riC.y * frC.x - riC.x * frC.y)
    end

    MT['Cheat']['RegisterCallback']("pre_prediction", function(cmd)
        local antiaim = categorys['Anti-Aim']['antiaim_enable']:Get()
        local custom_antiaim = categorys['Anti-Aim']['custom_aa_enable']:Get()
        local localplayer = MT['EntityList']['GetLocalPlayer']()
        local aa_state = MT['get_aa_state'](localplayer)
        local baseyaw = MT['base_yaw'](aa_state)
        local roll = categorys['Anti-Aim']['roll']:Get()
        local localplayer = MT['EntityList']['GetLocalPlayer']()
        if MT['ClientState']['m_choked_commands'] == 0 then
            AntiAims['fastswitch'] = not AntiAims['fastswitch']
        end
        local edge_yaw = MT['can_edge'](aa_state)
        if not ragebot_rf['autopeek']:Get() then
            AntiAims['autopeek_pos'] = localplayer:GetProp("m_vecOrigin")
        end
        if categorys['Misc']['quick_peek']:Get() and ragebot_rf['autopeek']:Get() then
            local forw = MT['bit']['band'](cmd['buttons'], 8) == 8
            local back = MT['bit']['band'](cmd['buttons'], 16) == 16
            local right = MT['bit']['band'](cmd['buttons'], 512) == 512
            local left = MT['bit']['band'](cmd['buttons'], 1024) == 1024
            local postion = localplayer:GetProp("m_vecOrigin")
            if not forw and not back and not right and not left then
                if math.floor(AntiAims['autopeek_pos']['x']) ~= math.floor(postion['x']) or math.floor(AntiAims['autopeek_pos']['y']) ~= math.floor(postion['y']) then
                    MT['setMovement'](cmd, AntiAims['autopeek_pos']['x'], AntiAims['autopeek_pos']['y'])
                end
            end
        end
        if antiaim then
            local Legit_aa = categorys['Anti-Aim']['Legit_aa']:Get()
            local legit_aa_key = categorys['Anti-Aim']['Legit_aa_hotkey']:GetBool()
            if Legit_aa and legit_aa_key then
                return MT['legit_aa'](cmd, localplayer, false)
            end
        else
            local onkey_aa = categorys['Anti-Aim']['Onkey']['Hotkey']:Get()
            local onkey_enable = categorys['Anti-Aim']['Onkey']['enable_aa']:Get()
            if onkey_aa and onkey_enable then
                return MT['legit_aa'](cmd, localplayer, true)
            end
        end
        if edge_yaw['ey'] then
            MT['edge_yaw'](cmd, true)
        else
            MT['edge_yaw'](cmd, false)
        end
        if baseyaw['fs'] then
            AntiAims['freestanding'] = true
        else
            AntiAims['freestanding'] = false
        end
        if categorys['Anti-Aim']['antionshot']:Get() then
            if ragebot_rf['hideshot']:Get() then
                AntiAim_rf['limit']:Set(1)
            end
        end
        if categorys['Anti-Aim']['roll_manual']:Get() then
            local get_desync, none_sync = MT['get_desync']()
            local yaw_add = get_desync and -95 or 95
            local desync_onshot = get_desync and 2 or 3
            MT['AAHandler']({
                override_aa = true,
                pitch = 1,
                yaw_base = 4,
                yaw_add = 0,
                yaw_modifier = 0,
                modifier_degree = 0,
                inverter = true,
                left_limit = 60,
                right_limit = 60,
                fakeoption = {
                    [1] = false,
                    [2] = false,
                    [3] = false,
                    [4] = false
                },
                lby_mode = 0,
                freestanding_desync = 0,
                desync_on_shot = 3,
                yaw_base = 4,
                desynclimit = 58,
                YawOffset = yaw_add,
                LBYOffset = -58,
                Overridepitch = 90,
                Desync_onshot = desync_onshot,
                inverteroverride = true
            }, false)
            cmd['viewangles']['roll'] = 47
        else
            if antiaim then
                local legit_aa_key = categorys['Anti-Aim']['Legit_aa_hotkey']:GetBool()
                if not legit_aa_key then
                    local lowdelta, lowdelta_key = categorys['Anti-Aim']['Lowdelta']:Get(), categorys['Anti-Aim']['Lowdelta_hotkey']:Get()
                    if lowdelta and lowdelta_key then
                        local speed = categorys['Anti-Aim']['Lowdelta_speed']:Get()
                        MT['walkspeed'](cmd, speed)
                        MT['lowdelta']()
                    else
                        MT['manualKeys']()
                        if not AntiAims['is_manual'] then
                            MT['DesyncHandler'](aa_state)
                        end
                    end
                end
            elseif custom_antiaim then
                local custom_aa_state = custom_base_mode[aa_state]
                local onkey_aa = categorys['Anti-Aim']['Onkey']['Hotkey']:Get()
                if not onkey_aa then
                    if categorys['Anti-Aim'][custom_aa_state]['enable_aa']:Get() then
                        local typeofaa = categorys['Anti-Aim'][custom_aa_state]['type']:Get()
                        local yaw_base = categorys['Anti-Aim'][custom_aa_state]['yaw_base']:Get()
                        if typeofaa == 0 then
                            local get_desync = MT['get_desync']()
                            local bodyyaw = MT['BodyYawHandler'](custom_aa_state)
                            local inverter = false
                            local fake_option = {}
                            local pitch = categorys['Anti-Aim'][custom_aa_state][0]['pitch']:Get()
                            local yaw_add = categorys['Anti-Aim'][custom_aa_state][0]['yaw_add']:Get()
                            local yaw_modifier = categorys['Anti-Aim'][custom_aa_state][0]['yaw_modifier']:Get()
                            local modifire_degree = categorys['Anti-Aim'][custom_aa_state][0]['modifire_degree']:Get()
                            local jitter = categorys['Anti-Aim'][custom_aa_state][0]['jitter']:Get()
                            local jitter_left = categorys['Anti-Aim'][custom_aa_state][0]['yawleft']:Get()
                            local jitter_right = categorys['Anti-Aim'][custom_aa_state][0]['yawright']:Get()
                            if bodyyaw == "Disabled" then
                                inverter = categorys['Anti-Aim'][custom_aa_state][0]['inverter']:Get()
                            else
                                inverter = bodyyaw
                            end
                            local jitteryaw = 0
                            if jitter then
                                jitteryaw = AntiAims['fastswitch'] and jitter_right or -jitter_left
                            end
                            local fakeoption = categorys['Anti-Aim'][custom_aa_state][0]['fakeoption']
                            fake_option = {
                                [1] = fakeoption:GetBool(1),
                                [2] = fakeoption:GetBool(2),
                                [3] = fakeoption:GetBool(3),
                                [4] = fakeoption:GetBool(4)
                            }
                            local lby_mode = categorys['Anti-Aim'][custom_aa_state][0]['lby_mode']:Get()
                            local freestanding_desync = categorys['Anti-Aim'][custom_aa_state][0]['freestanding_desync']:Get()
                            local desync_onshot = categorys['Anti-Aim'][custom_aa_state][0]['desync_onshot']:Get()
                            local fakemodes = categorys['Anti-Aim'][custom_aa_state][0]['fakeyaw_type']:Get()
                            local fakeleft = categorys['Anti-Aim'][custom_aa_state][0]['fakeleft']:Get()
                            local fakeright = categorys['Anti-Aim'][custom_aa_state][0]['fakeright']:Get()
                            if fakemodes == 2 then
                                inverter = AntiAims['fastswitch'] and true or false
                            elseif fakemodes == 3 then
                                fakeleft = math.random(1, fakeleft)
                                fakeright = math.random(1, fakeright)
                            end
                            local leanamount = 0
                            local leanmodes = categorys['Anti-Aim'][custom_aa_state][0]['leanmodes']:Get()
                            local leanamount_left = categorys['Anti-Aim'][custom_aa_state][0]['leanamount_left']:Get()
                            local leanamount_right = categorys['Anti-Aim'][custom_aa_state][0]['leanamount_right']:Get()
                            if leanmodes == 1 then
                                leanamount = leanamount_right or leanamount_left
                            elseif leanmodes == 2 then
                                leanamount = AntiAims['fastswitch'] and leanamount_left or leanamount_right
                            elseif leanmodes == 3 then
                                leanamount = get_desync and leanamount_left or leanamount_right
                            end
                            MT['AAHandler']({
                                override_aa = false,
                                pitch = pitch,
                                yaw_base = yaw_base,
                                yaw_add = jitter and jitteryaw or yaw_add,
                                yaw_modifier = yaw_modifier,
                                modifier_degree = modifire_degree,
                                inverter = inverter,
                                left_limit = fakeleft,
                                right_limit = fakeright,
                                fakeoption = fake_option,
                                lby_mode = lby_mode,
                                freestanding_desync = freestanding_desync,
                                desync_on_shot = desync_onshot
                            }, false)
                            if not AntiAims['freestanding'] then
                                if ragebot_data['active_weapon'] ~= 44 and ragebot_data['active_weapon'] ~= 45 and ragebot_data['active_weapon'] ~= 46 then
                                    cmd['viewangles']['roll'] = leanamount
                                else
                                    cmd['viewangles']['roll'] = 0
                                end
                            else
                                cmd['viewangles']['roll'] = 0
                            end
                        else
                            local pitch = categorys['Anti-Aim'][custom_aa_state][1]['c_pitch']:Get()
                            local yaw_offset = categorys['Anti-Aim'][custom_aa_state][1]['yaw_offset']:Get()
                            local lby_offset = categorys['Anti-Aim'][custom_aa_state][1]['lby_offset']:Get()
                            local desync_shot = categorys['Anti-Aim'][custom_aa_state][1]['c_desync_onshot']:Get()
                            local desync_limit = categorys['Anti-Aim'][custom_aa_state][1]['desync_limit']:Get()
                            MT['AAHandler']({
                                override_aa = true,
                                yaw_base = yaw_base,
                                yaw_add = 0,
                                desynclimit = desync_limit,
                                YawOffset = yaw_offset,
                                LBYOffset = lby_offset,
                                Overridepitch = pitch,
                                Desync_onshot = desync_shot,
                                inverteroverride = true
                            }, false)
                        end
                    else
                        local typeofaa = categorys['Anti-Aim']["Global"]['type']:Get()
                        local yaw_base = categorys['Anti-Aim']["Global"]['yaw_base']:Get()
                        if typeofaa == 0 then
                            local get_desync = MT['get_desync']()
                            local bodyyaw = MT['BodyYawHandler']("Global")
                            local inverter = false
                            local fake_option = {}
                            local fakeyaw = 60
                            local pitch = categorys['Anti-Aim']["Global"][0]['pitch']:Get()
                            local yaw_add = categorys['Anti-Aim']["Global"][0]['yaw_add']:Get()
                            local yaw_modifier = categorys['Anti-Aim']["Global"][0]['yaw_modifier']:Get()
                            local modifire_degree = categorys['Anti-Aim']["Global"][0]['modifire_degree']:Get()
                            local jitter = categorys['Anti-Aim']["Global"][0]['jitter']:Get()
                            local jitter_left = categorys['Anti-Aim']["Global"][0]['yawleft']:Get()
                            local jitter_right = categorys['Anti-Aim']["Global"][0]['yawright']:Get()
                            if bodyyaw == "Disabled" then
                                inverter = categorys['Anti-Aim']["Global"][0]['inverter']:Get()
                            else
                                inverter = bodyyaw
                            end
                            local jitteryaw = 0
                            if jitter then
                                jitteryaw = AntiAims['fastswitch'] and jitter_right or -jitter_left
                            end
                            local fakeoption = categorys['Anti-Aim']["Global"][0]['fakeoption']
                            fake_option = {
                                [1] = fakeoption:GetBool(1),
                                [2] = fakeoption:GetBool(2),
                                [3] = fakeoption:GetBool(3),
                                [4] = fakeoption:GetBool(4)
                            }
                            local lby_mode = categorys['Anti-Aim']["Global"][0]['lby_mode']:Get()
                            local freestanding_desync = categorys['Anti-Aim']["Global"][0]['freestanding_desync']:Get()
                            local desync_onshot = categorys['Anti-Aim']["Global"][0]['desync_onshot']:Get()
                            local fakemodes = categorys['Anti-Aim']["Global"][0]['fakeyaw_type']:Get()
                            local fakeleft = categorys['Anti-Aim']["Global"][0]['fakeleft']:Get()
                            local fakeright = categorys['Anti-Aim']["Global"][0]['fakeright']:Get()
                            if fakemodes == 2 then
                                inverter = AntiAims['fastswitch'] and true or false
                            elseif fakemodes == 3 then
                                fakeleft = math.random(1, fakeleft)
                                fakeright = math.random(1, fakeright)
                            end
                            local leanamount = 0
                            local leanmodes = categorys['Anti-Aim']["Global"][0]['leanmodes']:Get()
                            local leanamount_left = categorys['Anti-Aim']["Global"][0]['leanamount_left']:Get()
                            local leanamount_right = categorys['Anti-Aim']["Global"][0]['leanamount_right']:Get()
                            if leanmodes == 1 then
                                leanamount = leanamount_right or leanamount_left
                            elseif leanmodes == 2 then
                                leanamount = AntiAims['fastswitch'] and leanamount_left or leanamount_right
                            elseif leanmodes == 3 then
                                leanamount = get_desync and leanamount_left or leanamount_right
                            end
                            MT['AAHandler']({
                                override_aa = false,
                                pitch = pitch,
                                yaw_base = yaw_base,
                                yaw_add = jitter and jitteryaw or yaw_add,
                                yaw_modifier = yaw_modifier,
                                modifier_degree = modifire_degree,
                                inverter = inverter,
                                left_limit = fakeleft,
                                right_limit = fakeright,
                                fakeoption = fake_option,
                                lby_mode = lby_mode,
                                freestanding_desync = freestanding_desync,
                                desync_on_shot = desync_onshot
                            }, false)
                            if not AntiAims['freestanding'] then
                                if ragebot_data['active_weapon'] ~= 44 and ragebot_data['active_weapon'] ~= 45 and ragebot_data['active_weapon'] ~= 46 then
                                    cmd['viewangles']['roll'] = leanamount
                                else
                                    cmd['viewangles']['roll'] = 0
                                end
                            else
                                cmd['viewangles']['roll'] = 0
                            end
                        else
                            local pitch = categorys['Anti-Aim']["Global"][1]['c_pitch']:Get()
                            local yaw_offset = categorys['Anti-Aim']["Global"][1]['yaw_offset']:Get()
                            local lby_offset = categorys['Anti-Aim']["Global"][1]['lby_offset']:Get()
                            local desync_shot = categorys['Anti-Aim']["Global"][1]['c_desync_onshot']:Get()
                            local desync_limit = categorys['Anti-Aim']["Global"][1]['desync_limit']:Get()
                            MT['AAHandler']({
                                override_aa = true,
                                yaw_base = yaw_base,
                                yaw_add = 0,
                                desynclimit = desync_limit,
                                YawOffset = yaw_offset,
                                LBYOffset = lby_offset,
                                Overridepitch = pitch,
                                Desync_onshot = desync_shot,
                                inverteroverride = true
                            }, false)
                        end
                    end
                end
                local walkspeed = categorys['Anti-Aim']['Slow motion']['walkspeed']:Get()
                if walkspeed and aa_state == "slowwalk" then
                    local speed = categorys['Anti-Aim']['Slow motion']['speed']:Get()
                    MT['walkspeed'](cmd, speed)
                end
            end
        end

    end)

    function MT.delta_angle(angle)
        local angle = math['fmod'](angle, 360.0)
        if angle > 180.0 then
            angle = angle - 360.0
        end
        if angle < -180.0 then
            angle = angle + 360.0
        end
        return angle
    end

    local RealRotation = 0
    function MT.desync()
        if AntiAims['fastswitch'] then
            RealRotation = MT['AntiAim']['GetCurrentRealRotation']()
        end
        local max_delta = MT['AntiAim']['GetMaxDesyncDelta']() + math['abs'](MT['AntiAim']['GetMinDesyncDelta']())
        local delta = math['abs'](MT['delta_angle'](RealRotation - MT['AntiAim']['GetFakeRotation']())) / max_delta
        if delta > 1.0 then
            delta = 1.0
        end
        return math['ceil'](delta * 58)
    end

    local frame_rate = 0.0
    function MT.get_abs_fps()
        frame_rate = 0.9 * frame_rate + (1.0 - 0.9) * MT['GlobalVars']['absoluteframetime']
        return math['floor']((1.0 / frame_rate) + 0.5)
    end
    
    local load_avatar = MT['Http']['Get'](avatar_url)
    local mt_white = MT['Http']['Get'](madtech_white)
    local mt_black = MT['Http']['Get'](madtech_black)
    local mt_nl_logo = MT['Http']['Get'](neverlose_logo)
    local av_image = MT['render']['LoadImage'](load_avatar, MT['Vector2']['new'](120, 120))
    local mt_w_image = MT['render']['LoadImage'](mt_white, MT['Vector2']['new'](120, 120))
    local mt_b_image = MT['render']['LoadImage'](mt_black, MT['Vector2']['new'](120, 120))
    local mt_nl_image = MT['render']['LoadImage'](mt_nl_logo, MT['Vector2']['new'](120, 120))
    --MT['extended']['agent']()
    local Indicator = {
        dt_last = 0,
        dt_fill = 3
    }

    function MT.indicator()
        local is_idi = categorys['Indicators']['Indicators']:Get()
        if not is_idi then return end
        local screen = MT['EngineClient']['GetScreenSize']()
        local is_wm = categorys['Indicators']['watermark']:Get()
        if is_wm then
            local watermark_color = categorys['Indicators']['watermark']:GetColor()
            local username_size = MT['render']['CalcTextSize'](username, 13)
            local version_size = MT['render']['CalcTextSize'](string['format']("V%s", version), 12)
            local x_size = username_size['x'] - 20
            MT['render']['GradientBoxFilled'](MT['Vector2']['new'](screen['x'], 15), MT['Vector2']['new'](screen['x'] - 150 - x_size, 60), watermark_color, MT['color'](0, 0, 0, 0), watermark_color, MT['color'](0, 0, 0, 0))
            MT['render']['Image'](av_image, MT['Vector2']['new'](screen['x'] - 175 - x_size, 12.5), MT['Vector2']['new'](50, 50))
            MT['render']['Image'](mt_b_image, MT['Vector2']['new'](screen['x'] - 125.5 - x_size, -5.5), MT['Vector2']['new'](87, 86))
            MT['render']['Image'](mt_w_image, MT['Vector2']['new'](screen['x'] - 124 - x_size, -5.5), MT['Vector2']['new'](87, 87))
            MT['render']['Text'](username, MT['Vector2']['new']((screen['x'] - username_size['x']) - 15 , 25), MT['Color']['new'](1.0, 1.0, 1.0, 1.0), 13, Tahoma)
            MT['render']['Text'](string['format']("V%s", version), MT['Vector2']['new'](screen['x'] - version_size['x'] - username_size['x'] / 2 - 2, 38), MT['Color']['new'](1.0, 1.0, 1.0, 1.0), 12, Tahoma)
            MT['render']['Circle'](MT['Vector2']['new'](screen['x'] - 150 - x_size , 37), 25, 120, watermark_color, 2.5)
        end
        local mt_indi = categorys['Indicators']['madtech_indicator']:Get()
        if not MT['EngineClient']['IsConnected']() then return end
        if not MT['EngineClient']['IsInGame']() then return end
        if mt_indi then
            local localplayer = MT['EntityList']['GetLocalPlayer']()
            if not localplayer then return end
            local is_alive = localplayer:GetProp("m_iHealth") <= 0
            if is_alive then return end
            local mt_color = categorys['Indicators']['madtech_indicator']:GetColor()
            local mt_color_sec = categorys['Indicators']['madtech_indicator_sec']:GetColor()
            local desync_body = MT['desync']()
            if desync_body > 35 then
                desync_body = 35
            end
            MT['render']['Text']("MADTECH", MT['Vector2']['new'](screen['x'] / 2 - 26.5, screen['y'] / 2), mt_color, 13, Tahoma)
            MT['render']['BoxFilled'](MT['Vector2']['new'](screen['x'] / 2, screen['y'] / 2 + 22), MT['Vector2']['new'](screen.x/2+(math['abs'](desync_body) + 2), screen.y/2 + 15), MT['color'](0, 0, 0, 80))
            MT['render']['BoxFilled'](MT['Vector2']['new'](screen['x'] / 2, screen['y'] / 2 + 22), MT['Vector2']['new'](screen.x/2+(-math['abs'](desync_body) - 2), screen.y/2 + 15), MT['color'](0, 0, 0, 80))
            MT['render']['GradientBoxFilled'](MT['Vector2']['new'](screen['x'] / 2, screen['y'] / 2 + 20), MT['Vector2']['new'](screen.x/2+(math['abs'](desync_body)), screen.y/2 + 17), mt_color_sec, mt_color, mt_color_sec, mt_color)
            MT['render']['GradientBoxFilled'](MT['Vector2']['new'](screen['x'] / 2, screen['y'] / 2 + 20), MT['Vector2']['new'](screen.x/2+(-math['abs'](desync_body)), screen.y/2 + 17), mt_color_sec, mt_color, mt_color_sec, mt_color)
            local loc_indi
            local dt_is_enable = ragebot_rf['Doubletap']:Get()

            if dt_is_enable and categorys['Indicators']['madtech_indicator_op']:GetBool(1) then
                loc_indi = screen['y'] / 2 + 43
            else
                loc_indi = screen['y'] / 2 + 23
            end

            if categorys['Indicators']['madtech_indicator_op']:GetBool(1) then
                if dt_is_enable then
                    local mt_color_sec = categorys['Indicators']['madtech_indicator_sec']:GetColor()
                    local predict_size = screen['x'] / 2 - 28
                    MT['render']['Text']("DOUBLETAP", MT['Vector2']['new'](screen['x'] / 2 - 24.5, screen['y'] / 2 + 23), mt_color, 10, Tahoma)
                    MT['render']['BoxFilled'](MT['Vector2']['new'](screen['x'] / 2 - 30, screen['y'] / 2 + 42), MT['Vector2']['new'](screen['x'] / 2 + 30, screen['y'] / 2 + 35), MT['color'](0, 0, 0, 80))
                    MT['render']['GradientBoxFilled'](MT['Vector2']['new'](predict_size + Indicator['dt_fill'], screen['y'] / 2 + 40), MT['Vector2']['new'](predict_size, screen['y'] / 2 + 37), mt_color_sec, mt_color, mt_color_sec, mt_color)
                    local chrg = MT['Exploits']['GetCharge']()
                    if chrg ~= 1 then
                        Indicator['dt_fill'] = 3
                    else
                        MT['doubletap_pr']()
                    end
                end
            end
            if categorys['Indicators']['madtech_indicator_op']:GetBool(2) then
                local fs_is_enabled = categorys['Anti-Aim']['freestanding_hotkey']:Get()
                if fs_is_enabled then
                    MT['render']['Text']("FS", MT['Vector2']['new'](screen['x'] / 2 - 25, loc_indi), mt_color, 12, Tahoma)
                else
                    MT['render']['Text']("FS", MT['Vector2']['new'](screen['x'] / 2 - 25, loc_indi), MT['color'](130, 130, 130, 180), 12, Tahoma)
                end
                MT['render']['Text']("-", MT['Vector2']['new'](screen['x'] / 2 - 12, loc_indi), MT['color'](130, 130, 130, 180), 12, Tahoma)
                local hs_is_enabled = ragebot_rf['hideshot']:Get()
                if hs_is_enabled then
                    MT['render']['Text']("HS", MT['Vector2']['new'](screen['x'] / 2 - 7, loc_indi), mt_color, 12, Tahoma)
                else
                    MT['render']['Text']("HS", MT['Vector2']['new'](screen['x'] / 2 - 7, loc_indi), MT['color'](130, 130, 130, 180), 12, Tahoma)
                end
                MT['render']['Text']("-", MT['Vector2']['new'](screen['x'] / 2 + 7, loc_indi), MT['color'](130, 130, 130, 180), 12, Tahoma)
                local fakeduck = AntiAim_rf['fakeduck']:Get()
                if fakeduck then
                    MT['render']['Text']("FD", MT['Vector2']['new'](screen['x'] / 2 + 13, loc_indi), mt_color, 12, Tahoma)
                else
                    MT['render']['Text']("FD", MT['Vector2']['new'](screen['x'] / 2 + 13, loc_indi), MT['color'](130, 130, 130, 180), 12, Tahoma)
                end
            end
            if categorys['Indicators']['madtech_indicator_op']:GetBool(3) then
                local desync_arrow = math['abs'](desync_body)
                if desync_arrow > 25 then
                    desync_arrow = 25
                end
                local data = MT['get_nearest_enemy']()
                local origin = localplayer:GetEyePosition()
                local vec = MT['Vector']['new'](origin['x'], origin['y'], origin['z'])
                if data['id'] ~= nil then
                    distance = vec:DistTo(data['id']:GetProp("m_vecOrigin")) * 0.1
                end
            end
        end
        local mt_damage = categorys['Indicators']['minimum_indi']:Get()
        if mt_damage then
            local mt_damage = categorys['Indicators']['minimum_indi']:GetColor()
            local damage = tostring(ragebot_rf['minimum_damage']:Get())
            damage = damage == "0" and "AUTO" or damage
            MT['render']['Text'](damage, MT['Vector2']['new'](screen['x'] / 2 , screen['y'] / 2 - 14), mt_damage, 11, Tahoma)
        end
        local hd = categorys['Indicators']['hud']:Get()
        if hd then
            local hd_color = categorys['Indicators']['hud']:GetColor()
            MT['render']['BoxFilled'](MT['Vector2']['new'](screen['x'] / 2 - 80,  screen['y'] / 2 + 440), MT['Vector2']['new'](screen['x'] / 2 + 80,  screen['y'] / 2 + 400), hd_color)
            MT['render']['CircleFilled'](MT['Vector2']['new'](screen['x'] / 2 - 80,  screen['y'] / 2 + 420), 20.0, 120, hd_color, 90, 270)
            MT['render']['CircleFilled'](MT['Vector2']['new'](screen['x'] / 2 + 80,  screen['y'] / 2 + 420), 20.0, 120, hd_color, -90, 90)
            MT['render']['CircleFilled'](MT['Vector2']['new'](screen['x'] / 2 + 2,  screen['y'] / 2 + 420), 30.0, 120, MT['Color']['new'](hd_color.r, hd_color.g, hd_color.b, 255))
            if categorys['Indicators']['hud_image']:Get() == 0 then
                MT['render']['Image'](mt_nl_image, MT['Vector2']['new'](screen['x'] / 2 - 25.5 ,  screen['y'] / 2 + 393), MT['Vector2']['new'](55, 55))
            else
                MT['render']['Image'](av_image, MT['Vector2']['new'](screen['x'] / 2 - 25.5 ,  screen['y'] / 2 + 393), MT['Vector2']['new'](55, 55))
            end
            MT['render']['Text'](string['format']("fps: %s", MT['get_abs_fps']()), MT['Vector2']['new'](screen['x'] / 2 - 85, screen['y'] / 2 + 411.5), MT['color'](200, 200, 200, 255), 16)
            MT['render']['Text'](string['format']("ms: %s", MT['get_latency']()), MT['Vector2']['new'](screen['x'] / 2 + 40, screen['y'] / 2 + 411.5), MT['color'](200, 200, 200, 255), 16)
        end
    end
    
    function MT.doubletap_pr()
        local timer = MT['GlobalVars']['curtime']
        if Indicator['dt_fill'] < 55 then
            local livetime = timer - Indicator['dt_last']
            if timer >= 0.8 then
                Indicator['dt_last'] = timer
                Indicator['dt_fill'] = Indicator['dt_fill'] + 2
            end
        else
            Indicator['dt_fill'] = 56
        end
    end

    function MT.BruteTimer()
        if AntiAims['last_brute'] ~= 0 then
            if (MT['GlobalVars']['curtime'] - AntiAims['last_brute']) >= categorys['Antibruteforce']['reset_timer']:Get() then
                AntiAims['brute'] = 0
                AntiAims['last_brute'] = 0
                MT['Cheat']['AddEvent']("Antibruteforce timer reset")
            end
        end
    end

    MT['Cheat']['RegisterCallback']("createmove", function(cmd)
        local localplayer = get_client_entity(MT['EntityList']['GetLocalPlayer']():EntIndex())
        if not localplayer then return end
        for k, v in pairs(AntiAims['cache']) do
            MT['set_prop'](localplayer, k)
        end
        if cmd['viewangles']['roll'] > 0 then
            actual_mov = MT['Vector2']['new'](cmd.forwardmove, cmd.sidemove)
            MT['cr_movement'](cmd)
        end
    end)

    MT['Cheat']['RegisterCallback']("draw", function()
        MT['BruteTimer']()
        --Main
        local categoryes = category:Get()
        if categoryes == 0 then
            local antiaim = categorys['Anti-Aim']['antiaim_enable']:Get()
            categorys['Anti-Aim']['antiaim_enable']:SetVisible(false)
            categorys['Anti-Aim']['body_yaw']:SetVisible(antiaim)
            categorys['Anti-Aim']['Legit_aa']:SetVisible(antiaim)
            categorys['Anti-Aim']['Lowdelta']:SetVisible(antiaim)
            --categorys['Anti-Aim']['freestanding']:SetVisible(antiaim)
            categorys['Anti-Aim']['manual']:SetVisible(antiaim)
            local get_custom = categorys['Anti-Aim']['custom_aa_enable']:Get()
            categorys['Anti-Aim']['custom_mode']:SetVisible(get_custom)
            local live_custom_mode = custom_modes[categorys['Anti-Aim']['custom_mode']:Get() + 1]
            local antiaim_type = categorys['Anti-Aim'][live_custom_mode]['type']:Get()
            local leanmodes = categorys['Anti-Aim'][live_custom_mode][0]['leanmodes']:Get() ~= 0
            local fakemodes = categorys['Anti-Aim'][live_custom_mode][0]['fakeyaw_type']:Get() ~= 0
            local c_yaw_modifier = categorys['Anti-Aim'][live_custom_mode][0]['yaw_modifier']:Get() ~= 0 and (antiaim_type == 0 and true or false) or false
            local c_jitter = categorys['Anti-Aim'][live_custom_mode][0]['jitter']:Get() and true or false
            categorys['Anti-Aim'][live_custom_mode][0]['yawleft']:SetVisible(antiaim_type and c_jitter or false)
            categorys['Anti-Aim'][live_custom_mode][0]['yawright']:SetVisible(antiaim_type and c_jitter or false)
            categorys['Anti-Aim'][live_custom_mode][0]['modifire_degree']:SetVisible(c_yaw_modifier)
            categorys['Anti-Aim'][live_custom_mode][0]['fakeleft']:SetVisible(antiaim_type and fakemodes or false)
            categorys['Anti-Aim'][live_custom_mode][0]['fakeright']:SetVisible(antiaim_type and fakemodes or false)
            categorys['Anti-Aim'][live_custom_mode][0]['leanamount_left']:SetVisible(antiaim_type and leanmodes or false)
            categorys['Anti-Aim'][live_custom_mode][0]['leanamount_right']:SetVisible(antiaim_type and leanmodes or false)
            local fakelag = categorys['Anti-Aim']['a_lag']:Get()
            categorys['Anti-Aim']['a_limit']:SetVisible(fakelag ~= 0)
            categorys['Anti-Aim']['a_ticks']:SetVisible(fakelag == 2)
            if not get_custom then
                for _, b in pairs(custom_modes) do
                    for k, item in pairs(categorys['Anti-Aim'][b]) do
                        if type(item) == "table" then
                            for z, x in pairs(item) do
                                x:SetVisible(false)
                            end
                        else
                            item:SetVisible(false)
                        end
                    end
                end
            end
            if live_custom_mode == "Slow motion" then
                local walkspeed = get_custom and categorys['Anti-Aim']['Slow motion']['walkspeed']:Get() or false
                categorys['Anti-Aim']['Slow motion']['speed']:SetVisible(walkspeed)
            end
            --body yaw
            local bodyyaw = categorys['Anti-Aim']['body_yaw']:Get()
            if bodyyaw ~= 0 then
                categorys['Anti-Aim']['body_yow_slider']:SetVisible(antiaim and true or false)
            else
                categorys['Anti-Aim']['body_yow_slider']:SetVisible(antiaim and false or false)
            end
            if bodyyaw == 3 then
                categorys['Anti-Aim']['body_yow_inverter']:SetVisible(antiaim and true or false)
            else
                categorys['Anti-Aim']['body_yow_inverter']:SetVisible(antiaim and false or false)
            end
            --Legit aa
            local Legit_aa = categorys['Anti-Aim']['Legit_aa']:Get()
            categorys['Anti-Aim']['Legit_aa_backward']:SetVisible(antiaim and Legit_aa or false)
            categorys['Anti-Aim']['Legit_aa_hotkey']:SetVisible(antiaim and Legit_aa or false)
            categorys['Anti-Aim']['Legit_aa_modes']:SetVisible(antiaim and Legit_aa or false)
            --lowdelta
            local lowdelta = categorys['Anti-Aim']['Lowdelta']:Get()
            categorys['Anti-Aim']['Lowdelta_hotkey']:SetVisible(antiaim and lowdelta or false)
            categorys['Anti-Aim']['Lowdelta_desync']:SetVisible(antiaim and lowdelta or false)
            categorys['Anti-Aim']['Lowdelta_speed']:SetVisible(antiaim and lowdelta or false)
            --freestanding
            local fs = categorys['Anti-Aim']['freestanding']:Get()
            categorys['Anti-Aim']['freestanding_hotkey']:SetVisible(fs or false)
            categorys['Anti-Aim']['freestanding_modes']:SetVisible(fs or false)
            --edge_Yaw
            local ey = categorys['Anti-Aim']['edge']:Get()
            categorys['Anti-Aim']['edge_hotkey']:SetVisible(ey or false)
            categorys['Anti-Aim']['edge_modes']:SetVisible(ey or false)
            --manual aa 
            local maa = categorys['Anti-Aim']['manual']:Get()
            categorys['Anti-Aim']['manual_modes']:SetVisible(antiaim and maa or false)
            categorys['Anti-Aim']['manual_left']:SetVisible(antiaim and maa or false)
            categorys['Anti-Aim']['manual_right']:SetVisible(antiaim and maa or false)
            --Mega lean
            local roll = categorys['Anti-Aim']['roll']:Get()
            categorys['Anti-Aim']['roll_manual']:SetVisible(roll or false)
        elseif categoryes == 1 then
            --Doubletap
            local Doubletap = categorys['RageBot']['Doubletap']:Get()
            local Doubletap_fl = categorys['RageBot']['Doubletap_standby_chock']:Get()
            local Doubletap_rc = categorys['RageBot']['Doubletap_recharge']:Get()
            categorys['RageBot']['Doubletap_standby_chock']:SetVisible(Doubletap)
            categorys['RageBot']['Doubletap_recharge']:SetVisible(Doubletap)
            categorys['RageBot']['Doubletap_speed']:SetVisible(Doubletap)
            categorys['RageBot']['Doubletap_chock_cr']:SetVisible(Doubletap)
            categorys['RageBot']['extended_backtrack']:SetVisible(Doubletap)
            categorys['RageBot']['Doubletap_standby_chock_modes']:SetVisible(Doubletap and Doubletap_fl or false)
            categorys['RageBot']['Doubletap_recharge_t']:SetVisible(Doubletap and Doubletap_rc or false)
            -- idealtick
            local idealtick = categorys['RageBot']['idealtick']:Get() 
            local idealtick_op = categorys['RageBot']['idealtick_option']:Get()
            if idealtick_op == 0 then
                categorys['RageBot']['idealtick_hotkey']:SetVisible(idealtick and true or false)
            else
                categorys['RageBot']['idealtick_hotkey']:SetVisible(false)
            end
            categorys['RageBot']['idealtick_option']:SetVisible(idealtick)
            categorys['RageBot']['idealtick_modes']:SetVisible(idealtick)
            categorys['RageBot']['idealtick_weapons']:SetVisible(idealtick)
            categorys['RageBot']['idealtick_fakelag']:SetVisible(idealtick)
            -- onshot
            local onshot = categorys['RageBot']['Forceonshot']:Get()
            categorys['RageBot']['onshot_hotkey']:SetVisible(onshot)
            categorys['RageBot']['onshot_time']:SetVisible(onshot)
            -- forcebaim
            local forcebaim = categorys['RageBot']['Forcebaim']:Get()
            categorys['RageBot']['Forcebaim_weapons']:SetVisible(forcebaim)
            -- forcetp
            local forceteleportx = categorys['RageBot']['force_tp']:Get()
            categorys['RageBot']['force_tp_wp']:SetVisible(forceteleportx)
            categorys['RageBot']['force_tp_dist']:SetVisible(forceteleportx)
        elseif categoryes == 2 then
            -- indicator
            local switch = categorys['Indicators']['Indicators']:Get()
            categorys['Indicators']['madtech_indicator']:SetVisible(switch)
            categorys['Indicators']['watermark']:SetVisible(switch)
            categorys['Indicators']['minimum_indi']:SetVisible(switch)
            categorys['Indicators']['hud']:SetVisible(switch)
            -- Desyncline
            local desync_line = categorys['Indicators']['madtech_indicator']:Get()
            categorys['Indicators']['madtech_indicator_op']:SetVisible(switch and desync_line or false)
            categorys['Indicators']['madtech_indicator_sec']:SetVisible(switch and desync_line or false)
            -- Hud
            local hd = categorys['Indicators']['hud']:Get()
            categorys['Indicators']['hud_image']:SetVisible(switch and hd or false)
        elseif categoryes == 3 then
            local switch = categorys['Antibruteforce']['anti_bruteforce']:Get()
            categorys['Antibruteforce']['add_brute']:SetVisible(switch)
            categorys['Antibruteforce']['remove_brute']:SetVisible(switch)
            categorys['Antibruteforce']['reset_timer']:SetVisible(switch)
            for k,v in pairs(categorys['Antibruteforce']['brute']) do
                v:SetVisible(switch)
            end
        elseif categoryes == 4 then
            -- hit/miss log 
            local hitandmiss = categorys['Misc']['hitandmiss']:Get()
            categorys['Misc']['hitandmiss_box']:SetVisible(hitandmiss)
            categorys['Misc']['event_box']:SetVisible(hitandmiss)
        end
        MT['indicator']()
        local clantag_mt = categorys['Misc']['clantag_mt']:Get()
        if clantag_mt then
            MT['clantag_animation']()
        end
        MT['sleep_while']()
    end)
    MT['Cheat']['RegisterCallback']("destroy", function()
        ragebot_rf['bodyaim']:Set(ragebot_data['defualt_bodyaim'])
        for k,v in pairs(ragebot_data['defualt_bodyaim_disabler']) do
            ragebot_rf['bodyaim_db']:SetBool(k, v)
        end
    end)
end

MT['load']()

