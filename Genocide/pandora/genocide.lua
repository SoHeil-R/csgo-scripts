ffi.cdef[[
    typedef int(__thiscall* get_clipboard_text_length)(void*);
    typedef void(__thiscall* set_clipboard_text)(void*, const char*, int);
    typedef void(__thiscall* get_clipboard_text)(void*, int, const char*, int);
]]
local fs = (function()local a=client.create_interface("filesystem_stdio.dll","VBaseFileSystem011")local b=ffi.cast(ffi.typeof("void***"),a)local c=b[0]local d=ffi.cast("int (__thiscall*)(void*, void*, int, void*)",c[0])local e=ffi.cast("int (__thiscall*)(void*, void const*, int, void*)",c[1])local f=ffi.cast("void* (__thiscall*)(void*, const char*, const char*, const char*)",c[2])local g=ffi.cast("void (__thiscall*)(void*, void*)",c[3])local h=ffi.cast("unsigned int (__thiscall*)(void*, void*)",c[7])local i=ffi.cast("bool (__thiscall*)(void*, const char*, const char*)",c[10])local j=client.create_interface("filesystem_stdio.dll","VFileSystem017")local k=ffi.cast(ffi.typeof("void***"),j)local l=k[0]local m=ffi.cast("void (__thiscall*)(void*, const char*, const char*, int)",l[11])local n=ffi.cast("bool (__thiscall*)(void*, const char*, const char*)",l[12])local o=ffi.cast("void (__thiscall*)(void*, const char*, const char*)",l[20])local p=ffi.cast("bool (__thiscall*)(void*, const char*, const char*, const char*)",l[21])local q=ffi.cast("void (__thiscall*)(void*, const char*, const char*)",l[22])local r=ffi.cast("bool (__thiscall*)(void*, const char*, const char*)",l[23])local s=ffi.cast("const char* (__thiscall*)(void*, const char*, int*)",l[32])local t=ffi.cast("const char* (__thiscall*)(void*, int)",l[33])local u=ffi.cast("bool (__thiscall*)(void*, int)",l[34])local v=ffi.cast("void (__thiscall*)(void*, int)",l[35])local w={["r"]="r",["w"]="w",["a"]="a",["r+"]="r+",["w+"]="w+",["a+"]="a+",["rb"]="rb",["wb"]="wb",["ab"]="ab",["rb+"]="rb+",["wb+"]="wb+",["ab+"]="ab+"}local x={}x.__index=x;function x.exists(y,z)return i(b,y,z)end;function x.rename(A,B,z)p(k,A,B,z)end;function x.remove(y,z)o(k,y,z)end;function x.create_directory(C,z)q(k,C,z)end;function x.is_directory(C,z)return r(k,C,z)end;function x.find_first(C)local D=ffi.new("int[1]")local y=s(k,C,D)if y==ffi.NULL then return nil end;return D,ffi.string(y)end;function x.find_next(D)local y=t(k,D)if y==ffi.NULL then return nil end;return ffi.string(y)end;function x.find_is_directory(D)return u(k,D)end;function x.find_close(D)v(k,D)end;function x.add_search_path(C,z,E)m(k,C,z,E)end;function x.remove_search_path(C,z)n(k,C,z)end;function x.get_neverlose_path()return g_EngineClient:GetGameDirectory():sub(1,-5).."nl\\"end;function x.open(y,F,z)if not w[F]then error("Invalid mode!")end;local self=setmetatable({file=y,mode=F,path_id=z,handle=f(b,y,F,z)},x)return self end;function x:get_size()return h(b,self.handle)end;function x:write(G)e(b,G,#G,self.handle)end;function x:read()local H=self:get_size()local I=ffi.new("char[?]",H+1)d(b,I,H,self.handle)return ffi.string(I)end;function x:close()g(b,self.handle)end;return x end)()
local json = (function()local a={_version="0.1.2"}local b;local c={["\\"]="\\\\",["\""]="\\\"",["\b"]="\\b",["\f"]="\\f",["\n"]="\\n",["\r"]="\\r",["\t"]="\\t"}local d={["\\/"]="/"}for e,f in pairs(c)do d[f]=e end;local function g(h)return c[h]or string.format("\\u%04x",h:byte())end;local function i(j)return"null"end;local function k(j,l)local m={}l=l or{}if l[j]then error("circular reference")end;l[j]=true;if rawget(j,1)~=nil or next(j)==nil then local n=0;for e in pairs(j)do if type(e)~="number"then error("invalid table: mixed or invalid key types")end;n=n+1 end;if n~=#j then error("invalid table: sparse array")end;for o,f in ipairs(j)do table.insert(m,b(f,l))end;l[j]=nil;return"["..table.concat(m,",").."]"else for e,f in pairs(j)do if type(e)~="string"then error("invalid table: mixed or invalid key types")end;table.insert(m,b(e,l)..":"..b(f,l))end;l[j]=nil;return"{"..table.concat(m,",").."}"end end;local function p(j)return'"'..j:gsub('[%z\1-\31\\"]',g)..'"'end;local function q(j)if j~=j or j<=-math.huge or j>=math.huge then error("unexpected number value '"..tostring(j).."'")end;return string.format("%.14g",j)end;local r={["nil"]=i,["table"]=k,["string"]=p,["number"]=q,["boolean"]=tostring}b=function(j,l)local s=type(j)local t=r[s]if t then return t(j,l)end;error("unexpected type '"..s.."'")end;function a.encode(j)return b(j)end;local u;local function v(...)local m={}for o=1,select("#",...)do m[select(o,...)]=true end;return m end;local w=v(" ","\t","\r","\n")local x=v(" ","\t","\r","\n","]","}",",")local y=v("\\","/",'"',"b","f","n","r","t","u")local z=v("true","false","null")local A={["true"]=true,["false"]=false,["null"]=nil}local function B(C,D,E,F)for o=D,#C do if E[C:sub(o,o)]~=F then return o end end;return#C+1 end;local function G(C,D,H)local I=1;local J=1;for o=1,D-1 do J=J+1;if C:sub(o,o)=="\n"then I=I+1;J=1 end end;error(string.format("%s at line %d col %d",H,I,J))end;local function K(n)local t=math.floor;if n<=0x7f then return string.char(n)elseif n<=0x7ff then return string.char(t(n/64)+192,n%64+128)elseif n<=0xffff then return string.char(t(n/4096)+224,t(n%4096/64)+128,n%64+128)elseif n<=0x10ffff then return string.char(t(n/262144)+240,t(n%262144/4096)+128,t(n%4096/64)+128,n%64+128)end;error(string.format("invalid unicode codepoint '%x'",n))end;local function L(M)local N=tonumber(M:sub(3,6),16)local O=tonumber(M:sub(9,12),16)if O then return K((N-0xd800)*0x400+O-0xdc00+0x10000)else return K(N)end end;local function P(C,o)local Q=false;local R=false;local S=false;local T;for U=o+1,#C do local V=C:byte(U)if V<32 then G(C,U,"control character in string")end;if T==92 then if V==117 then local W=C:sub(U+1,U+5)if not W:find("%x%x%x%x")then G(C,U,"invalid unicode escape in string")end;if W:find("^[dD][89aAbB]")then R=true else Q=true end else local h=string.char(V)if not y[h]then G(C,U,"invalid escape char '"..h.."' in string")end;S=true end;T=nil elseif V==34 then local M=C:sub(o+1,U-1)if R then M=M:gsub("\\u[dD][89aAbB]..\\u....",L)end;if Q then M=M:gsub("\\u....",L)end;if S then M=M:gsub("\\.",d)end;return M,U+1 else T=V end end;G(C,o,"expected closing quote for string")end;local function X(C,o)local V=B(C,o,x)local M=C:sub(o,V-1)local n=tonumber(M)if not n then G(C,o,"invalid number '"..M.."'")end;return n,V end;local function Y(C,o)local V=B(C,o,x)local Z=C:sub(o,V-1)if not z[Z]then G(C,o,"invalid literal '"..Z.."'")end;return A[Z],V end;local function _(C,o)local m={}local n=1;o=o+1;while 1 do local V;o=B(C,o,w,true)if C:sub(o,o)=="]"then o=o+1;break end;V,o=u(C,o)m[n]=V;n=n+1;o=B(C,o,w,true)local a0=C:sub(o,o)o=o+1;if a0=="]"then break end;if a0~=","then G(C,o,"expected ']' or ','")end end;return m,o end;local function a1(C,o)local m={}o=o+1;while 1 do local a2,j;o=B(C,o,w,true)if C:sub(o,o)=="}"then o=o+1;break end;if C:sub(o,o)~='"'then G(C,o,"expected string for key")end;a2,o=u(C,o)o=B(C,o,w,true)if C:sub(o,o)~=":"then G(C,o,"expected ':' after key")end;o=B(C,o+1,w,true)j,o=u(C,o)m[a2]=j;o=B(C,o,w,true)local a0=C:sub(o,o)o=o+1;if a0=="}"then break end;if a0~=","then G(C,o,"expected '}' or ','")end end;return m,o end;local a3={['"']=P,["0"]=X,["1"]=X,["2"]=X,["3"]=X,["4"]=X,["5"]=X,["6"]=X,["7"]=X,["8"]=X,["9"]=X,["-"]=X,["t"]=Y,["f"]=Y,["n"]=Y,["["]=_,["{"]=a1}u=function(C,D)local a0=C:sub(D,D)local t=a3[a0]if t then return t(C,D)end;G(C,D,"unexpected character '"..a0 .."'")end;function a.decode(C)if type(C)~="string"then error("expected argument of type string, got "..type(C))end;local m,D=u(C,B(C,1,w,true))D=B(C,D,w,true)if D<=#C then G(C,D,"trailing garbage")end;return m end;return a end)()
local base64 = (function()local a,b,c=bit.lshift,bit.rshift,bit.band;local d,e,f,g,h,i,tostring,error,pairs=string.char,string.byte,string.gsub,string.sub,string.format,table.concat,tostring,error,pairs;local j=function(k,l,m)return c(b(k,l),a(1,m)-1)end;local function n(o)local p,q={},{}for r=1,65 do local s=e(g(o,r,r))or 32;if q[s]~=nil then error('invalid alphabet: duplicate character '..tostring(s),3)end;p[r-1]=s;q[s]=r-1 end;return p,q end;local t,u={},{}t['base64'],u['base64']=n('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=')t['base64url'],u['base64url']=n('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_')local v={__index=function(w,x)if type(x)=='string'and x:len()==64 or x:len()==65 then t[x],u[x]=n(x)return w[x]end end}setmetatable(t,v)setmetatable(u,v)local function y(z,p)p=t[p or'base64']or error('invalid alphabet specified',2)z=tostring(z)local A,B,C={},1,#z;local D=C%3;local E={}for r=1,C-D,3 do local F,G,H=e(z,r,r+2)local k=F*0x10000+G*0x100+H;local I=E[k]if not I then I=d(p[j(k,18,6)],p[j(k,12,6)],p[j(k,6,6)],p[j(k,0,6)])E[k]=I end;A[B]=I;B=B+1 end;if D==2 then local F,G=e(z,C-1,C)local k=F*0x10000+G*0x100;A[B]=d(p[j(k,18,6)],p[j(k,12,6)],p[j(k,6,6)],p[64])elseif D==1 then local k=e(z,C)*0x10000;A[B]=d(p[j(k,18,6)],p[j(k,12,6)],p[64],p[64])end;return i(A)end;local function J(K,q)q=u[q or'base64']or error('invalid alphabet specified',2)local L='[^%w%+%/%=]'if q then local M,N;for O,P in pairs(q)do if P==62 then M=O elseif P==63 then N=O end end;L=h('[^%%w%%%s%%%s%%=]',d(M),d(N))end;K=f(tostring(K),L,'')local E={}local A,B={},1;local C=#K;local Q=g(K,-2)=='=='and 2 or g(K,-1)=='='and 1 or 0;for r=1,Q>0 and C-4 or C,4 do local F,G,H,R=e(K,r,r+3)local S=F*0x1000000+G*0x10000+H*0x100+R;local I=E[S]if not I then local k=q[F]*0x40000+q[G]*0x1000+q[H]*0x40+q[R]I=d(j(k,16,8),j(k,8,8),j(k,0,8))E[S]=I end;A[B]=I;B=B+1 end;if Q==1 then local F,G,H=e(K,C-3,C-1)local k=q[F]*0x40000+q[G]*0x1000+q[H]*0x40;A[B]=d(j(k,16,8),j(k,8,8))elseif Q==2 then local F,G=e(K,C-3,C-2)local k=q[F]*0x40000+q[G]*0x1000;A[B]=d(j(k,16,8))end;return i(A)end;return{encode=y,decode=J}end)()
local clipboard = (function()local a=ffi.cast(ffi.typeof("void***"),client.create_interface("vgui2.dll","VGUI_System010"))local b=ffi.cast("get_clipboard_text_length",a[0][7])local c=ffi.cast("get_clipboard_text",a[0][11])local d=ffi.cast("set_clipboard_text",a[0][9])local e={}e.set=function(f)d(a,f,#f)end;e.get=function()local g=b(a)if g>0 then local h=ffi.new("char[?]",g)c(a,0,h,g*ffi.sizeof("char[?]",g))return ffi.string(h,g-1)end end;return e end)()
local reference = {
    target_per_tick = ui.get("Rage", "Aimbot", "General", "Targets per tick"),
    roll_resolver = ui.get("Rage", "Aimbot", "General", "Roll resolver"),
    antiaim = ui.get("Rage", "Anti-aim", "General", "Anti-aim"),
    pitch = ui.get("Rage", "Anti-aim", "General", "Pitch"),
    freestanding = ui.get("Rage", "Anti-aim", "General", "Freestanding key"),
    yaw_base = ui.get("Rage", "Anti-aim", "General", "Yaw base"),
    yaw = ui.get("Rage", "Anti-aim", "General", "Yaw"),
    yaw_additive = ui.get("Rage", "Anti-aim", "General", "Yaw additive"),
    yaw_jitter = ui.get("Rage", "Anti-aim", "General", "Yaw jitter"),
    fake_yaw_type = ui.get("Rage", "Anti-aim", "General", "Fake yaw type"),
    fake_yaw_onuse = ui.get("Rage", "Anti-aim", "General", "Fake yaw on use"),
    body_yaw_limit = ui.get("Rage", "Anti-aim", "General", "Body yaw limit"),
    inverter = ui.get("Rage", "Anti-aim", "General", "Anti-aim invert"),
    fake_yaw_direction = ui.get("Rage", "Anti-aim", "General", "Fake yaw direction"),
    fake_yaw_shot_direction = ui.get("Rage", "Anti-aim", "General", "Fake yaw shot direction"),
    body_roll = ui.get("Rage", "Anti-aim", "General", "Body roll"),
    body_roll_amount = ui.get("Rage", "Anti-aim", "General", "Body roll amount"),
    body_roll_key = ui.get("Rage", "Anti-aim", "General", "Body roll move key"),
    slowmotion = ui.get("Misc", "General", "Movement", "Slow motion key"),
    doubletap = ui.get("Rage", "Exploits", "General", "Double tap key"),
    hideshot = ui.get("Rage", "Exploits", "General", "Hide shots key"),
    exploitlag = ui.get("Rage", "Exploits", "General", "Exploit lag limit"),
    fakelag_amount = ui.get("Rage", "Anti-aim", "Fake-lag", "Fake lag amount"),
    fakeduck = ui.get("Rage", "Anti-aim", "Fake-lag", "Fake duck key"),
    forcebodyaim = ui.get_rage("Accuracy", "Force body-aim"),
    forcebodyaim_key = ui.get_rage("Accuracy", "Force body-aim key"),
}
local _print = print
print = function(...)
    _print(tostring(...))
end
local ticks = 0
function tickcount(value)
    return (ticks % value) + 1
end

function encode(value)
    return "GENOCIDE_PANDORA_"..base64.encode(value)
end

function decode(value)
    value = value:gsub("GENOCIDE_PANDORA_", "")
    return base64.decode(value)
end

function matchExist(table, value)
    for k,v in pairs(table) do
        if v == value then
            return true, k
        end
    end
    return false
end

local timeout_callbacks = {}
function timeout(time, callback)
    table.insert(timeout_callbacks, { time = time, real = global_vars.realtime, callback = callback})
end

function run_timeout()
    if #timeout_callbacks > 0 then
        for k,v in pairs(timeout_callbacks) do
            local live = global_vars.realtime
            if (live - v.real) >= v.time then
                v.callback()
                table.remove(timeout_callbacks, k)
            end
        end
    end
end

function world2scren(xdelta, ydelta)
    if xdelta == 0 and ydelta == 0 then
        return 0
    end
    return math.deg(math.atan2(ydelta, xdelta))
end

function normalize_yaw(yaw)
    while yaw > 180 do yaw = yaw - 360 end
    while yaw < -180 do yaw = yaw + 360 end
    return yaw
end

function getclosestpoint(A, B, P)
    a_to_p = { P[1] - A[1], P[2] - A[2] }
    a_to_b = { B[1] - A[1], B[2] - A[2] }
    atb2 = a_to_b[1]^2 + a_to_b[2]^2
    atp_dot_atb = a_to_p[1]*a_to_b[1] + a_to_p[2]*a_to_b[2]
    t = atp_dot_atb / atb2
    return { A[1] + a_to_b[1]*t, A[2] + a_to_b[2]*t }
end

function get_localplayer()
    return entity_list.get_client_entity(engine.get_local_player())
end

function entity:health()
    return self:get_prop("DT_BasePlayer", "m_iHealth"):get_int()
end

function entity:is_local()
    local local_player = get_localplayer()
    return self == local_player
end

function entity:alive()
    return self:health() > 0
end

function entity:team()
    return self:get_prop("DT_BaseEntity", "m_iTeamNum"):get_int()
end

function entity:teammate()
    local local_player = get_localplayer()
    return self:team() == local_player:team()
end

function get_enemies(fov)
    local enemies = {}
    local localplayer = get_localplayer()
    local localpostion = localplayer:origin()
    local viewangles = engine.get_view_angles()
    local players = entity_list.get_all("CCSPlayer")
    for i = 1, #players do
        local player = entity_list.get_client_entity(players[i])
        if player:alive() and not player:dormant() and not player:teammate() and not player:is_local() then
            local enemiespostion = player:origin()
            local enemyfov = math.abs(normalize_yaw(world2scren(localpostion['x'] - enemiespostion['x'], localpostion['y'] - enemiespostion['y']) - viewangles.y + 180))
            if fov >= enemyfov then
                table.insert(enemies, {players[i], player})
            end
        end
    end
    return enemies
end

local data = {
    active = "Default",
    list = {"Default"},
    autoload = false
}
local database_loc = "GENOCIDE\\pandora\\"

function savedata()
    local database = fs.open(database_loc.."database.gc", "wb+")
    database:write(encode(json.encode(data)))
    database:close()
end

function loaddata()
    local database = fs.open(database_loc.."database.gc", "rb+")
    data = json.decode(decode(database:read()))
    database:close()
    return data
end

fs.create_directory(database_loc)
if not fs.exists(database_loc.."database.gc") then
    local database = fs.open(database_loc.."database.gc", "wb+")
    database:write(encode(json.encode(data)))
    database:close()
else
    loaddata()
end

local mc = {"Anti-Aim", "Custom Anti-aim", "Ragebot", "Visual", "Misc", "Config"}
local antiaim_stats = {"global", "standing", "moving", "air", "air-crouch", "crouching", "slowwalk", "on key"}
local categorys = ui.add_dropdown("             G E N O C I D E", mc)
local antiaim_preset = {}
local menu = {
    [mc[1]] = {
        freestanding = ui.add_checkbox("Freestanding"),
        freestanding_key = ui.add_cog("Freestanding key", false, true),
        freestanding_disabler = ui.add_multi_dropdown("Disabler", {"While inair", "While crouching", "While slowwalk", "While fakeduck"}),
        breaklc = ui.add_checkbox("Break LC in air"),
        jitter_fakelag = ui.add_checkbox("Jitter fake lag"),
        fakelag_delay = ui.add_slider("Jitter delay", 4, 30),
        fakelag_count = ui.add_slider("Fake lag limit", 2, 14),
    },
    [mc[2]] = {
        enable = ui.add_checkbox("Enable Anti-aim"),
        stats = ui.add_dropdown("Stats", antiaim_stats),
        builder = {}
    },
    [mc[3]] = {
        roll_resolver = ui.add_checkbox("Roll resolver"),
        roll_resolver_key = ui.add_cog("Roll resolver key", false, true),
        forcebody = ui.add_checkbox("Force body aim lethal"),
        lethalhp = ui.add_slider("Lethal HP", 1, 100),
        idealtick = ui.add_checkbox("Idealtick"),
        idealtick_key = ui.add_cog("Idealtick key", false, true),
        idealtick_df = ui.add_slider("Default tick", 1, 10),
        idealtick_tk = ui.add_slider("Ideal per tick", 1, 10),
        clock_correction = ui.add_checkbox("Clock correction"),
        doubletap_speed = ui.add_slider("Doubletap speed", 15, 20),        
    },
    [mc[4]] = {},
    [mc[5]] = {},
    [mc[6]] = {
        configlist = ui.add_dropdown("Config list", data.list),
        configname = ui.add_textbox("Config Name"),
        save = ui.add_button("Save"),
        load = ui.add_button("Load"),
        delete = ui.add_button("Delete"),
        export = ui.add_button("Export config"),
        import = ui.add_button("Import config"),
        autoload = ui.add_checkbox("Autoload")
    }
}

menu[mc[3]].doubletap_speed:set(16)
menu[mc[3]].clock_correction:set(true)

menu[mc[6]].save:add_callback(function()
    local configlist = menu[mc[6]].configlist
    local configname = menu[mc[6]].configname:get()
    data.autoload = menu[mc[6]].autoload:get()
    if #configname > 0 then
        if not matchExist(data.list, configname) then
            table.insert(data.list, configname)
            configlist:update_items(data.list)
            configlist:set(#data.list - 1)
            local database = fs.open(string.format("%s%s.gc", database_loc, configname), "wb+")
            database:write(encode(json.encode(save_config())))
            database:close()
        else
            local config = menu[mc[6]].configlist:get() + 1
            configname = data.list[tonumber(config)]
            local database = fs.open(string.format("%s%s.gc", database_loc, configname), "wb+")
            database:write(encode(json.encode(save_config())))
            database:close()
        end
    else
        local config = menu[mc[6]].configlist:get() + 1
        configname = data.list[tonumber(config)]
        local database = fs.open(string.format("%s%s.gc", database_loc, configname), "wb+")
        database:write(encode(json.encode(save_config())))
        database:close()
    end
    savedata()
    client.log(string.format("Config %s successfully saved!", configname), color.new(255, 255, 255), "GENOCIDE", true)
end)

menu[mc[6]].load:add_callback(function()
    local config = menu[mc[6]].configlist:get() + 1
    local configname = data.list[tonumber(config)]
    local database = fs.open(string.format("%s%s.gc", database_loc, configname), "rb+")
    local configdata = json.decode(decode(database:read()))
    database:close()
    if #configdata < 20 then
        data.active = configname
        data.autoload = menu[mc[6]].autoload:get()
        savedata()
        load_config(configdata)
        client.log(string.format("Config %s successfully loaded!", configname), color.new(255, 255, 255), "GENOCIDE", true)
    else
        client.log("Failed to load config!", color.new(255, 255, 255), "GENOCIDE", true)
    end
end)

menu[mc[6]].delete:add_callback(function()
    local config = menu[mc[6]].configlist:get() + 1
    if config > 1 then
        local configname = data.list[tonumber(config)]
        table.remove(data.list, config)
        menu[mc[6]].configlist:update_items(data.list)
        fs.remove(string.format("%s%s.gc", database_loc, configname), "GAME")
        savedata()
        client.log(string.format("Config %s successfully deleted!", configname), color.new(255, 255, 255), "GENOCIDE", true)
    else
        client.log("You cant delete all configs!", color.new(255, 255, 255), "GENOCIDE", true)
    end
end)

menu[mc[6]].export:add_callback(function()
    local config = menu[mc[6]].configlist:get() + 1
    local configname = data.list[tonumber(config)]
    local database = fs.open(string.format("%s%s.gc", database_loc, configname), "rb+")
    local sconfig = database:read()
    database:close()
    clipboard.set(sconfig)
    client.log(string.format("Config %s successfully exported!", configname), color.new(255, 255, 255), "GENOCIDE", true)
end)

menu[mc[6]].import:add_callback(function()
    local config = menu[mc[6]].configlist:get() + 1
    local configname = data.list[tonumber(config)]
    local gconfig = clipboard.get()
    if #gconfig > 20 then
        local configdata = json.decode(decode(gconfig))
        load_config(configdata)
        client.log(string.format("Config %s successfully imported!", configname), color.new(255, 255, 255), "GENOCIDE", true)
    else
        client.log("Failed to import config!", color.new(255, 255, 255), "GENOCIDE", true)
    end
end)

if data.autoload then
    menu[mc[6]].autoload:set(true)
    timeout(2, function() 
        local configname = data.active
        local database = fs.open(string.format("%s%s.gc", database_loc, configname), "rb+")
        local configdata = json.decode(decode(database:read()))
        database:close()
        load_config(configdata)
        client.log(string.format("Config %s successfully loaded!", configname), color.new(255, 255, 255), "GENOCIDE", true)
    end)
end

for k,v in pairs(antiaim_stats) do
    antiaim_preset[v] = {} 
    menu[mc[2]].builder[v] = {}
    local stats = menu[mc[2]].builder[v]
    if v ~= "global" then
        stats.enable = ui.add_checkbox("["..v.."] Enable")
    end
    if v == "on key" then
        stats.hotkeylabel = ui.add_label("Hotkey")
        stats.hotkey = ui.add_cog("Hotkey", false, true)
    end
    stats.pitch = ui.add_dropdown("["..v.."] Pitch", {"Disabled", "Down", "Up", "Zero"})
    stats.yaw_base = ui.add_dropdown("["..v.."] Yaw base", {"Local view", "At crosshair", "At distance"})
    stats.yaw = ui.add_dropdown("["..v.."] Yaw", {"Disabled", "Backward", "Static"})
    stats.yaw_add = ui.add_slider("["..v.."] Yaw add", -180, 180)
    stats.yaw_add:set(0)
    stats.yaw_modifier = ui.add_dropdown("["..v.."] Yaw modifier", {"Disabled", "Offset", "Center"})
    stats.yaw_offset = ui.add_slider("["..v.."] Offset", -180, 180)
    stats.yaw_offset:set(0)
    stats.yaw_offset_delay = ui.add_slider("["..v.."] Offset Delay", 4, 60)
    stats.inverter = ui.add_checkbox("["..v.."] Inverter")
    stats.leftlimit = ui.add_slider("["..v.."] Left limit", 1, 60)
    stats.leftlimit:set(60)
    stats.rightlimit = ui.add_slider("["..v.."] Right limit", 1, 60)
    stats.rightlimit:set(60)
    stats.fakeoption = ui.add_dropdown("["..v.."] Fake Option", {"Eye yaw", "Jitter", "Anti bruteforce"})
    stats.jitter_delay = ui.add_slider("["..v.."] Jitter Delay", 4, 60)
    stats.freestanding = ui.add_dropdown("["..v.."] Freestanding", {"Default", "Peek real", "Peek fake"})
    stats.onshot = ui.add_dropdown("["..v.."] On shot", {"Default", "Left", "Right", "Opposite"})
    stats.roll = ui.add_dropdown("["..v.."] Roll", {"Disbaled", "Static", "Jitter", "Sway", "Opposite"})
    stats.rollamount = ui.add_slider("["..v.."] Roll amount", -50, 50)
    stats.rollamount:set(0)

end

function menu_update()
    local category = categorys:get() + 1
    if mc[category] == mc[2] then
        local stats = menu[mc[2]].stats:get() + 1
        local antiaim_enable = menu[mc[2]].enable:get()
        stats = antiaim_stats[stats]
        for k,v in pairs(antiaim_stats) do
            if antiaim_enable then
                menu[mc[2]].stats:set_visible(true)
                for x, z in pairs(menu[mc[2]].builder[v]) do
                    local stats = stats == v
                    if v ~= "global" then
                        menu[mc[2]].builder[v].enable:set_visible(stats)
                        local enable = menu[mc[2]].builder[v].enable:get()
                        stats = stats and enable
                    end
                    z:set_visible(stats)
                end
                local stats = stats == v
                local yaw = menu[mc[2]].builder[v].yaw:get()
                local yaw_modifier = menu[mc[2]].builder[v].yaw_modifier:get()
                menu[mc[2]].builder[v].yaw_add:set_visible(stats and yaw ~= 0 and yaw_modifier == 0)
                menu[mc[2]].builder[v].yaw_offset:set_visible(stats and yaw_modifier ~= 0)
                menu[mc[2]].builder[v].yaw_offset_delay:set_visible(stats and yaw_modifier ~= 0)
                local fakeoption = menu[mc[2]].builder[v].fakeoption:get()
                menu[mc[2]].builder[v].jitter_delay:set_visible(stats and fakeoption == 1)
                local roll = menu[mc[2]].builder[v].roll:get()
                menu[mc[2]].builder[v].rollamount:set_visible(stats and roll ~= 0)

            else
                menu[mc[2]].stats:set_visible(false)
                for z,x in pairs(menu[mc[2]].builder[v]) do
                    x:set_visible(false)
                end
            end
        end
    end
    local freestanding = menu[mc[1]].freestanding:get()
    menu[mc[1]].freestanding_disabler:set_visible(mc[category] == mc[1] and freestanding)
    local fakelag = menu[mc[1]].jitter_fakelag:get()
    menu[mc[1]].fakelag_delay:set_visible(mc[category] == mc[1] and fakelag)
    menu[mc[1]].fakelag_count:set_visible(mc[category] == mc[1] and fakelag)
    local idealtick = menu[mc[3]].idealtick:get()
    menu[mc[3]].idealtick_df:set_visible(mc[category] == mc[3] and idealtick)
    menu[mc[3]].idealtick_tk:set_visible(mc[category] == mc[3] and idealtick)
    local forcebody = menu[mc[3]].forcebody:get()
    menu[mc[3]].lethalhp:set_visible(mc[category] == mc[3] and forcebody)
end

local lastcategory
function category_update()
    local category = categorys:get() + 1
    if mc[category] ~= lastcategory then
        lastcategory = mc[category]
        for k,v in pairs(mc) do
            for z,x in pairs(menu[v]) do
                if type(x) ~= "table" then
                    x:set_visible(mc[category] == v)
                else
                    for c,v in pairs(x) do
                        for a,s in pairs(v) do
                            s:set_visible(mc[category] == v)
                        end
                    end
                end
            end
        end
    end
end

function get_preset()
    for k,v in pairs(antiaim_stats) do
        for z,x in pairs(menu[mc[2]].builder[v]) do
            if z ~= "hotkeylabel" and z ~= "hotkey" then
                antiaim_preset[v][z] = x:get()
            end
        end
    end
end

function save_config()
    local saved = {}
    for k,v in pairs(menu) do
        if k ~= "Config" then
            saved[k] = {}
            for z,x in pairs(v) do
                if type(x) ~= "table" then
                    if z ~= "idealtick_key" and z ~= "freestanding_key" and z ~= "freestanding_disabler" and z ~= "roll_resolver_key" then
                        saved[k][z] = x:get()
                    end
                else
                    saved[k][z] = {}
                    for q,w in pairs(x) do
                        saved[k][z][q] = {}
                        for a,s in pairs(w) do
                            if a ~= "hotkeylabel" and a ~= "hotkey" then
                                saved[k][z][q][a] = s:get()
                            end
                        end
                    end
                end
            end
        end
    end
    return saved
end

function load_config(config)
    for k,v in pairs(config) do
        for z,x in pairs(v) do
            if type(x) ~= "table" then
                menu[k][z]:set(x)
            else
                for q,w in pairs(x) do
                    for a,s in pairs(w) do
                        menu[k][z][q][a]:set(s)
                    end
                end
            end
        end
    end
end

function get_velocity(localplayer)
    local velocity_x = localplayer:get_prop("DT_BasePlayer", "m_vecVelocity[0]"):get_float()
    local velocity_y = localplayer:get_prop("DT_BasePlayer", "m_vecVelocity[1]"):get_float()
    return math.floor(math.sqrt(velocity_x * velocity_x + velocity_y * velocity_y))
end

function get_stats(cmd)
    local localplayer = get_localplayer()
    local velocity = get_velocity(localplayer)
    local inair = localplayer:get_prop("DT_BasePlayer", "m_hGroundEntity"):get_int() == -1
    local inair_key = input.key_down(0x20)
    local induck = cmd:has_flag(4)
    local slowwalk = reference.slowmotion:get_key()
    local onkey = menu[mc[2]].builder['on key'].hotkey:get_key()
    if onkey then return "on key" end
    if slowwalk then return "slowwalk" end
    if (inair or inair_key) and induck then return "air-crouch" end
    if (inair or inair_key) then return "air" end
    if induck then return "crouching" end
    if velocity > 2 then
        return "moving"
    else
        return "standing"
    end
end

function freestanding(stats)
    local disabled = false 
    local fs = menu[mc[1]].freestanding:get()
    local fs_key = menu[mc[1]].freestanding_key:get_key()
    local fs_disabler = menu[mc[1]].freestanding_disabler
    if fs and fs_key then
        if fs_disabler:get("While inair") then
            if stats == "air" or stats == "air-crouch" then
                disabled = true
            end
        end
        if fs_disabler:get("While crouching") then
            if stats == "crouching" then
                disabled = true
            end
        end
        if fs_disabler:get("While slowwalk") then
            if stats == "slowwalk" then
                disabled = true
            end
        end
        if fs_disabler:get("While fakeduck") then
            if reference.fakeduck:get_key() then
                disabled = true
            end
        end
        if not disabled then
            reference.freestanding:set_key(true)
            reference.fake_yaw_type:set(1)
        end
    end
    return (fs and fs_key) and not disabled
end

local bruteforce = {
    active = false,
    brute = false,
    timer = 5,
    lastmiss = 0,
    lastshot = 0,
    shotnumber = 0,
    inverted = false,
}

function resetbrute()
    bruteforce = {
        active = false,
        brute = false,
        timer = 5,
        lastmiss = 0,
        lastshot = 0,
        shotnumber = 0,
        inverted = false,
    }
    client.log("Bruteforce reset data", color.new(255, 255, 255), "GENOCIDE", true)
end

function update_antiaim(cmd, preset, stats)
    if preset then
        if preset.pitch and not freestanding(stats) then
            local is_enable = menu[mc[2]].builder[stats].enable:get()
            preset = is_enable and preset or antiaim_preset['global']
            reference.antiaim:set(true)
            reference.yaw_jitter:set(false)
            reference.fake_yaw_onuse:set(true)
            reference.freestanding:set_key(false)
            reference.pitch:set(preset.pitch)
            reference.yaw_base:set(preset.yaw_base)
            reference.yaw:set(preset.yaw)
            if preset.yaw_modifier == 0 then
                reference.yaw_additive:set(preset.yaw_add)
            elseif preset.yaw_modifier == 1 then
                if bruteforce.active then
                    if bruteforce.inverted then
                        reference.yaw_additive:set(tickcount(preset.yaw_offset_delay) > preset.yaw_offset_delay / 2 and 0 or -preset.yaw_offset)
                    else
                        reference.yaw_additive:set(tickcount(preset.yaw_offset_delay) > preset.yaw_offset_delay / 2 and 0 or preset.yaw_offset)
                    end
                else
                    reference.yaw_additive:set(tickcount(preset.yaw_offset_delay) > preset.yaw_offset_delay / 2 and 0 or preset.yaw_offset)
                end
            elseif preset.yaw_modifier == 2 then
                if bruteforce.active then
                    if bruteforce.inverted then
                        reference.yaw_additive:set(tickcount(preset.yaw_offset_delay) > preset.yaw_offset_delay / 2 and preset.yaw_offset or -preset.yaw_offset)
                    else
                        reference.yaw_additive:set(tickcount(preset.yaw_offset_delay) > preset.yaw_offset_delay / 2 and -preset.yaw_offset or preset.yaw_offset)
                    end
                else
                    reference.yaw_additive:set(tickcount(preset.yaw_offset_delay) > preset.yaw_offset_delay / 2 and -preset.yaw_offset or preset.yaw_offset)
                end
            end
            reference.body_yaw_limit:set(anti_aim.inverted() and preset.rightlimit or preset.leftlimit)
            reference.inverter:set_key_cond(0)
            if preset.fakeoption == 0 then
                bruteforce.brute = false
                reference.fake_yaw_type:set(preset.fakeoption)
                reference.inverter:set_key(preset.inverter)
            elseif preset.fakeoption == 1 then
                bruteforce.brute = false
                reference.inverter:set_key(tickcount(preset.jitter_delay) > preset.jitter_delay / 2)
            elseif preset.fakeoption == 2 then
                reference.fake_yaw_type:set(0)
                bruteforce.brute = true
                if bruteforce.active then
                    if bruteforce.shotnumber ~= bruteforce.lastmiss then
                        bruteforce.lastmiss = bruteforce.shotnumber
                        if bruteforce.inverted then bruteforce.inverted = false else bruteforce.inverted = true end
                    end
                    reference.inverter:set_key(bruteforce.inverted)
                    if global_vars.realtime - bruteforce.lastshot >= bruteforce.timer then
                        resetbrute()
                    end
                else
                    bruteforce.inverted = preset.inverter
                    reference.inverter:set_key(preset.inverter)
                end
            end
            reference.fake_yaw_direction:set(preset.freestanding)
            reference.fake_yaw_shot_direction:set(preset.onshot)
            reference.body_roll:set(preset.roll)
            reference.body_roll_amount:set(preset.rollamount)
            reference.body_roll_key:set_key(true)
            if menu[mc[1]].breaklc:get() then
                if stats == "air" or stats == "air-crouch" then
                    reference.exploitlag:set(tickcount(8) > 4 and 4 or 1)
                else
                    reference.exploitlag:set(2)
                end
            end
        end
    end
end

local deactive_dt = false
function idealtick()
    local idealtick_key = menu[mc[3]].idealtick_key:get_key()
    local ideal_tick = menu[mc[3]].idealtick_tk:get()
    local default_tick = menu[mc[3]].idealtick_df:get()
    if idealtick_key then
        if not reference.doubletap:get_key() then
            deactive_dt = true
            reference.doubletap:set_key(true)
            reference.target_per_tick:set(ideal_tick)
        end
    else
        if deactive_dt then
            deactive_dt = false
            reference.doubletap:set_key(false)
        end
        reference.target_per_tick:set(default_tick)
    end
end

function forcebody()
    local lethalhp = menu[mc[3]].lethalhp:get()
    reference.forcebodyaim:set(true)
    for k,v in pairs(get_enemies(100)) do
        if v[2]:health() <= lethalhp then
            reference.forcebodyaim_key:set_key(true)
            esp.add_player_flag("LEATHAL", color.new(255, 0, 0), v[1])
        else
            reference.forcebodyaim_key:set_key(false)
        end
    end
end

local resolverlist = {}
local cooldown = false
function roll_resolver()
    reference.roll_resolver:set_key_cond(0)
    menu[mc[3]].roll_resolver_key:set_key_cond(0)
    local resolver_key = menu[mc[3]].roll_resolver_key:get_key()
    if resolver_key then
        if not cooldown then
            cooldown = true
            local get_target = get_enemies(5)
            if #get_target > 0 then
                local target_index = get_target[1][2]:index()
                local target_info = engine.get_player_info(target_index)
                if not resolverlist[target_index] then
                    resolverlist[target_index] = {index = target_index, entityindex = get_target[1][1]}
                    client.log(string.format("%s added to roll resolver!", target_info.name), color.new(255, 255, 255), "GENOCIDE", true)
                else
                    resolverlist[target_index] = nil
                    client.log(string.format("%s remove from roll resolver!", target_info.name), color.new(255, 255, 255), "GENOCIDE", true)
                end
            end
        end
    else
        cooldown = false
    end
    for k,v in pairs(get_enemies(50)) do
        local index = v[2]:index()
        if resolverlist[index] then
            reference.roll_resolver:set_key(true)
            esp.add_player_flag("ROLL RESOLVER", color.new(38, 103, 255), v[1])
        else
            reference.roll_resolver:set_key(false)
        end
    end
end

function antibruteforce(event)
    if not bruteforce.brute then return end 
    local localplayer = get_localplayer()
    if not localplayer:alive() then return end
    local target_id = event:get_int("userid")
    local target = entity_list.get_client_entity(engine.get_player_for_user_id(target_id))
    if target:is_local() then return end
    if target:teammate() then return end
    if target:dormant() then return end
    local x, y, z = event:get_int("x"), event:get_int("y"), event:get_int("z")
    local selfhead = localplayer:hitbox_position(0)
    local targetorigin = target:origin()
    local closestpoint = getclosestpoint({targetorigin.x, targetorigin.y, targetorigin.z}, {x, y, z}, {selfhead.x, selfhead.y, selfhead.z})
    local delta = {selfhead.x - closestpoint[1], selfhead.y - closestpoint[2]}
    local distance = math.abs(math.sqrt(delta[1] ^2 + delta[2] ^ 2))
    if distance <= 75 and (global_vars.realtime - bruteforce.lastshot) > 0.2 then
        bruteforce.active = true
        bruteforce.shotnumber = bruteforce.shotnumber + 1
        bruteforce.lastshot = global_vars.realtime
        client.log("Anti bruteforce due to shot", color.new(255, 255, 255), "GENOCIDE", true)
    end
end

function ragebot()
    local processtick = cvar.find_var("sv_maxusrcmdprocessticks")
    local clock_correction = cvar.find_var("cl_clock_correction")
    local dt_speed = menu[mc[3]].doubletap_speed:get()
    local clockcorrection = menu[mc[3]].clock_correction:get()
    processtick:set_value_int(dt_speed)
    clock_correction:set_value_int(clockcorrection and 1 or 0)
    local is_idealtick = menu[mc[3]].idealtick:get()
    if is_idealtick then
        idealtick()
    end
end

callbacks.register("post_move", function(cmd)
    if menu[mc[2]].enable:get() then
        local stats = get_stats(cmd)
        update_antiaim(cmd, antiaim_preset[stats], stats)
        local jitter_fakelag = menu[mc[1]].jitter_fakelag:get()
        if jitter_fakelag then
            local count = menu[mc[1]].fakelag_count:get()
            local delay = menu[mc[1]].fakelag_delay:get()
            reference.fakelag_amount:set(tickcount(delay) > delay / 2 and 1 or count)
        end
    end
    ragebot()
    ticks = ticks + 1
end)

callbacks.register("paint", function()
    if ui.is_open() then
        get_preset()
        category_update()
        menu_update()
    end
    local forcebodylethal = menu[mc[3]].forcebody:get()
    if forcebodylethal then
        forcebody()
    else
        reference.forcebodyaim:set(false)
    end
    local rollresolver = menu[mc[3]].roll_resolver:get()
    if rollresolver then
        roll_resolver()
    end
    run_timeout()
end)

callbacks.register("bullet_impact", function(e)
    antibruteforce(e)
end)

callbacks.register("client_disconnect", function()
    resolverlist = {}
    if bruteforce.active then
        resetbrute()
    end
end)

callbacks.register("game_newmap", function()
    resolverlist = {}
    if bruteforce.active then
        resetbrute()
    end
end)

callbacks.register("cs_game_disconnected", function()
    resolverlist = {}
    if bruteforce.active then
        resetbrute()
    end
end)
