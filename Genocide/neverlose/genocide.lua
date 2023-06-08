local ffi = require("ffi")
local base64 = require("neverlose/base64")
local clipboard = require("neverlose/clipboard")
local vmt_hook = require("neverlose/vmt_hook")
ffi.cdef([[
    typedef struct
    {
        uint8_t r;
        uint8_t g;
        uint8_t b;
        uint8_t a;
    } color_struct_t;
    typedef struct {
        char  pad_0000[20];
        int m_nOrder;
        int m_nSequence;
        float m_flPrevCycle;
        float m_flWeight;
        float m_flWeightDeltaRate;
        float m_flPlaybackRate;
        float m_flCycle;
        void *m_pOwner;
        char  pad_0038[4];
    } CAnimationLayer_t;
    typedef void (__cdecl* sendMessage)(void*, color_struct_t&, const char* text, ...);
    typedef void*(__thiscall* get_client_entity_t)(void*, int);
]])

local uintptr_t = ffi.typeof("uintptr_t**")
local this_call = function(call_function, parameters)
    return function(...)
        return call_function(parameters, ...)
    end
end

local entity_list_003 = ffi.cast(uintptr_t, utils.create_interface("client.dll", "VClientEntityList003"))
local get_entity_address = this_call(ffi.cast("get_client_entity_t", entity_list_003[0][3]), entity_list_003)

local genocide = {
    name = 'Genocide',
    build = 'DEBUG',
    version = '0.0.6',
    actual_movement = vector(0, 0),
    create_interface = function(self, args)
        return ffi.cast(args[1], self.utils.create_interface(args[2], args[3]))
    end,
    console = function(self, args)
        local uintptr_t = ffi.typeof("uintptr_t**")
        local c_color = ffi.typeof("color_struct_t")
        local c_engine = self:create_interface({uintptr_t, "vstdlib.dll", "VEngineCvar007"})
        local sendMessage = ffi.cast("sendMessage", c_engine[0][25])
        args[1] = #args[1] > 1 and string.format(' %s\n', args[1]) or args[1]
        sendMessage(c_engine, c_color(unpack(args[2])), args[1])
    end,
    console_g = function (self, args)
        local length = #args[1] - 1
        local r1, g1, b1, a1 = unpack(args[2])
        local r2, g2, b2, a2 = unpack(args[3])
        local r_next = (r2 - r1) / length
        local g_next = (g2 - g1) / length
        local b_next = (b2 - b1) / length
        local a_next = (a2 - a1) / length
        for i=1, length do
            self:console({args[1]:sub(i, i), {r1, g1, b1, a1}})
            r1 = r1 + r_next; g1 = g1 + g_next; b1 = b1 + b_next; a1 = a1 + a_next;
        end
    end,
    create_gradient = function(self, args)
        local message = ''
        local length = #args[1]
        local r1, g1, b1, a1 = unpack(args[2])
        local r2, g2, b2, a2 = unpack(args[3])
        local r_next = (r2 - r1) / length
        local g_next = (g2 - g1) / length
        local b_next = (b2 - b1) / length
        local a_next = (a2 - a1) / length
        for i=1, length do
            message = message .. string.format('\a%02x%02x%02x%02x%s', r1, g1, b1, a1, args[1]:sub(i, i))
            r1 = r1 + r_next; g1 = g1 + g_next; b1 = b1 + b_next; a1 = a1 + a_next;
        end
        return message
    end,
    error = function (self, error)
        self:console_g({string.format('%s|Error - ', self.name), {252, 3, 3, 255}, {255, 102, 102, 255}})
        self:console({error, {217, 217, 217, 255}})
    end,
    roll_movement = function(self, cmd)
        local frL, riL = self:angle_vector(vector(0, cmd.view_angles.y, 0))
        local frC, riC = self:angle_vector(cmd.view_angles)
        frL.z = 0
        riL.z = 0
        frC.z = 0
        riC.z = 0
        frL = frL / frL:length()
        riL = riL / riL:length()
        frC = frC / frC:length()
        riC = riC / riC:length()
        local worldCoords = frL * self.actual_movement.x + riL * self.actual_movement.y;
        cmd.sidemove = (frC.x * worldCoords.y - frC.y * worldCoords.x) / (riC.y * frC.x - riC.x * frC.y)
        cmd.forwardmove = (riC.y * worldCoords.x - riC.x * worldCoords.y) / (riC.y * frC.x - riC.x * frC.y)
    end,
    angle_vector = function(self, QAngle)
        local forward, right = vector(), vector()
        local pitch, yaw, roll = math.rad(QAngle.x), math.rad(QAngle.y), math.rad(QAngle.z)
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
}


local reference = {
    hideshot = ui.find('aimbot', 'ragebot', 'main', 'hide shots'),
    hideshot_option = ui.find('aimbot', 'ragebot', 'main', 'hide shots', 'Options'),
    doubletap = ui.find('aimbot', 'ragebot', 'main', 'double tap'),
    doubletap_limit = ui.find('aimbot', 'ragebot', 'main', 'double tap', 'fake lag limit'),
    bodyaim = ui.find('aimbot', 'ragebot', 'safety', 'body aim'),
    bodyaim_disabler = ui.find('aimbot', 'ragebot', 'safety', 'body aim', 'disablers'),
    slowwalk = ui.find('aimbot', 'anti aim', 'misc', 'slow walk'),
    pitch = ui.find('aimbot', 'anti aim', 'angles', 'pitch'),
    yaw = ui.find('aimbot', 'anti aim', 'angles', 'yaw'),
    base = ui.find('aimbot', 'anti aim', 'angles', 'yaw', 'base'),
    yaw_offset = ui.find('aimbot', 'anti aim', 'angles', 'yaw', 'offset'),
    avoidbackstab = ui.find('aimbot', 'anti aim', 'angles', 'yaw', 'avoid backstab'),
    yaw_modifier = ui.find('aimbot', 'anti aim', 'angles', 'yaw modifier'),
    jitter_offset = ui.find('aimbot', 'anti aim', 'angles', 'yaw modifier', 'offset'),
    bodyyaw = ui.find('aimbot', 'anti aim', 'angles', 'body yaw'),
    inverter = ui.find('aimbot', 'anti aim', 'angles', 'body yaw', 'inverter'),
    leftlimit = ui.find('aimbot', 'anti aim', 'angles', 'body yaw', 'left limit'),
    rightlimit = ui.find('aimbot', 'anti aim', 'angles', 'body yaw', 'right limit'),
    options = ui.find('aimbot', 'anti aim', 'angles', 'body yaw', 'options'),
    bodyyaw_freestanding = ui.find('aimbot', 'anti aim', 'angles', 'body yaw', 'freestanding'),
    onshot = ui.find('aimbot', 'anti aim', 'angles', 'body yaw', 'on shot'),
    lbymode = ui.find('aimbot', 'anti aim', 'angles', 'body yaw', 'lby mode'),
    freestanding = ui.find('aimbot', 'anti aim', 'angles', 'freestanding'),
    freestanding_disableyaw = ui.find('aimbot', 'anti aim', 'angles', 'freestanding', 'disable yaw modifiers'),
    freestanding_bodyfs = ui.find('aimbot', 'anti aim', 'angles', 'freestanding', 'body freestanding'),
    extendedangles = ui.find('aimbot', 'anti aim', 'angles', 'extended angles'),
    extended_pitch = ui.find('aimbot', 'anti aim', 'angles', 'extended angles', 'extended pitch'),
    extended_roll = ui.find('aimbot', 'anti aim', 'angles', 'extended angles', 'extended roll'),
    fakeduck = ui.find('aimbot', 'anti aim', 'misc', 'fake duck'),
    fakelatency = ui.find('miscellaneous', 'main', 'other', 'fake latency'),
    legmovement = ui.find('aimbot', 'anti aim', 'misc', 'leg movement'),

}
local LastTag = nil
set_clantag = function(clantag)
    if clantag == LastTag then return end
    common.set_clan_tag(clantag or "")
    LastTag = clantag
end

build_tag = function(tag)
    local ret = {' '}
    for i = 1, #tag do
        table.insert(ret, tag:sub(1, i))
    end
    for i = #ret - 1, 1, -1 do
        table.insert(ret, ret[i])
    end
    return ret
end
local genocide_clantag = build_tag(string.format("  %s  ", genocide.name:upper()))
tag_animation = function()
    local net_channel = utils.net_channel()
    if not globals.is_connected and not net_channel then return end
    local tickinterval = globals.tickinterval
    local tickcount = globals.tickcount
    local latency = net_channel.avg_latency[0] / tickinterval
    local tickcount_predict = tickcount + latency
    local key = math.floor(math.fmod(tickcount_predict / 40, #genocide_clantag + 1) + 1)
    set_clantag(genocide_clantag[key])
end

menu_is_open = function()
    return ui.get_alpha() > 0
end

is_fakelag = function()
    return reference.hideshot:get() or reference.doubletap:get()
end

get_velocity = function()
    local localplayer = entity.get_local_player()
    return math.floor(math.sqrt(localplayer.m_vecVelocity.x * localplayer.m_vecVelocity.x + localplayer.m_vecVelocity.y * localplayer.m_vecVelocity.y))
end

tickcount = function(tick)
    return (globals.tickcount % tick) + 1
end

matchExist = function(table, value)
    for k,v in pairs(table) do
        if v == value then
            return true, k
        end
    end
    return false
end

get_anim_overlay = function(entity, layer)
    return ffi.cast("CAnimationLayer_t**", ffi.cast("uintptr_t", entity) + 0x2990)[0][layer]
end

local default_aa = {
    pitch = "Disabled",
    pitch_delay = 2,
    pitch_randomize = {},
    yaw = "Disabled",
    base = "Local View",
    yaw_add = 0,
    yaw_jitter = false,
    jitter_left = 0,
    jitter_right = 0,
    yaw_modifier = "Disabled",
    yaw_offset = 0,
    fiveway_delay = 2,
    fiveway_offset = {0, 0, 0, 0, 0},
    fiveway_limit = {0, 0, 0, 0, 0},
    bodyyaw = false,
    inverter = false,
    inverterspam = false,
    inverterspam_delay = 2,
    leftlimit = 60,
    rightlimit = 60,
    options = {},
    freestanding = "Default",
    onshot = "Default",
    lbymode = "Disabled",
    roll = false,
    roll_modes = "Static",
    roll_delay = 2,
    roll_amount = 0,
    extendedangles = false,
    extendedpitch = 0,
    extendedroll = 0
}
local manual_roll = {['Limited']={['normal']={[true]={pitch="Down",yaw="Backward",base="Local View",yaw_add=-80,bodyyaw=false,leftlimit=60,rightlimit=60,roll=true,roll_amount=50},[false]={pitch="Down",yaw="Backward",base="Local View",yaw_add=80,bodyyaw=true,leftlimit=60,rightlimit=60,roll=true,roll_amount=50}},['fakelag']={[true]={pitch="Down",yaw="Backward",base="Local View",yaw_add=-80,bodyyaw=false,leftlimit=60,rightlimit=60,extendedangles=true,extendedpitch=-45,extendedroll=50},[false]={pitch="Down",yaw="Backward",base="Local View",yaw_add=80,bodyyaw=true,leftlimit=60,rightlimit=60,extendedangles=true,extendedpitch=-45,extendedroll=50}}},['Unlimited']={['normal']={[true]={pitch="Down",yaw="Backward",base="Local View",yaw_add=-80,bodyyaw=false,leftlimit=60,rightlimit=60,roll=true,roll_amount=70},[false]={pitch="Down",yaw="Backward",base="Local View",yaw_add=80,bodyyaw=true,leftlimit=60,rightlimit=60,roll=true,roll_amount=70}},['fakelag']={[true]={pitch="Down",yaw="Backward",base="Local View",yaw_add=-80,bodyyaw=false,leftlimit=60,rightlimit=60,extendedangles=true,extendedpitch=-45,extendedroll=90},[false]={pitch="Down",yaw="Backward",base="Local View",yaw_add=80,bodyyaw=true,leftlimit=60,rightlimit=60,extendedangles=true,extendedpitch=-45,extendedroll=90}}}}
local antiaim_preset = {}
local antiaim_types = {"normal", "fakelag"}
local aa_stats = {"global", "standing", "moving", "air", "air-c", "crouching", "slowwalk", "on key"}
ui.sidebar(genocide.name, 'hand-middle-finger')
local information = ui.create(ui.get_icon('id-card'), ui.get_icon('info')..' Information')
local general = ui.create(ui.get_icon('id-card'), ui.get_icon('tools')..' General')
local configsy = ui.create(ui.get_icon('id-card'), ui.get_icon('list')..' Configs')
local genologo = render.load_image(network.get("https://cdn.discordapp.com/attachments/1025188208650240090/1074994871380742184/genocide.png"), vector(270, 51))
information:texture(genologo, vector(270, 51), color(255, 255, 255, 255), 'f')
information:label(string.format('Welcome back, %s', genocide:create_gradient({common.get_username(), {0, 98, 255, 255}, {2, 46, 199, 255}})))
information:label(string.format('Build: %s', genocide:create_gradient({genocide.build, {0, 98, 255, 255}, {2, 46, 199, 255}})))
information:label(string.format('Version: %s', genocide:create_gradient({genocide.version, {0, 98, 255, 255}, {2, 46, 199, 255}})))

if db.configlist == nil then
    db.configlist = {"default"}
    db.autoload = false
    db.lastconfig = "default"
end

local configlist_data = db.configlist
local configlist = configsy:list("", configlist_data)
local configinput = configsy:input("Config name")

configsy:button(string.format("%s Save", ui.get_icon("save")), function()
    local cfglist = configlist:get()
    local cfginput = configinput:get()
    local config = save_config()
    local cfgname = configlist_data[cfglist]
    if #cfginput > 0 then
        if not matchExist(configlist_data, cfginput) then
            table.insert(configlist_data, cfginput)
            db[cfginput] = config
            db.configlist = configlist_data
            configlist:update(db.configlist)
            configinput:set("")
            configlist:set(#configlist_data)
        else
            db[cfgname] = config
        end
    else
        db[cfgname] = config
    end 
    common.add_notify("Conifg", string.format("(%s) successfully saved!", cfgname))
end, true)

configsy:button(string.format("%s Load", ui.get_icon("tasks")), function()
    local cfglist = configlist:get()
    local cfgname = configlist_data[cfglist]
    if db[cfgname] then
        db.lastconfig = cfgname
        load_config(db[cfgname])
        common.add_notify("Conifg", string.format("(%s) successfully loaded!", cfgname))
    else
        common.add_notify("Conifg", "Failed to load!")
    end
end, true)

configsy:button(string.format("%s Delete", ui.get_icon("trash")), function()
    local cfglist = configlist:get()
    local cfgname = configlist_data[cfglist]
    if cfglist ~= 1 then
        db[cfgname] = nil
        table.remove(configlist_data, cfglist)
        db.configlist = configlist_data
        configlist:update(db.configlist)
        common.add_notify("Conifg", string.format("(%s) successfully removed!", cfgname))
    else
        common.add_notify("Conifg", "You cant remove default config!")
    end
end, true)

configsy:button(string.format("%s Export", ui.get_icon("file-export")), function()
    local cfglist = configlist:get()
    local cfgname = configlist_data[cfglist]
    if db[cfgname] then
        clipboard.set(genocide.name.."_"..base64.encode(json.stringify(db[cfgname])))
        common.add_notify("Conifg", string.format("(%s) successfully exported!", cfgname))
    end
end, true)

configsy:button(string.format("%s Import", ui.get_icon("file-import")), function()
    local cfglist = configlist:get()
    local cfgname = configlist_data[cfglist]
    local getclipboard = clipboard.get()
    if #clipboard.get() > 20 then
        if getclipboard:match(genocide.name) then
            getclipboard = getclipboard:gsub(genocide.name.."_", "")
            local config = json.parse(base64.decode(getclipboard))
            load_config(config)
            common.add_notify("Conifg", string.format("(%s) successfully imported!", cfgname))
        else
            common.add_notify("Conifg", "Failed to import!")
        end
    else
        common.add_notify("Conifg", "Failed to import!")
    end
end, true)

configsy:switch("Autoload Config"):set_callback(function(value)
    db.autoload = value:get()
end):set(db.autoload)

utils.execute_after(2, function()
    if db.autoload then
        local configname = db.lastconfig
        load_config(db[configname])
        local _, key = matchExist(configlist_data, configname)
        configlist:set(key)
        common.add_notify("Conifg", string.format("(%s) successfully loaded!", configname))
    end
end)


local antiaim = ui.create(ui.get_icon('shield-alt'), ui.get_icon('shield-alt')..' AntiAim')
local builder = ui.create(ui.get_icon('shield-alt'), ui.get_icon('shapes')..' Builder')

local aimlogic = ui.create(ui.get_icon('globe'), ui.get_icon('memory')..' Aimbot logic')
local doubletap = ui.create(ui.get_icon('globe'), ui.get_icon('crosshairs')..' Doubletap')
local misc = ui.create(ui.get_icon('globe'), ui.get_icon('wrench')..' Misc')

local mc = {"antiaim", "ragebot", "misc"}
local menu = {
    ['antiaim'] = {
        enable = antiaim:switch('Enable AntiAim'),
        avoidbackstab = antiaim:switch('Avoid Backstab'),
        freestanding = antiaim:switch('Freestanding'),
        manual_roll = antiaim:switch('Manual Roll'),
        defensive_inair = antiaim:switch('Break LC In Air'),
        animationbreaker = antiaim:selectable('Anim. Breaker', {"Follow direction", "Static legs in air", "Zero pitch on land", "Moonwalk", "Moonwalk in air"}),
        stats = builder:combo('', aa_stats),
        builder = {}
    },
    ['ragebot'] = {
        forcebody = aimlogic:switch('Force Body Aim on Lethal'),
        extendedteleport = aimlogic:switch('Extended Teleport'),
        extendedbacktrack = aimlogic:switch('Extended Backtrack'):set_callback(function(value)
            if not value:get() then
                reference.fakelatency:set(5)
            end
        end),
        dt_type = doubletap:combo('Doubletap Type', {'Offensive', 'Defensive'}),
        override_dt = doubletap:switch('Doubletap Speed'),
        clock_correction = doubletap:switch('Clock Correction'):set(true)
    },
    ['misc'] = {
        clantag = misc:switch('Clantag'):set_callback(function(value)
            if not value:get() then
                set_clantag("")
            end
        end),
        aspectratio = misc:switch('Aspect Ratio'),
    }
}

menu[mc[1]].freestanding_sub = menu[mc[1]].freestanding:create()
menu[mc[1]].freestanding_fakelimit = menu[mc[1]].freestanding_sub:slider("Fake Limit", 0, 60, 60)
menu[mc[1]].freestanding_disabler = menu[mc[1]].freestanding_sub:selectable("Disabler", {"While inair", "While crouching", "While slowwalk", "While fakeduck"})
menu[mc[1]].freestanding_disableyaw = menu[mc[1]].freestanding_sub:switch("Disable Yaw Modifiers")
menu[mc[1]].freestanding_bodyfs = menu[mc[1]].freestanding_sub:switch("Body Freestanding")

menu[mc[1]].manual_roll_sub = menu[mc[1]].manual_roll:create()
menu[mc[1]].manual_roll_mode = menu[mc[1]].manual_roll_sub:combo('Modes', {'Limited', 'Unlimited'})
menu[mc[1]].manual_roll_hotkey = menu[mc[1]].manual_roll_sub:switch('Hotkey')

menu[mc[2]].forcebody_sub = menu[mc[2]].forcebody:create()
menu[mc[2]].forcebody_disablers = menu[mc[2]].forcebody_sub:selectable('Disablers', {'Target Resolved', 'Target Shooting', 'Head Safepoint'})
menu[mc[2]].forcebody_hp = menu[mc[2]].forcebody_sub:slider('Lethal HP', 20, 93, 85)
menu[mc[2]].override_dt_sub = menu[mc[2]].override_dt:create()
menu[mc[2]].dt_speed = menu[mc[2]].override_dt_sub:slider("Speed", 15, 22, 16)

menu[mc[2]].backtrack_sub = menu[mc[2]].extendedbacktrack:create()
menu[mc[2]].backtrack_bind = menu[mc[2]].backtrack_sub:hotkey('Hotkey')
menu[mc[2]].backtrack_lvl = menu[mc[2]].backtrack_sub:combo('', {'Maximum', 'Medium', 'Minimum'})
menu[mc[2]].backtrack_ticks = menu[mc[2]].backtrack_sub:slider('Ticks', 17, 20, 17)
menu[mc[2]].backtrack_latency = menu[mc[2]].backtrack_sub:slider('Fake Latency', 0, 200, 100)

menu[mc[3]].aspectratio_sub = menu[mc[3]].aspectratio:create()
menu[mc[3]].aspectratio_val = menu[mc[3]].aspectratio_sub:slider('Value', 0, 50, 10, 0.1)

for k,v in pairs(aa_stats) do
    antiaim_preset[v] = {}
    menu[mc[1]].builder[v] = {}
    menu[mc[1]].builder[v].aatype = builder:combo('Exploit Type', {'normal', 'fakelag'})
    if v == "on key" then
        menu[mc[1]].builder[v].bind = builder:hotkey("Hotkey", 0x45)
    end
    for m,w in pairs(antiaim_types) do
        antiaim_preset[v][w] = {}
        menu[mc[1]].builder[v][w] = {}
        if v ~= "global" then 
                menu[mc[1]].builder[v][w].enables = builder:switch('['..v:upper()..'] Enable'):set_callback(function(value)
                antiaim_preset[v][w].enable = value:get()
                menu[mc[1]].builder[v].aatype:set_visible(value:get())
                menu[mc[1]].builder[v][w].pitch:set_visible(value:get())
                menu[mc[1]].builder[v][w].yaw:set_visible(value:get())
                menu[mc[1]].builder[v][w].bodyyaw:set_visible(value:get())
                local aatype = menu[mc[1]].builder[v].aatype:get()
                menu[mc[1]].builder[v][w].roll:set_visible(aatype == "normal" and value:get())
                menu[mc[1]].builder[v][w].extendedangles:set_visible(aatype == "fakelag" and value:get())
            end)
        end
        menu[mc[1]].builder[v][w].pitch = builder:combo('Pitch', {"Disabled", "Down", "Fake Down", "Fake Up", "Randomize"}):set_callback(function(value)
            antiaim_preset[v][w].pitch = value:get()
        end)
        menu[mc[1]].builder[v][w].pitch_sub = menu[mc[1]].builder[v][w].pitch:create()
        menu[mc[1]].builder[v][w].pitch_delay = menu[mc[1]].builder[v][w].pitch_sub:slider("Delay", 1, 10, 1):set_callback(function(value)
            antiaim_preset[v][w].pitch_delay = value:get()
        end)
        menu[mc[1]].builder[v][w].pitch_randomize = menu[mc[1]].builder[v][w].pitch_sub:selectable("Pitch", {"Disabled", "Down", "Fake Down", "Fake Up"}):set_callback(function(value)
            antiaim_preset[v][w].pitch_randomize = value:get()
        end)
        menu[mc[1]].builder[v][w].yaw = builder:combo("Yaw", {"Disabled", "Backward", "Static"}):set_callback(function(value)
            antiaim_preset[v][w].yaw = value:get()
        end)
        menu[mc[1]].builder[v][w].sub_yaw = menu[mc[1]].builder[v][w].yaw:create()
        menu[mc[1]].builder[v][w].base = menu[mc[1]].builder[v][w].sub_yaw:combo("Base", {"Local View", "At Target"}):set_callback(function(value)
            antiaim_preset[v][w].base = value:get()
        end)
        menu[mc[1]].builder[v][w].yaw_add = menu[mc[1]].builder[v][w].sub_yaw:slider("Yaw Add", -180, 180, 0):set_callback(function(value)
            antiaim_preset[v][w].yaw_add = value:get()
        end)
        menu[mc[1]].builder[v][w].yaw_jitter = menu[mc[1]].builder[v][w].sub_yaw:switch('Yaw Jitter'):set_callback(function(value)
            antiaim_preset[v][w].yaw_jitter = value:get()
        end)
        menu[mc[1]].builder[v][w].jitter_left = menu[mc[1]].builder[v][w].sub_yaw:slider("Offset left", -180, 180, 0):set_callback(function(value)
            antiaim_preset[v][w].jitter_left = value:get()
        end)
        menu[mc[1]].builder[v][w].jitter_right = menu[mc[1]].builder[v][w].sub_yaw:slider("Offset right", -180, 180, 0):set_callback(function(value)
            antiaim_preset[v][w].jitter_right = value:get()
        end)
        menu[mc[1]].builder[v][w].yaw_modifier = menu[mc[1]].builder[v][w].sub_yaw:combo("Yaw modifier", {"Disabled", "Center", "Offset", "Random", "Spin", "5-WAY"}):set_callback(function(value)
            antiaim_preset[v][w].yaw_modifier = value:get()
        end)
        menu[mc[1]].builder[v][w].yaw_offset = menu[mc[1]].builder[v][w].sub_yaw:slider("Offset", -180, 180, 0):set_callback(function(value)
            antiaim_preset[v][w].yaw_offset = value:get()
        end)
        if not antiaim_preset[v][w].fiveway_delay then
            antiaim_preset[v][w].fiveway_offset = {0, 0, 0, 0, 0}
            antiaim_preset[v][w].fiveway_limit = {0, 0, 0, 0, 0}
        end
        menu[mc[1]].builder[v][w].fiveway_delay = menu[mc[1]].builder[v][w].sub_yaw:slider("Delay", 1, 10, 1):set_callback(function(value)
            antiaim_preset[v][w].fiveway_delay = value:get()
        end)
        menu[mc[1]].builder[v][w].fiveway_offset_1 = menu[mc[1]].builder[v][w].sub_yaw:slider("[1] Offset", -180, 180, 0):set_callback(function(value)
            antiaim_preset[v][w].fiveway_offset[1] = value:get()
        end)
        menu[mc[1]].builder[v][w].fiveway_offset_2 = menu[mc[1]].builder[v][w].sub_yaw:slider("[2] Offset", -180, 180, 0):set_callback(function(value)
            antiaim_preset[v][w].fiveway_offset[2] = value:get()
        end)
        menu[mc[1]].builder[v][w].fiveway_offset_3 = menu[mc[1]].builder[v][w].sub_yaw:slider("[3] Offset", -180, 180, 0):set_callback(function(value)
            antiaim_preset[v][w].fiveway_offset[3] = value:get()
        end)
        menu[mc[1]].builder[v][w].fiveway_offset_4 = menu[mc[1]].builder[v][w].sub_yaw:slider("[4] Offset", -180, 180, 0):set_callback(function(value)
            antiaim_preset[v][w].fiveway_offset[4] = value:get()
        end)
        menu[mc[1]].builder[v][w].fiveway_offset_5 = menu[mc[1]].builder[v][w].sub_yaw:slider("[5] Offset", -180, 180, 0):set_callback(function(value)
            antiaim_preset[v][w].fiveway_offset[5] = value:get()
        end)
        menu[mc[1]].builder[v][w].fiveway_limit_1 = menu[mc[1]].builder[v][w].sub_yaw:slider("[1] FakeLimit", -60, 60, 0):set_callback(function(value)
            antiaim_preset[v][w].fiveway_limit[1] = value:get()
        end)
        menu[mc[1]].builder[v][w].fiveway_limit_2 = menu[mc[1]].builder[v][w].sub_yaw:slider("[2] FakeLimit", -60, 60, 0):set_callback(function(value)
            antiaim_preset[v][w].fiveway_limit[2] = value:get()
        end)
        menu[mc[1]].builder[v][w].fiveway_limit_3 = menu[mc[1]].builder[v][w].sub_yaw:slider("[3] FakeLimit", -60, 60, 0):set_callback(function(value)
            antiaim_preset[v][w].fiveway_limit[3] = value:get()
        end)
        menu[mc[1]].builder[v][w].fiveway_limit_4 = menu[mc[1]].builder[v][w].sub_yaw:slider("[4] FakeLimit", -60, 60, 0):set_callback(function(value)
            antiaim_preset[v][w].fiveway_limit[4] = value:get()
        end)
        menu[mc[1]].builder[v][w].fiveway_limit_5 = menu[mc[1]].builder[v][w].sub_yaw:slider("[5] FakeLimit", -60, 60, 0):set_callback(function(value)
            antiaim_preset[v][w].fiveway_limit[5] = value:get()
        end)
        menu[mc[1]].builder[v][w].bodyyaw = builder:switch("Body Yaw"):set_callback(function(value)
            antiaim_preset[v][w].bodyyaw = value:get()
        end)
        menu[mc[1]].builder[v][w].sub_bodyyaw = menu[mc[1]].builder[v][w].bodyyaw:create()
        menu[mc[1]].builder[v][w].inverter = menu[mc[1]].builder[v][w].sub_bodyyaw:switch("Inverter"):set_callback(function(value)
            antiaim_preset[v][w].inverter = value:get()
        end)
        menu[mc[1]].builder[v][w].inverterspam = menu[mc[1]].builder[v][w].sub_bodyyaw:switch("Inverter spam"):set_callback(function(value)
            antiaim_preset[v][w].inverterspam = value:get()
        end)
        menu[mc[1]].builder[v][w].inverterspam_delay = menu[mc[1]].builder[v][w].sub_bodyyaw:slider("Delay", 1, 10, 1):set_callback(function(value)
            antiaim_preset[v][w].inverterspam_delay = value:get()
        end)
        menu[mc[1]].builder[v][w].leftlimit = menu[mc[1]].builder[v][w].sub_bodyyaw:slider("Left limit", 0, 60, 60):set_callback(function(value)
            antiaim_preset[v][w].leftlimit = value:get()
        end)
        menu[mc[1]].builder[v][w].rightlimit = menu[mc[1]].builder[v][w].sub_bodyyaw:slider("Right limit", 0, 60, 60):set_callback(function(value)
            antiaim_preset[v][w].rightlimit = value:get()
        end)
        menu[mc[1]].builder[v][w].options = menu[mc[1]].builder[v][w].sub_bodyyaw:selectable("Options", {"Avoid Overlap", "Anti Bruteforce"}):set_callback(function(value)
            antiaim_preset[v][w].options = value:get()
        end)
        menu[mc[1]].builder[v][w].freestanding = menu[mc[1]].builder[v][w].sub_bodyyaw:combo("Freestanding", {"Default", "With Player", "With Edge","Reversed Player", "Reversed Edge"}):set_callback(function(value)
            antiaim_preset[v][w].freestanding = value:get()
        end)
        menu[mc[1]].builder[v][w].onshot = menu[mc[1]].builder[v][w].sub_bodyyaw:combo("On Shot", {"Default", "Opposite", "Freestanding", "Switch"}):set_callback(function(value)
            antiaim_preset[v][w].onshot = value:get()
        end)
        menu[mc[1]].builder[v][w].lbymode = menu[mc[1]].builder[v][w].sub_bodyyaw:combo("LBY Mode", {"Disable", "Opposite", "Sway"}):set_callback(function(value)
            antiaim_preset[v][w].lbymode = value:get()
        end)
        menu[mc[1]].builder[v][w].roll = builder:switch("Roll"):set_callback(function(value)
            antiaim_preset[v][w].roll = value:get()
        end)
        menu[mc[1]].builder[v][w].sub_roll = menu[mc[1]].builder[v][w].roll:create()
        menu[mc[1]].builder[v][w].roll_modes = menu[mc[1]].builder[v][w].sub_roll:combo("Modes", {"Static", "Jitter", "Freestand", "Reversed Freestand"}):set_callback(function(value)
            antiaim_preset[v][w].roll_modes = value:get()
        end)
        menu[mc[1]].builder[v][w].roll_delay = menu[mc[1]].builder[v][w].sub_roll:slider("Delay", 1, 10, 1):set_callback(function(value)
            antiaim_preset[v][w].roll_delay = value:get()
        end)
        menu[mc[1]].builder[v][w].roll_amount = menu[mc[1]].builder[v][w].sub_roll:slider("Amount", -70, 70, 0):set_callback(function(value)
            antiaim_preset[v][w].roll_amount = value:get()
        end)
        menu[mc[1]].builder[v][w].extendedangles = builder:switch("Extended Angles"):set_callback(function(value)
            antiaim_preset[v][w].extendedangles = value:get()
        end)
        menu[mc[1]].builder[v][w].extended = menu[mc[1]].builder[v][w].extendedangles:create()
        menu[mc[1]].builder[v][w].extendedpitch = menu[mc[1]].builder[v][w].extended:slider("Extended Pitch", -180, 180, 0):set_callback(function(value)
            antiaim_preset[v][w].extendedpitch = value:get()
        end)
        menu[mc[1]].builder[v][w].extendedroll = menu[mc[1]].builder[v][w].extended:slider("Extended Roll", 0, 90, 0):set_callback(function(value)
            antiaim_preset[v][w].extendedroll = value:get()
        end)
    end
end


update_antiaim_menu = function()
    local antiaim_enable = menu[mc[1]].enable:get()
    for k,v in pairs(menu[mc[1]]) do
        if k ~= "enable" then
            if type(v) ~= "table" then
                if tostring(v):match("menu_item") then
                    v:set_visible(antiaim_enable)
                end
            else
                for r,w in pairs(v) do
                    for z,m in pairs(antiaim_types) do
                        if w[m].enables then
                            w[m].enables:set_visible(antiaim_enable)
                        end
                        w.aatype:set_visible(antiaim_enable)
                        w[m].pitch:set_visible(antiaim_enable)
                        w[m].yaw:set_visible(antiaim_enable)
                        w[m].bodyyaw:set_visible(antiaim_enable)
                        w[m].roll:set_visible(antiaim_enable)
                        w[m].extendedangles:set_visible(antiaim_enable)
                        -- menu[mc[1]].builder[w][m]
                    end
                end
            end
        end
    end
    if antiaim_enable then
        local stats = menu[mc[1]].stats:get()
        for k,v in pairs(aa_stats) do
            local aatype = menu[mc[1]].builder[v].aatype:get()
            menu[mc[1]].builder[v].aatype:set_visible(v == stats)
            if v == "on key" then
                menu[mc[1]].builder[v].bind:set_visible(v == stats)
            end
            for m,w in pairs(antiaim_types) do
                local is_enable = v == stats and w == aatype
                if menu[mc[1]].builder[v][w].enables then
                    menu[mc[1]].builder[v][w].enables:set_visible(is_enable)
                    is_enable = v == stats and menu[mc[1]].builder[v][w].enables:get() and w == aatype
                end
                local pitch = menu[mc[1]].builder[v][w].pitch:get()
                menu[mc[1]].builder[v][w].pitch:set_visible(is_enable)
                menu[mc[1]].builder[v][w].pitch_delay:set_visible(pitch == "Randomize")
                menu[mc[1]].builder[v][w].pitch_randomize:set_visible(pitch == "Randomize")
                menu[mc[1]].builder[v][w].yaw:set_visible(is_enable)
                menu[mc[1]].builder[v][w].bodyyaw:set_visible(is_enable)
                local yaw_jitter = menu[mc[1]].builder[v][w].yaw_jitter:get()
                menu[mc[1]].builder[v][w].yaw_add:set_visible(not yaw_jitter)
                menu[mc[1]].builder[v][w].jitter_left:set_visible(yaw_jitter)
                menu[mc[1]].builder[v][w].jitter_right:set_visible(yaw_jitter)
                local inverterspam = menu[mc[1]].builder[v][w].inverterspam:get()
                menu[mc[1]].builder[v][w].inverter:set_visible(not inverterspam)
                menu[mc[1]].builder[v][w].inverterspam_delay:set_visible(inverterspam)
                menu[mc[1]].builder[v][w].roll:set_visible(aatype == "normal" and is_enable)
                menu[mc[1]].builder[v][w].extendedangles:set_visible(aatype == "fakelag" and is_enable)
                local yaw_modifier = menu[mc[1]].builder[v][w].yaw_modifier:get()
                menu[mc[1]].builder[v][w].yaw_offset:set_visible(yaw_modifier ~= "5-WAY")
                menu[mc[1]].builder[v][w].fiveway_delay:set_visible(yaw_modifier == "5-WAY")
                menu[mc[1]].builder[v][w].fiveway_offset_1:set_visible(yaw_modifier == "5-WAY")
                menu[mc[1]].builder[v][w].fiveway_limit_1:set_visible(yaw_modifier == "5-WAY")
                menu[mc[1]].builder[v][w].fiveway_offset_2:set_visible(yaw_modifier == "5-WAY")
                menu[mc[1]].builder[v][w].fiveway_limit_2:set_visible(yaw_modifier == "5-WAY")
                menu[mc[1]].builder[v][w].fiveway_offset_3:set_visible(yaw_modifier == "5-WAY")
                menu[mc[1]].builder[v][w].fiveway_limit_3:set_visible(yaw_modifier == "5-WAY")
                menu[mc[1]].builder[v][w].fiveway_offset_4:set_visible(yaw_modifier == "5-WAY")
                menu[mc[1]].builder[v][w].fiveway_limit_4:set_visible(yaw_modifier == "5-WAY")
                menu[mc[1]].builder[v][w].fiveway_offset_5:set_visible(yaw_modifier == "5-WAY")
                menu[mc[1]].builder[v][w].fiveway_limit_5:set_visible(yaw_modifier == "5-WAY")
                local rollmodes = menu[mc[1]].builder[v][w].roll_modes:get()
                menu[mc[1]].builder[v][w].roll_delay:set_visible(rollmodes == "Jitter")
            end
        end
    end
end

save_config = function()
    local config = {}
    for k,v in pairs(menu) do
        config[k] = {}
        for m,w in pairs(v) do
            if m ~= "builder" then
                if tostring(w):match("menu_item") then
                    config[k][m] = w:get()
                end
            else
                config[k][m] = {}
                for z,a in pairs(w) do
                    config[k][m][z] = {}
                    for q,e in pairs(antiaim_types) do
                        config[k][m][z][e] = {}
                        for i,l in pairs(a[e]) do
                            if tostring(l):match("menu_item") then
                                config[k][m][z][e][i] = l:get()
                            end
                        end
                    end
                end
            end
        end
    end
    return config
end

load_config = function(config)
    for k,v in pairs(config) do
        for m,w in pairs(v) do
            if menu[k] then
                if menu[k][m] then
                    if m ~= "builder" then
                        if menu[k][m]:get_type() ~= "hotkey" then
                            menu[k][m]:set(w)
                        end
                    else
                        for z,a in pairs(w) do
                            for q,e in pairs(antiaim_types) do
                                if a[e] then
                                    for i,l in pairs(a[e]) do
                                        antiaim_preset[z][e][i] = l
                                        menu[k][m][z][e][i]:set(l)
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

reset_menu = function()
    for k,v in pairs(aa_stats) do
        for m,w in pairs(antiaim_types) do
            for z, b in pairs(menu[mc[1]].builder[v][w]) do
                if tostring(menu[mc[1]].builder[v][w][z]):match("menu_item") then
                    menu[mc[1]].builder[v][w][z]:reset()
                end
            end
        end
    end
end

get_desyncside = function()
    local desyncside = false
    local localplayer = entity.get_local_player()
    if not localplayer then return end
    local chesthitbox = localplayer:get_hitbox_position(3)
    local cameraAngle = render.camera_angles()
    local cameraPostion = render.camera_position()
    local angles = {
        angle_left = 0,
        angle_right = 0,
        dist_left = 0,
        dist_right = 0
    }
    for i=20, 120, 10 do
        local angle_left = chesthitbox + vector():angles(0, i + cameraAngle.y) * 100
        local trace_left = utils.trace_line(chesthitbox, angle_left, nil, 0xFFFFFFFF, 1)
        local dist_left = chesthitbox:dist(trace_left.end_pos)
        local angle_right = chesthitbox + vector():angles(0, (-i) + cameraAngle.y) * 100
        local trace_right = utils.trace_line(chesthitbox, angle_right, nil, 0xFFFFFFFF, 1)
        local dist_right = chesthitbox:dist(trace_right.end_pos)
        if angles.dist_left == 0 or dist_left - 1 > angles.dist_left then
            angles.dist_left = dist_left
            angles.angle_left = i
        end
        if angles.dist_right == 0 or dist_right - 1 > angles.dist_right then
            angles.dist_right = dist_right
            angles.angle_right = i
        end
    end
    if angles.angle_left < angles.angle_right then
        desyncside = true
    elseif angles.angle_left > angles.angle_right then
        desyncside = false
    end
    return desyncside
end

antiaim_stats = function()
    local localplayer = entity.get_local_player()
    local velocity = get_velocity()
    local flags = bit.band(localplayer.m_fFlags, 1) == 0
    local duckamount = localplayer.m_flDuckAmount
    local is_slowwalk = reference.slowwalk:get()
    local in_air = common.is_button_down(0x20)
    local in_crouching = common.is_button_down(0x11)
    local onkey_use = menu[mc[1]].builder['on key'].bind:get()
    local onkey_normal = menu[mc[1]].builder['on key']['normal'].enables:get()
    local onkey_fakelag = menu[mc[1]].builder['on key']['fakelag'].enables:get()
    if onkey_use then if onkey_normal or onkey_fakelag then return "on key" end end
    if flags and (in_crouching or duckamount >= 0.5) then return "air-c" end
    if in_air or flags then return "air" end
    if duckamount >= 0.5 then return "crouching" end
    if is_slowwalk then return "slowwalk" end
    if velocity > 1 then
        return "moving"
    else
        return "standing"
    end
end

freestanding = function(stats)
    local disabled = false
    local fs = menu[mc[1]].freestanding:get()
    local fs_fakelimit = menu[mc[1]].freestanding_fakelimit:get()
    local fs_disabler = menu[mc[1]].freestanding_disabler:get()
    local fs_disableyaw = menu[mc[1]].freestanding_disableyaw:get()
    local fs_bodyfreestand = menu[mc[1]].freestanding_bodyfs:get()
    if fs then
        for k,v in pairs(fs_disabler) do
            if v == "While inair" then
                if stats == "air" or stats == "air-c" then
                    disabled = true
                    break
                end
            elseif v == "While crouching" then
                if stats == "crouching" then
                    disabled = true
                    break
                end
            elseif v == "While slowwalk" then
                if stats == "slowwalk" then
                    disabled = true
                    break
                end
            elseif v == "While fakeduck" then
                if reference.fakeduck:get() then
                    disabled = true
                    break
                end
            end
        end
        reference.pitch:override("Down")
        reference.freestanding:override(not disabled)
        reference.freestanding_disableyaw:override(fs_disableyaw)
        reference.freestanding_bodyfs:override(fs_bodyfreestand)
        reference.leftlimit:override(fs_fakelimit)
        reference.rightlimit:override(fs_fakelimit)
    end
    return fs and not disabled
end

local lastway = 0
local lastpitch = "Disabled"
local lastinvert = false
local lastdesync = false
local weapon_id = 0
update_antiaim = function(cmd, data, stats)
    local localplayer = entity.get_local_player()
    local weapon = localplayer:get_player_weapon()
    local m_vecOrigin = localplayer.m_vecOrigin
    if weapon then
        weapon_id = weapon:get_classid()
    end
    if not freestanding(stats) then
        local lastdesync = get_desyncside()
        local types = is_fakelag() and 'normal' or 'fakelag'
        local isenable = menu[mc[1]].builder[stats][types].enables:get()
        if stats == "on key" then
            local dist = 85
            local bomb, hostage, doors = false, false, false
            entity.get_entities(129, false, function(value) -- BOMB
                local distance = value.m_vecOrigin
                distanceBtw = vector(distance.x, distance.y, distance.z):dist(vector(m_vecOrigin.x, m_vecOrigin.y, m_vecOrigin.z))
                if distanceBtw < dist then
                    bomb = true
                end
            end)
            entity.get_entities(97, false, function(value) -- HOSTAGE
                local distance = value.m_vecOrigin
                distanceBtw = vector(distance.x, distance.y, distance.z):dist(vector(m_vecOrigin.x, m_vecOrigin.y, m_vecOrigin.z))
                if distanceBtw < dist then
                    hostage = true
                end
            end)
            entity.get_entities(143, false, function(value) -- DOORS
                local distance = value.m_vecOrigin
                distanceBtw = vector(distance.x, distance.y, distance.z):dist(vector(m_vecOrigin.x, m_vecOrigin.y, m_vecOrigin.z))
                if distanceBtw < dist then
                    doors = true
                end
            end)
            if not bomb and not hostage and not doors then
                cmd.buttons = bit.band(cmd.buttons, bit.bnot(32))
            end
        end
        data = isenable and data or antiaim_preset['global']
        local is_manual_roll = menu[mc[1]].manual_roll:get()
        local manual_roll_mode = menu[mc[1]].manual_roll_mode:get()
        local manual_roll_hotkey = menu[mc[1]].manual_roll_hotkey:get()
        if is_manual_roll and manual_roll_hotkey then
            data = manual_roll[manual_roll_mode][types][lastdesync]
        else
            data = data[types]
        end
        if data.pitch ~= "Randomize" then
            reference.pitch:override(data.pitch or default_aa.pitch)
        else
            if not data.pitch_randomize then
                data.pitch_delay = default_aa.pitch_delay
                data.pitch_randomize = default_aa.pitch_randomize
            end
            if tickcount(data.pitch_delay + 1) == data.pitch_delay then
                lastpitch = data.pitch_randomize[math.random(#data.pitch_randomize)]
            end
            reference.pitch:override(lastpitch)
        end
        reference.base:override(data.base or default_aa.base)
        reference.yaw:override(data.yaw or default_aa.yaw)
        if data.yaw_modifier ~= "5-WAY" then
            if not data.inverterspam then
                if data.freestanding == "Default" then
                    reference.bodyyaw_freestanding:override("Off")
                    reference.inverter:override(data.inverter or default_aa.inverter)
                elseif data.freestanding == "With Player" then
                    reference.bodyyaw_freestanding:override("Peek Fake")
                elseif data.freestanding == "Reversed Player" then
                    reference.bodyyaw_freestanding:override("Peek Real")
                elseif data.freestanding == "With Edge" then
                    reference.bodyyaw_freestanding:override("Off")
                    reference.inverter:override(lastdesync)
                elseif data.freestanding == "Reversed Edge" then
                    reference.bodyyaw_freestanding:override("Off")
                    reference.inverter:override(not lastdesync)
                end
            else
                if tickcount(data.inverterspam_delay + 1) == data.inverterspam_delay then
                    lastinvert = not lastinvert
                end
                reference.inverter:override(lastinvert)
            end
            if data.yaw_jitter then
                reference.yaw_offset:override(tickcount(3) >= 3 and data.jitter_left or data.jitter_right)
            else
                reference.yaw_offset:override(data.yaw_add or default_aa.yaw_add)
            end
            reference.yaw_modifier:override(data.yaw_modifier or default_aa.yaw_modifier)
            reference.jitter_offset:override(data.yaw_offset or default_aa.yaw_offset)
            reference.leftlimit:override(data.leftlimit or default_aa.leftlimit)
            reference.rightlimit:override(data.rightlimit or default_aa.rightlimit)
        else
            if not data.fiveway_delay then
                data.fiveway_delay = default_aa.fiveway_delay
            end
            if tickcount(data.fiveway_delay + 1) == data.fiveway_delay then
                if lastway + 1 == 6 then
                    lastway = 1
                else
                    lastway = lastway + 1
                end
            end
            reference.yaw_offset:override(data.fiveway_offset[lastway] or default_aa.fiveway_offset[lastway])
            local bodylimit = data.fiveway_limit[lastway] or default_aa.fiveway_limit[lastway]
            if bodylimit then
                reference.inverter:override(bodylimit < 0)
                reference.leftlimit:override(math.abs(bodylimit))
                reference.rightlimit:override(math.abs(bodylimit))
            end
        end
        reference.bodyyaw:override(data.bodyyaw or default_aa.bodyyaw)
        reference.options:override(data.options or default_aa.options)
        reference.onshot:override(data.onshot or default_aa.onshot)
        reference.lbymode:override(data.lbymode or default_aa.lbymode)
        reference.extendedangles:override(data.extendedangles or default_aa.extendedangles)
        reference.extended_pitch:override(data.extendedpitch or default_aa.extendedpitch)
        reference.extended_roll:override(data.extendedroll or default_aa.extendedroll)
        reference.freestanding:override(false)
        if data.roll then
            if data.roll_modes == "Jitter" then
                if tickcount(data.roll_delay + 1) == data.roll_delay then
                    data.roll_amount = data.roll_amount > 0 and -data.roll_amount or math.abs(data.roll_amount)
                end
            elseif data.roll_modes == "Freestand" then
                data.roll_amount = lastdesync and -data.roll_amount or math.abs(data.roll_amount)
            elseif data.roll_modes == "Reversed Freestand" then
                data.roll_amount = not lastdesync and -data.roll_amount or math.abs(data.roll_amount)
            end
            if weapon_id ~= 156 and weapon_id ~= 96 and weapon_id ~= 99 then
                cmd.view_angles.z = data.roll_amount
                genocide:roll_movement(cmd)
            end
        end
        reference.avoidbackstab:override(menu[mc[1]].avoidbackstab:get())
    end
end

get_target = function()
    local camera_angles = render.camera_angles()
    local camera_position = render.camera_position()
    local direction = vector():angles(camera_angles)
    local closest_enemy, closest_distance = nil, math.huge
    for k,v in pairs(entity.get_players(true)) do
        local headpostion = v:get_hitbox_position(1)
        local ray_distance = headpostion:dist_to_ray(camera_position, direction)
        if closest_distance > ray_distance then
            closest_enemy = v
            closest_distance = ray_distance
        end
    end
    return {closest_enemy, closest_distance}
end

forcebody = function()
    local target = get_target()
    if target[1] then
        local health = target[1].m_iHealth
        local bodyaim = reference.bodyaim:get()
        local forcebodyhp = menu[mc[2]].forcebody_hp:get()
        local forcebody_disablers = menu[mc[2]].forcebody_disablers:get()
        if forcebodyhp >= health and not target[1]:is_dormant() and target[1]:is_alive() then
            if bodyaim ~= "Force" then
                reference.bodyaim:set('Force')
                reference.bodyaim_disabler:set({})
            end
        else
            if bodyaim ~= "Default" then
                reference.bodyaim:set('Default')
                reference.bodyaim_disabler:set(forcebody_disablers)
            end
        end
    end
end

local last_doubletap_charge = 0
ragebot = function(cmd)
    local antiaim_stats = antiaim_stats()
    local doubletap = reference.doubletap:get()
    local backtrack = menu[mc[2]].extendedbacktrack:get()
    local backtrack_bind = menu[mc[2]].backtrack_bind:get()
    local process_ticks = cvar.sv_maxusrcmdprocessticks
    local clock_correction = cvar.cl_clock_correction
    if backtrack and backtrack_bind then
        process_ticks:int(menu[mc[2]].backtrack_ticks:get(), true)
    else
        if menu[mc[2]].override_dt:get() then
            process_ticks:int(menu[mc[2]].dt_speed:get(), true)
        end
    end
    local dt_type =  menu[mc[2]].dt_type:get()
    cmd.force_defensive = dt_type ~= "Offensive"
    clock_correction:int(menu[mc[2]].clock_correction:get() and 1 or 0, true)
    if menu[mc[2]].forcebody:get() then
        forcebody()
    end
    if menu[mc[2]].extendedteleport:get() then
        if not doubletap then
            if globals.curtime - last_doubletap_charge < 0.2 then
                rage.exploit:force_teleport()
            end
        else
            last_doubletap_charge = globals.curtime
        end
    end
    if backtrack and backtrack_bind then
        local backtrack = false
        local backtrack_mode = menu[mc[2]].backtrack_lvl:get()
        if backtrack_mode == "Maximum" then
            backtrack = tickcount(2) == 1
        elseif backtrack_mode == "Medium" then
            backtrack = tickcount(4) >= 2
        elseif backtrack_mode == "Minimum" then
            backtrack = tickcount(8) >= 4
        end
        cmd.send_packet = backtrack
    end
    if backtrack then
        local backtrack_latency = menu[mc[2]].backtrack_latency:get()
        reference.fakelatency:override(backtrack_latency)
    end
    if menu[mc[1]].defensive_inair:get() then
        if antiaim_stats == "air" or antiaim_stats == "air-c" then
            reference.hideshot_option:set('break lc')
            reference.doubletap_limit:set(tickcount(4) >= 2 and 2 or 5)
        else
            reference.hideshot_option:set('favor fire rate')
            reference.doubletap_limit:set(1)
        end
    end
end

local ground_ticks, end_time = 1, 0
animation_breakers = function(localplayer, entity)
    if not localplayer:is_alive() then return end
    local self_index = localplayer:get_index()
    local self_address = get_entity_address(self_index)
    if not localplayer.m_flPoseParameter[0] and not self_address then return end
    local animbreaker = menu[mc[1]].animationbreaker
    local antiaim_stats = antiaim_stats()
    if animbreaker:get('Follow direction') and not animbreaker:get('Moonwalk') then
        localplayer.m_flPoseParameter[0] = 1
        reference.legmovement:set('Sliding')
    end
    if animbreaker:get('Static legs in air') and not animbreaker:get('Moonwalk in air') then
        localplayer.m_flPoseParameter[6] = 1
    end
    if animbreaker:get('Moonwalk') then
        if antiaim_stats == 'moving' then
            localplayer.m_flPoseParameter[7] = 0
            reference.legmovement:set('Walking')
        else
            localplayer.m_flPoseParameter[7] = localplayer.m_flPoseParameter[7]
        end    
    end
    if animbreaker:get('Moonwalk in air') then
        if antiaim_stats == 'air' or antiaim_stats == 'air-c' then
            get_anim_overlay(self_address, 6).m_flWeight = 1
        end
    end
    if animbreaker:get('Zero pitch on land') then
        local on_ground = bit.band(localplayer.m_fFlags, 1)
        if on_ground == 1 then
            ground_ticks = ground_ticks + 1
        else
            ground_ticks = 0
            end_time = globals.curtime + 1
        end 
        if ground_ticks > 1 and end_time > globals.curtime then
            localplayer.m_flPoseParameter[12] = 0.5 
        end
    end
end

esp.enemy:new_text("Lethal", "Lethal", function(player)
    if menu[mc[2]].forcebody:get() then
        if player:is_dormant() then return "" end
        local health = player.m_iHealth
        local forcebodyhp = menu[mc[2]].forcebody_hp:get()
        if forcebodyhp >= health then
            return "Lethal"
        end
    end
end)

general = function()
    local aspectratio = cvar.r_aspectratio
    if menu[mc[3]].clantag:get() then
        tag_animation()
    end
    if menu[mc[3]].aspectratio:get() then
        aspectratio:float(menu[mc[3]].aspectratio_val:get() / 10)
    else
        aspectratio:float(0)
    end
end

reset_menu()
events.createmove:set(function(cmd)
    if menu[mc[1]].enable:get() then
        local antiaim_stats = antiaim_stats()
        update_antiaim(cmd, antiaim_preset[antiaim_stats], antiaim_stats)
    end
    ragebot(cmd)
end)

events.render:set(function(ctx)
    if menu_is_open() then
        update_antiaim_menu()
    end
    general()
end)

local hooked_function = nil
local inside_updateCSA = function(thisptr, edx)
    local localplayer = entity.get_local_player()
    if not localplayer or not ffi.cast('uintptr_t**', thisptr) then return end
    hooked_function(thisptr, edx)
    animation_breakers(localplayer, thisptr)
end

events.createmove_run:set(function()
    local self = entity.get_local_player()
    if not self or not self:is_alive() then
        return
    end
    local self_index = self:get_index()
    local self_address = get_entity_address(self_index)
    if not self_address or hooked_function then
        return
    end
    local new_point = vmt_hook.new(self_address)
    hooked_function = new_point.hook("void(__fastcall*)(void*, void*)", inside_updateCSA, 224)
end)