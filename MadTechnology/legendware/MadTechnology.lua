local ffi = MT.require("ffi")
local MT = {
    refrence = {},
    bit = bit,
    menu = menu,
    http = http,
    color = color,
    utils = utils,
    events = events,
    render = render,
    vector = vector,
    client = client,
    engine = engine,
    globals = globals,
    entitylist = entitylist,
    console = console,
    unpack = unpack,
    require = require,
}
local username = MT.globals.get_username()

ffi.cdef[[
    short GetAsyncKeyState(int vKey);
    typedef struct
    {
        float x,y,z;
    }Vector_t;
    typedef uintptr_t (__thiscall* GetClientEntity_4242425_t)(void*, int);
]]

ffi.cdef[[ struct c_color { unsigned char clr[4]; }; ]]
local console_color = ffi.new("struct c_color")
console_color.clr[3] = 255

function MT.IsButtonDown(key)
    if ffi.C.GetAsyncKeyState(key) ~= 0 then
        return true
    else
        return false
    end
end

local _print = print
function print(...)
    _print(tostring(...))
end

function MT.httpImage(host, link)
    local data = MT.http.get( host, link )
    return MT.render.create_image( data )
end

local IClientEntityList = ffi.cast(ffi.typeof("void***"), MT.utils.create_interface("client.dll", "VClientEntityList003"))
local GetHighestEntityIndex = ffi.cast(ffi.typeof("int(__thiscall*)(void*)"), IClientEntityList[0][6])
local entity_list_ptr = ffi.cast("void***", MT.utils.create_interface("client.dll", "VClientEntityList003"))
local get_client_entity_fn = ffi.cast("GetClientEntity_4242425_t", entity_list_ptr[0][3])
local set_clantag = ffi.cast('int(__fastcall*)(const char*, const char*)', MT.utils.find_signature("engine.dll", "53 56 57 8B DA 8B F9 FF 15"))
local last_clantag = nil

function MT.set_clantag(v)
    if v == last_clantag then return end
    set_clantag(v, v)
    last_clantag = v
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

local clantag = MT['build_tag']('MadTechnology ')

local ffi_helpers = {
    get_entity_address = function(ent_index)
        local addr = get_client_entity_fn(entity_list_ptr, ent_index)
        return addr
    end,
}

MT.json = (function()local a={_version="0.1.2"}local b;local c={["\\"]="\\\\",["\""]="\\\"",["\b"]="\\b",["\f"]="\\f",["\n"]="\\n",["\r"]="\\r",["\t"]="\\t"}local d={["\\/"]="/"}for e,f in pairs(c)do d[f]=e end;local function g(h)return c[h]or string.format("\\u%04x",h:byte())end;local function i(j)return"null"end;local function k(j,l)local m={}l=l or{}if l[j]then error("circular reference")end;l[j]=true;if rawget(j,1)~=nil or next(j)==nil then local n=0;for e in pairs(j)do if type(e)~="number"then error("invalid table: mixed or invalid key types")end;n=n+1 end;if n~=#j then error("invalid table: sparse array")end;for o,f in ipairs(j)do table.insert(m,b(f,l))end;l[j]=nil;return"["..table.concat(m,",").."]"else for e,f in pairs(j)do if type(e)~="string"then error("invalid table: mixed or invalid key types")end;table.insert(m,b(e,l)..":"..b(f,l))end;l[j]=nil;return"{"..table.concat(m,",").."}"end end;local function p(j)return'"'..j:gsub('[%z\1-\31\\"]',g)..'"'end;local function q(j)if j~=j or j<=-math.huge or j>=math.huge then error("unexpected number value '"..tostring(j).."'")end;return string.format("%.14g",j)end;local r={["nil"]=i,["table"]=k,["string"]=p,["number"]=q,["boolean"]=tostring}b=function(j,l)local s=type(j)local t=r[s]if t then return t(j,l)end;error("unexpected type '"..s.."'")end;function a.encode(j)return b(j)end;local u;local function v(...)local m={}for o=1,select("#",...)do m[select(o,...)]=true end;return m end;local w=v(" ","\t","\r","\n")local x=v(" ","\t","\r","\n","]","}",",")local y=v("\\","/",'"',"b","f","n","r","t","u")local z=v("true","false","null")local A={["true"]=true,["false"]=false,["null"]=nil}local function B(C,D,E,F)for o=D,#C do if E[C:sub(o,o)]~=F then return o end end;return#C+1 end;local function G(C,D,H)local I=1;local J=1;for o=1,D-1 do J=J+1;if C:sub(o,o)=="\n"then I=I+1;J=1 end end;error(string.format("%s at line %d col %d",H,I,J))end;local function K(n)local t=math.floor;if n<=0x7f then return string.char(n)elseif n<=0x7ff then return string.char(t(n/64)+192,n%64+128)elseif n<=0xffff then return string.char(t(n/4096)+224,t(n%4096/64)+128,n%64+128)elseif n<=0x10ffff then return string.char(t(n/262144)+240,t(n%262144/4096)+128,t(n%4096/64)+128,n%64+128)end;error(string.format("invalid unicode codepoint '%x'",n))end;local function L(M)local N=tonumber(M:sub(3,6),16)local O=tonumber(M:sub(9,12),16)if O then return K((N-0xd800)*0x400+O-0xdc00+0x10000)else return K(N)end end;local function P(C,o)local Q=false;local R=false;local S=false;local T;for U=o+1,#C do local V=C:byte(U)if V<32 then G(C,U,"control character in string")end;if T==92 then if V==117 then local W=C:sub(U+1,U+5)if not W:find("%x%x%x%x")then G(C,U,"invalid unicode escape in string")end;if W:find("^[dD][89aAbB]")then R=true else Q=true end else local h=string.char(V)if not y[h]then G(C,U,"invalid escape char '"..h.."' in string")end;S=true end;T=nil elseif V==34 then local M=C:sub(o+1,U-1)if R then M=M:gsub("\\u[dD][89aAbB]..\\u....",L)end;if Q then M=M:gsub("\\u....",L)end;if S then M=M:gsub("\\.",d)end;return M,U+1 else T=V end end;G(C,o,"expected closing quote for string")end;local function X(C,o)local V=B(C,o,x)local M=C:sub(o,V-1)local n=tonumber(M)if not n then G(C,o,"invalid number '"..M.."'")end;return n,V end;local function Y(C,o)local V=B(C,o,x)local Z=C:sub(o,V-1)if not z[Z]then G(C,o,"invalid literal '"..Z.."'")end;return A[Z],V end;local function _(C,o)local m={}local n=1;o=o+1;while 1 do local V;o=B(C,o,w,true)if C:sub(o,o)=="]"then o=o+1;break end;V,o=u(C,o)m[n]=V;n=n+1;o=B(C,o,w,true)local a0=C:sub(o,o)o=o+1;if a0=="]"then break end;if a0~=","then G(C,o,"expected ']' or ','")end end;return m,o end;local function a1(C,o)local m={}o=o+1;while 1 do local a2,j;o=B(C,o,w,true)if C:sub(o,o)=="}"then o=o+1;break end;if C:sub(o,o)~='"'then G(C,o,"expected string for key")end;a2,o=u(C,o)o=B(C,o,w,true)if C:sub(o,o)~=":"then G(C,o,"expected ':' after key")end;o=B(C,o+1,w,true)j,o=u(C,o)m[a2]=j;o=B(C,o,w,true)local a0=C:sub(o,o)o=o+1;if a0=="}"then break end;if a0~=","then G(C,o,"expected '}' or ','")end end;return m,o end;local a3={['"']=P,["0"]=X,["1"]=X,["2"]=X,["3"]=X,["4"]=X,["5"]=X,["6"]=X,["7"]=X,["8"]=X,["9"]=X,["-"]=X,["t"]=Y,["f"]=Y,["n"]=Y,["["]=_,["{"]=a1}u=function(C,D)local a0=C:sub(D,D)local t=a3[a0]if t then return t(C,D)end;G(C,D,"unexpected character '"..a0 .."'")end;function a.decode(C)if type(C)~="string"then error("expected argument of type string, got "..type(C))end;local m,D=u(C,B(C,1,w,true))D=B(C,D,w,true)if D<=#C then G(C,D,"trailing garbage")end;return m end;return a end)()
MT.base64 = (function()local a={}local b=_G.bit32 and _G.bit32.extract;if not b then if _G.bit then local c,d,e=_G.bit.lshift,_G.bit.rshift,_G.bit.band;b=function(f,g,h)return e(d(f,g),c(1,h)-1)end elseif _G._VERSION=="Lua 5.1"then b=function(f,g,h)local i=0;local j=2^g;for k=0,h-1 do local l=j+j;if f%l>=j then i=i+2^k end;j=l end;return i end else b=load[[return function( v, from, width )
    return ( v >> from ) & ((1 << width) - 1)
end]]()end end;function a.makeencoder(m,n,o)local p={}for q,r in pairs{[0]='A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9',m or'+',n or'/',o or'='}do p[q]=r:byte()end;return p end;function a.makedecoder(m,n,o)local s={}for q,t in pairs(a.makeencoder(m,n,o))do s[t]=q end;return s end;local u=a.makeencoder()local v=a.makedecoder()local r,w=string.char,table.concat;function a.encode(x,p,y)p=p or u;local z,A,B={},1,#x;local C=B%3;local D={}for k=1,B-C,3 do local E,F,G=x:byte(k,k+2)local f=E*0x10000+F*0x100+G;local H;if y then H=D[f]if not H then H=r(p[b(f,18,6)],p[b(f,12,6)],p[b(f,6,6)],p[b(f,0,6)])D[f]=H end else H=r(p[b(f,18,6)],p[b(f,12,6)],p[b(f,6,6)],p[b(f,0,6)])end;z[A]=H;A=A+1 end;if C==2 then local E,F=x:byte(B-1,B)local f=E*0x10000+F*0x100;z[A]=r(p[b(f,18,6)],p[b(f,12,6)],p[b(f,6,6)],p[64])elseif C==1 then local f=x:byte(B)*0x10000;z[A]=r(p[b(f,18,6)],p[b(f,12,6)],p[64],p[64])end;return w(z)end;function a.decode(I,s,y)s=s or v;local J='[^%w%+%/%=]'if s then local m,n;for t,q in pairs(s)do if q==62 then m=t elseif q==63 then n=t end end;J=('[^%%w%%%s%%%s%%=]'):format(r(m),r(n))end;I=I:gsub(J,'')local D=y and{}local z,A={},1;local B=#I;local K=I:sub(-2)=='=='and 2 or I:sub(-1)=='='and 1 or 0;for k=1,K>0 and B-4 or B,4 do local E,F,G,L=I:byte(k,k+3)local H;if y then local M=E*0x1000000+F*0x10000+G*0x100+L;H=D[M]if not H then local f=s[E]*0x40000+s[F]*0x1000+s[G]*0x40+s[L]H=r(b(f,16,8),b(f,8,8),b(f,0,8))D[M]=H end else local f=s[E]*0x40000+s[F]*0x1000+s[G]*0x40+s[L]H=r(b(f,16,8),b(f,8,8),b(f,0,8))end;z[A]=H;A=A+1 end;if K==1 then local E,F,G=I:byte(B-3,B-1)local f=s[E]*0x40000+s[F]*0x1000+s[G]*0x40;z[A]=r(b(f,16,8),b(f,8,8))elseif K==2 then local E,F=I:byte(B-3,B-2)local f=s[E]*0x40000+s[F]*0x1000;z[A]=r(b(f,16,8))end;return w(z)end;return a end)()

function MT.FindByClass(name)
    for i=0, GetHighestEntityIndex(IClientEntityList) do
        local ent = MT.entitylist.get_player_by_index(i)
        if ent ~= nil then
            if ent:get_class_name() == name then
                return {entity = ent, id = i}
            end
        end
    end
    return nil
end

function MT.print(text, color)
    local madtech = "[MADTECH] "
    local color_m = MT.color.new(0, 144, 217, 255)
    local madtech_color = ffi.new("struct c_color")
    local console_color = ffi.new("struct c_color")
    local engine_cvar = ffi.cast("void***", MT.utils.create_interface("vstdlib.dll", "VEngineCvar007"))
    local console_print = ffi.cast("void(__cdecl*)(void*, const struct c_color&, const char*, ...)", engine_cvar[0][25])
    madtech_color.clr[0] = color_m:r();madtech_color.clr[1] = color_m:g();madtech_color.clr[2] = color_m:b();madtech_color.clr[3] = color_m:a()
    console_color.clr[0] = color:r();console_color.clr[1] = color:g();console_color.clr[2] = color:b();console_color.clr[3] = color:a()
    console_print(engine_cvar, madtech_color, madtech)
    console_print(engine_cvar, console_color, string['format']("%s\n", text))
end

local sleep_table = {}
function MT.sleep(time, callback)
    local timer = MT.globals.get_curtime()
    table.insert(sleep_table, {livetime = timer, time = time, callback = callback})
end

function MT.sleep_while()
    for k,v in pairs(sleep_table) do
        local timer = MT.globals.get_curtime()
        local predict_time = timer - v.livetime
        if predict_time >= v.time then
            v.callback()
            sleep_table[k] = nil
        end
    end
end

function MT.Launching()
    local mt_font = MT.render.create_font("Tahoma", 13, 565, false, false, false)
    local ind_font = MT.render.create_font("Verdana", 12, 500, true, false, false)
    function MT:add_refrence(name)
        if not self.refrence[name] then
            return MT.print("Error(#01)", MT.color.new(255, 0, 0, 255))
        end
        return {
            GetValue = function ()
                return self.menu.get_bool(self.refrence[name])
            end,
            GetInt = function ()
                return self.menu.get_int(self.refrence[name])
            end,
            GetFloat = function ()
                return self.menu.get_float(self.refrence[name])
            end,
            GetColor = function ()
                return self.menu.get_color(self.refrence[name])
            end,
            GetBindState = function ()
                return self.menu.get_key_bind_state(self.refrence[name])
            end,
            GetBindMode = function ()
                return self.menu.get_key_bind_state(self.refrence[name])
            end,
            SetBool = function (_, value)
                return self.menu.set_bool(self.refrence[name], value)
            end,
            SetInt = function (_, value)
                return self.menu.set_int(self.refrence[name], value)
            end,
            SetColor = function (_, value)
                return self.menu.set_int(self.refrence[name], value)
            end,
        }
    end

    function MT:get_menu(element, name)
        self.refrence[name] = element
        return self:add_refrence(name)
    end

    function MT:create_menu(element, name, data)
        self.menu[element](self.unpack(data))
        self.refrence[name] = data[1]
        return self:add_refrence(name)
    end

    local categorys = {
        ['AntiAim'] = {
            antiaims_tab = MT:create_menu("add_slider_int", "antiaims_tab", {"                        Anti-Aims", 0, 0}),
            antiaims_enable = MT:create_menu("add_check_box", "antiaims_enable", {"Anti-aimbot angles"}),
            bodyyaw = MT:create_menu("add_combo_box", "bodyyaw", {"BodyYaw", {'Disabled', 'Hybrid', 'Freestanding', 'Movement'}}),
            next_line = MT.menu.next_line(),
            legit_aa_key = MT:create_menu("add_key_bind", "legit_aa_key", {"Legit anti-aim key"}),
            legit_aa_mode = MT:create_menu("add_combo_box", "legit_aa_mode", {"Legit anti-aim Modes", {'Static', 'Freestanding', 'Jitter'}}),
            lowdelta = MT:create_menu("add_key_bind", "lowdelta", {"LowDelta"}),
            lowdelta_speed = MT:create_menu("add_slider_int", "lowdelta_speed", {"LowDelta speed", 1 , 60}),
            lowdelta_desync = MT:create_menu("add_slider_int", "lowdelta_desync", {"LowDelta desync", 1, 60}),
            next_line_1 = MT.menu.next_line(),
            edge_yaw = MT:create_menu("add_key_bind", "edge_yaw_key", {"Edge yaw key"}),
            manual = MT:create_menu("add_key_bind", "manual", {"Mad Manual"}),
            manual_color = MT:create_menu("add_color_picker", "manual_color", {"Manual Color"}),
        },
        ['RageBot'] = {
            ragebot_tab = MT:create_menu("add_slider_int", "antiaims_tab", {"                        Ragebot", 0, 0}),
            resolver = MT:create_menu("add_check_box", "resolver", {"Resolver BETA"}),
            max_miss = MT:create_menu("add_slider_int", "max_miss", {"Max miss", 1, 4}),
            doubletap_speed = MT:create_menu("add_combo_box", "doubletap_speed", {"Doubletap Modes", {'Reliable', 'Fast', 'Fastest', "BreakShift"}}),
            clock_correction = MT:create_menu("add_check_box", "clock_correction", {"Disable Clock Correction"}),
            instant_recharge = MT:create_menu("add_check_box", "instant_recharge", {"Instant recharge"}),
        },
        ['Indicators'] = {
            indicators = MT:create_menu("add_slider_int", "indicators", {"                       Indicators", 0, 0}),
            indicator_enable = MT:create_menu("add_check_box", "indicator_enable", {"Indicator"}),
            next_line = MT.menu.next_line(),
            min_color = MT:create_menu("add_color_picker", "min_color", {"Color"}),
            sec_color = MT:create_menu("add_color_picker", "sec_color", {"Secondary Color"}),
            dm_color = MT:create_menu("add_color_picker", "dm_color", {"Damage color"}),
            WM_color = MT:create_menu("add_color_picker", "WM_color", {"Watermark color"}),
        },
        ['Misc'] = {
            Misc = MT:create_menu("add_slider_int", "Misc", {"                     Miscellaneous", 0, 0}),
            clantag = MT:create_menu("add_check_box", "clantag", {"MadTech clantag"}),
            anti_defensive = MT:create_menu("add_check_box", "anti_defensive", {"Anti-Defensive"}),
            anim_breaker = MT:create_menu("add_check_box", "anim_breaker", {"Anim Breaker"}),
        }
    }

    local ragebot_ref = {
        mindamage_key = MT:get_menu('rage.force_damage_key', 'mindamage_key'),
    }

    local antiaim_ref = {
        enable = MT:get_menu('anti_aim.enable', 'aa_enable'),
        pitch = MT:get_menu('anti_aim.pitch', 'pitch'),
        target_yaw = MT:get_menu('anti_aim.target_yaw', 'target_yaw'),
        edge_yaw = MT:get_menu('anti_aim.edge_yaw', 'edge_yaw'),
        yaw_offset = MT:get_menu('anti_aim.yaw_offset', 'yaw_offset'),
        yaw_modifier = MT:get_menu('anti_aim.yaw_modifier', 'yaw_modifier'),
        manual_forward_key = MT:get_menu('anti_aim.manual_forward_key', 'manual_forward_key'),
        manual_back_key = MT:get_menu('anti_aim.manual_back_key', 'manual_back_key'),
        manual_left_key = MT:get_menu('anti_aim.manual_left_key', 'manual_left_key'),
        manual_right_key = MT:get_menu('anti_aim.manual_right_key', 'manual_right_key'),
        enable_fake_lag = MT:get_menu('anti_aim.enable_fake_lag', 'enable_fake_lag'),
        fake_lag_type = MT:get_menu('anti_aim.fake_lag_type', 'fake_lag_type'),
        fake_lag_limit = MT:get_menu('anti_aim.fake_lag_limit', 'fake_lag_limit'),
        desync_type = MT:get_menu('anti_aim.desync_type', 'desync_type'),
        desync_range = MT:get_menu('anti_aim.desync_range', 'desync_range'),
        desync_range_inverted = MT:get_menu('anti_aim.desync_range_inverted', 'desync_range_inverted'),
        invert_desync_key = MT:get_menu('anti_aim.invert_desync_key', 'invert_desync_key'),
        leg_movement = MT:get_menu('misc.leg_movement', 'leg_movement'),
        slow_walk_key = MT:get_menu('misc.slow_walk_key', 'slow_walk_key'),
        fake_duck_key = MT:get_menu('anti_aim.fake_duck_key', 'fake_duck_key'),
    }

    local base_aa = {
        is_manual = false,
        manual_stats = "none",
        last_movement = false,
        manual_aa = {
            ['left'] = {
                pitch = 1,
                target_yaw = 1,
                edge_yaw = false,
                yaw_offset = 0,
                yaw_modifier = 0,
                desync_type = 1,
                desync_range = 30,
                desync_inverted = 30,
                inverter = false,
                manual = {
                    left = true,
                    right = false,
                    reset = false
                },
            },
            ['right'] = {
                pitch = 1,
                target_yaw = 1,
                edge_yaw = false,
                yaw_offset = 0,
                yaw_modifier = 0,
                desync_type = 1,
                desync_range = 30,
                desync_inverted = 30,
                inverter = true,
                manual = {
                    left = false,
                    right = true,
                    reset = false
                },
            }
        },
        legit_aa = {
            ['static'] = {
                pitch = 0,
                target_yaw = 0,
                edge_yaw = false,
                yaw_offset = 180,
                yaw_modifier = 0,
                desync_type = 1,
                desync_range = 30,
                desync_inverted = 30,
                inverter = true,
                manual = {
                    left = false,
                    right = false,
                    reset = true
                },
            },
            ['freestand'] = {
                pitch = 0,
                target_yaw = 0,
                edge_yaw = false,
                yaw_offset = 180,
                yaw_modifier = 0,
                desync_type = 1,
                desync_range = 30,
                desync_inverted = 30,
                inverter = true,
                manual = {
                    left = false,
                    right = false,
                    reset = true
                },
            },
            ['jitter'] = {
                pitch = 0,
                target_yaw = 0,
                edge_yaw = false,
                yaw_offset = 180,
                yaw_modifier = 0,
                desync_type = 2,
                desync_range = 30,
                desync_inverted = 30,
                inverter = true,
                manual = {
                    left = false,
                    right = false,
                    reset = true
                },
            },
        },
        main_aa = {
            ['standing'] = {
                pitch = 1,
                target_yaw = 1,
                edge_yaw = false,
                yaw_offset = 0,
                yaw_modifier = 0,
                desync_type = 1,
                desync_range = 27,
                desync_inverted = 27,
                inverter = true,
                manual = {
                    left = false,
                    right = false,
                    reset = true
                },
            },
            ['moving'] = {
                pitch = 1,
                target_yaw = 1,
                edge_yaw = false,
                yaw_offset = -2,
                yaw_modifier = 0,
                desync_type = 1,
                desync_range = 60,
                desync_inverted = 60,
                inverter = false,
                manual = {
                    left = false,
                    right = false,
                    reset = true
                },
            },
            ['slowwalk'] = {
                pitch = 1,
                target_yaw = 1,
                edge_yaw = false,
                yaw_offset = 0,
                yaw_modifier = 2,
                desync_type = 1,
                desync_range = 31,
                desync_inverted = 25,
                inverter = false,
                manual = {
                    left = false,
                    right = false,
                    reset = true
                },
            },
            ['air'] = {
                pitch = 1,
                target_yaw = 1,
                edge_yaw = false,
                yaw_offset = 1,
                yaw_modifier = 2,
                desync_type = 2,
                desync_range = 41,
                desync_inverted = 41,
                inverter = true,
                manual = {
                    left = false,
                    right = false,
                    reset = true
                },
            },
            ['crouching'] = {
                pitch = 1,
                target_yaw = 1,
                edge_yaw = false,
                yaw_offset = 0,
                yaw_modifier = 0,
                desync_type = 2,
                desync_range = 21,
                desync_inverted = 21,
                inverter = true,
                manual = {
                    left = false,
                    right = false,
                    reset = true
                },
            },
        }
    }

    local weapons = {
        ['CDEagle'] = 0,
        ['CWeaponHKP2000'] = 1,
        ['CWeaponP250'] = 1,
        ['CWeaponElite'] = 1,
        ['CWeaponFiveSeven'] = 1,
        ['CWeaponGlock'] = 1,
        ['CWeaponTec9'] = 1,
        ['CWeaponG3SG1'] = 2,
        ['CWeaponSCAR20'] = 2,
        ['CWeaponSSG08'] = 3,
        ['CWeaponAWP'] = 4,
        ['CAK47'] = 5,
        ['CWeaponAug'] = 5,
        ['CWeaponFamas'] = 5,
        ['CWeaponGalilAR'] = 5,
        ['CWeaponM4A1'] = 5,
        ['CWeaponSG556'] = 5,
        ['CWeaponP90'] = 6,
        ['CWeaponBizon'] = 6,
        ['CWeaponUMP45'] = 6,
        ['CWeaponMP7'] = 6,
        ['CWeaponMP9'] = 6,
        ['CWeaponMAC10'] = 6,
        ['CWeaponNOVA'] = 7,
        ['CWeaponXM1014'] = 7,
        ['CWeaponSawedoff'] = 7,
        ['CWeaponNegev'] = 8,
        ['CWeaponM249'] = 8
    }
    local weapon_damages = {}
    local weapon_number = 1
    for k,v in pairs(weapons) do
        weapon_damages[k] = {}
        weapon_damages[k].damage = MT:get_menu(string.format('rage.weapon[%s].minimum_damage   ', v), string.format("%s_damage_%s", k, weapon_number))
        weapon_damages[k].mindamage = MT:get_menu(string.format('rage.weapon[%s].force_damage_value   ', v), string.format("%s_mindamage_%s", k, weapon_number))
        weapon_number = weapon_number + 1
    end

    function MT.AAHandler(data, is_else)
        if data then
            if data.pitch then
                antiaim_ref.pitch:SetInt(data.pitch)
            elseif is_else then
                antiaim_ref.pitch:SetInt(0)
            end
            if data.target_yaw then
                antiaim_ref.target_yaw:SetInt(data.target_yaw)
            elseif is_else then
                antiaim_ref.target_yaw:SetInt(0)
            end
            if data.yaw_offset then
                antiaim_ref.yaw_offset:SetInt(data.yaw_offset)
            elseif is_else then
                antiaim_ref.yaw_offset:SetInt(0)
            end
            if data.yaw_modifier then
                antiaim_ref.yaw_modifier:SetInt(data.yaw_modifier)
            elseif is_else then
                antiaim_ref.yaw_modifier:SetInt(0)
            end
            if data.desync_type then
                antiaim_ref.desync_type:SetInt(data.desync_type)
            elseif is_else then
                antiaim_ref.desync_type:SetInt(0)
            end
            if data.desync_range then
                antiaim_ref.desync_range:SetInt(data.desync_range)
            elseif is_else then
                antiaim_ref.desync_range:SetInt(0)
            end
            if data.desync_inverted then
                antiaim_ref.desync_range_inverted:SetInt(data.desync_inverted)
            elseif is_else then
                antiaim_ref.desync_range_inverted:SetInt(0)
            end
            if data.desync_inverted then
                antiaim_ref.desync_range_inverted:SetInt(data.desync_inverted)
            elseif is_else then
                antiaim_ref.desync_range_inverted:SetInt(0)
            end
            if data.edge_yaw then
                antiaim_ref.edge_yaw:SetBool(true)
            else
                antiaim_ref.edge_yaw:SetBool(false)
            end
            if data.inverter then
                if not antiaim_ref.invert_desync_key:GetBindState() then
                    antiaim_ref.invert_desync_key:SetBool(true)
                end
            else
                if antiaim_ref.invert_desync_key:GetBindState() then
                    antiaim_ref.invert_desync_key:SetBool(false)
                end
            end
            if data.manual then
                if data.manual.left then
                    if not antiaim_ref.manual_left_key:GetBindState() and not antiaim_ref.manual_right_key:GetBindState() then
                        antiaim_ref.manual_left_key:SetBool(true)
                    else
                        antiaim_ref.manual_right_key:SetBool(false)
                        antiaim_ref.manual_left_key:SetBool(true)
                    end
                end
                if data.manual.right then
                    if not antiaim_ref.manual_left_key:GetBindState() and not antiaim_ref.manual_right_key:GetBindState() then
                        antiaim_ref.manual_right_key:SetBool(true)
                    else
                        antiaim_ref.manual_left_key:SetBool(false)
                        antiaim_ref.manual_right_key:SetBool(true)
                    end
                end
                if data.manual.reset then
                    if antiaim_ref.manual_left_key:GetBindState() or antiaim_ref.manual_right_key:GetBindState() or antiaim_ref.manual_back_key:GetBindState() then
                        antiaim_ref.manual_left_key:SetBool(false)
                        antiaim_ref.manual_right_key:SetBool(false)
                        antiaim_ref.manual_back_key:SetBool(false)
                    end
                end
            end
        end
    end

    function MT.get_aa_state()
        local localplayer = MT.entitylist.get_local_player()
        local velocity = math.floor(localplayer:get_velocity():length_2d())
        local slowwalk = false
        local flags = localplayer:get_prop_int("CBasePlayer", "m_fFlags")
        if MT.bit.band(flags, 1) == 0 or MT.IsButtonDown(32) then return "air" end
        if MT.bit.band(flags, 2) ~= 0 then return "crouching" end
        if slowwalk then return "slowwalk" end
        local state = "standing"
        if velocity > 1 then
            state = "moving"
        else
            state = "standing"
        end
        return state
    end

    function MT.get_eye_position(player, cmd)
        local origin = player:get_origin()
        return MT.vector.new(origin['x'] + cmd.viewangles['x'], origin.y + cmd.viewangles.y, origin.z + cmd.viewangles.z)
    end

    function MT.round(num, numDecimalPlaces)
        return tonumber(string['format']("%." .. (numDecimalPlaces or 0) .. "f", num))
    end

    function MT.DistTo(x, y, z, x1, y1, z1)
        return math.sqrt(math.pow((x1-x),2) + math.pow((y1-y),2) + math.pow((z1-z),2))
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
        return math.deg(math.atan2(ydelta, xdelta))
    end

    function MT.calculateAngle(src, point)
        local angles = MT.vector.new(0, 0, 0)
        local delta = MT.vector.new(src.x - point.x, src.y - point.y, src.z - point.z)
        local hyp = delta:length_2d()
        angles.y = math.atan(delta.y / delta.x) * math.pi
        angles.x = math.atan(-delta['z'] / hyp) * -math.pi
        angles.z = 0.0
        angles.y = angles.y + 180.0
        return angles
    end


    function MT.calculate_selection(x,y,z)
        if y < -5 then return 3 end
        if y > 5 then return 1 end
        return 2
    end
    
    function MT.get_nearest_enemy()
        local localplayer = MT.entitylist.get_local_player()
        if not localplayer then return nil end
        local localpos = localplayer:get_origin()
        local viewangles = MT.engine.get_view_angles()
        local fov = 180
        local data = {}
        for i=0, MT.globals.get_maxclients() do 
            local entity = MT.entitylist.get_player_by_index(i)
            if entity and entity:is_player() then
                local player = MT.entitylist.entity_to_player(entity)
                if player:get_health() > 0 and player:get_team() ~= localplayer:get_team() and player:get_index() ~= localplayer:get_index() then
                    local playerpos = player:get_origin()
                    local cur_fov = math.abs(MT.normalize_yaw(MT.world2scren(localpos.x - playerpos.x, localpos.y - playerpos.y) - viewangles.y + 180))
                    if cur_fov <= fov then
                        data = {entity = player, fov = cur_fov}
                    end
                end
            end
        end
        return data
    end

    function MT.LowestDist(table)
        local lowest = table[1]
        for k,v in pairs(table) do
            if lowest.dist >= v.dist then
                lowest = v
            end
        end
        return lowest
    end

    function MT.get_lowerdist_enemy()
        local localplayer = MT.entitylist.get_local_player()
        if not localplayer then return nil end
        local localpos = localplayer:get_origin()
        local viewangles = MT.engine.get_view_angles()
        local fov = 180
        local distance = {}
        for i=0, MT.globals.get_maxclients() do 
            local entity = MT.entitylist.get_player_by_index(i)
            if entity and entity:is_player() then
                local player = MT.entitylist.entity_to_player(entity)
                if player:get_health() > 0 and player:get_team() ~= localplayer:get_team() and player:get_index() ~= localplayer:get_index() then
                    local playerpos = player:get_origin()
                    local dist = localpos:dist_to(playerpos)
                    local cur_fov = math.abs(MT.normalize_yaw(MT.world2scren(localpos.x - playerpos.x, localpos.y - playerpos.y) - viewangles.y + 180))
                    if cur_fov <= fov then
                        table.insert(distance, {entity = player, dist = dist})
                    end
                end
            end
        end
        local lowest_data = MT.LowestDist(distance)
        return lowest_data
    end

    function MT.get_desync(e)
        local localplayer = MT.entitylist.get_local_player()
        local data = MT['get_nearest_enemy']()
        local desync = 'middle'
        if data then
            if data.entity == nil then return 'middle' end
            local angls = MT.calculateAngle(MT.get_eye_position(localplayer, e), data.entity:get_origin())
            local predict_angls = math.floor(angls.y - 180)
            if predict_angls == 0 then
                desync = 'middle'
            elseif predict_angls > 0 and predict_angls <= 5 then
                desync = 'right'
            elseif 0 > predict_angls and predict_angls >= -5 then
                desync = 'left'
            end
            -- print("name "..MT['engine']['get_player_info'](data.entity:get_index()).name)
            -- print(desync)
            -- print("y "..math['floor'](predict_angls)) -- 175 > 179 right || 180 > 184 left
            -- print("x "..MT['round'](angls['x'], 2))
            -- print("z "..angls['z'])
        end
        return desync
    end

    function MT.LegitAA(cmd)
        local localplayer = MT.entitylist.get_local_player()
        if not localplayer then return end
        local C4 = MT.FindByClass("CPlantedC4")
        if C4 ~= nil then
            local pl_orig = ffi.cast("Vector_t*",ffi_helpers.get_entity_address(localplayer:get_index())+312)
            local c4_orig = ffi.cast("Vector_t*",ffi_helpers.get_entity_address(C4.id)+312)
            local distance = MT.DistTo(pl_orig.x, pl_orig.y, pl_orig.z, c4_orig.x, c4_orig.y, c4_orig.z)
            if distance < 100 then
                return MT.AAHandler(base_aa.main_aa.standing, false)
            end
        else
            cmd.buttons = MT.bit.band(cmd.buttons, MT.bit.bnot(32))
        end
        local legit_mode = categorys.AntiAim.legit_aa_mode:GetInt()
        if legit_mode == 0 then
            MT.AAHandler(base_aa.legit_aa.static, false)
        elseif legit_mode == 1 then
            local desync = MT.get_desync(cmd)
            if desync == "right" then
                base_aa.legit_aa.freestand.inverter = true
            elseif desync == "left" then
                base_aa.legit_aa.freestand.inverter = false
            end
            MT.AAHandler(base_aa.legit_aa.freestand, false)
        elseif legit_mode == 2 then
            MT.AAHandler(base_aa.legit_aa.jitter, false)
        end
    end

    function MT.movement_sync()
        local right_key = MT.IsButtonDown(0x41)
        local left_key = MT.IsButtonDown(0x44)
        if right_key then
            base_aa.last_movement = false
        end
        if left_key then
            base_aa.last_movement = true
        end
        return base_aa.last_movement
    end

    function MT.can_edge(state)
        local can_edge = false
        local is_edgeyaw = categorys.AntiAim.edge_yaw:GetBindState()
        local is_fakeduck = antiaim_ref.fake_duck_key:GetBindState()
        if is_edgeyaw then can_edge = true end
        if state == "air" then can_edge = false
        elseif state == "crouching" then can_edge = false
        elseif state == "slowwalk" then can_edge = false
        elseif is_fakeduck then can_edge = false end
        return can_edge
    end

    function MT.edge_yaw()
        MT.AAHandler({
            pitch = 1,
            target_yaw = 1,
            edge_yaw = true,
            yaw_offset = 0,
            yaw_modifier = 0,
            desync_type = 1,
            desync_range = 30,
            desync_inverted = 30,
            inverter = false,
            manual = {
                left = false,
                right = false,
                reset = true
            },
        }, false)
    end

    function MT.desync_handler(e)
        local aa_state = MT.get_aa_state()
        local is_edge = MT.can_edge(aa_state)
        if is_edge then
            return MT.edge_yaw()
        end
        local bodyyaw = categorys.AntiAim.bodyyaw:GetInt()
        if aa_state ~= "slowwalk" and aa_state ~= "air" and aa_state ~= "crouching" then
            if bodyyaw == 1 then
                local desync = MT.get_desync(e)
                local movement_sync = MT.movement_sync()
                if aa_state == "standing" then
                    if desync == "right" then
                        base_aa.main_aa[aa_state].inverter = false
                        base_aa.main_aa[aa_state].desync_type = 1
                        base_aa.main_aa[aa_state].desync_range = 60
                        base_aa.main_aa[aa_state].desync_inverted = 60
                    elseif desync == "left" then
                        base_aa.main_aa[aa_state].inverter = true
                        base_aa.main_aa[aa_state].desync_type = 1
                        base_aa.main_aa[aa_state].desync_range = 60
                        base_aa.main_aa[aa_state].desync_inverted = 60
                    elseif desync == "middle" then
                        base_aa.main_aa[aa_state].inverter = false
                        base_aa.main_aa[aa_state].desync_type = 2
                        base_aa.main_aa[aa_state].desync_range = 22
                        base_aa.main_aa[aa_state].desync_inverted = 22
                    end
                elseif aa_state == "moving" then
                    if movement_sync then
                        base_aa.main_aa[aa_state].inverter = false
                        base_aa.main_aa[aa_state].desync_type = 1
                        base_aa.main_aa[aa_state].desync_range = 60
                        base_aa.main_aa[aa_state].desync_inverted = 60
                    else
                        base_aa.main_aa[aa_state].inverter = true
                        base_aa.main_aa[aa_state].desync_type = 1
                        base_aa.main_aa[aa_state].desync_range = 60
                        base_aa.main_aa[aa_state].desync_inverted = 60
                    end
                end
            elseif bodyyaw == 2 then
                local desync = MT.get_desync(e)
                if desync == "right" then
                    base_aa.main_aa[aa_state].inverter = false
                    base_aa.main_aa[aa_state].desync_type = 1
                    base_aa.main_aa[aa_state].desync_range = 60
                    base_aa.main_aa[aa_state].desync_inverted = 60
                elseif desync == "left" then
                    base_aa.main_aa[aa_state].inverter = true
                    base_aa.main_aa[aa_state].desync_type = 1
                    base_aa.main_aa[aa_state].desync_range = 60
                    base_aa.main_aa[aa_state].desync_inverted = 60
                elseif desync == "middle" then
                    base_aa.main_aa[aa_state].inverter = false
                    base_aa.main_aa[aa_state].desync_type = 2
                    base_aa.main_aa[aa_state].desync_range = 22
                    base_aa.main_aa[aa_state].desync_inverted = 22
                end
            elseif bodyyaw == 3 then
                local movement_sync = MT.movement_sync()
                if movement_sync then
                    base_aa.main_aa[aa_state].inverter = false
                    base_aa.main_aa[aa_state].desync_type = 1
                    base_aa.main_aa[aa_state].desync_range = 60
                    base_aa.main_aa[aa_state].desync_inverted = 60
                else
                    base_aa.main_aa[aa_state].inverter = true
                    base_aa.main_aa[aa_state].desync_type = 1
                    base_aa.main_aa[aa_state].desync_range = 60
                    base_aa.main_aa[aa_state].desync_inverted = 60
                end
            end
        end
        MT.AAHandler(base_aa.main_aa[aa_state], false)
    end

    function MT.walkspeed(cmd, speed)
        local localplayer = MT.entitylist.get_local_player()
        local velocity = math['floor'](localplayer:get_velocity():length_2d())
        local ld_speed = speed
        local speed = 1
        if(velocity > 1) then
            cmd.forwardmove = (cmd.forwardmove * speed) / ld_speed
            cmd.sidemove = (cmd.sidemove * speed) / ld_speed
            cmd.upmove = (cmd.sidemove * speed) / ld_speed
        end
    end

    function MT.lowdelta(cmd)
        local desync = categorys.AntiAim.lowdelta_desync:GetInt()
        local speed = categorys.AntiAim.lowdelta_speed:GetInt()
        local random_desync = math['random'](desync - 10, desync)
        MT.AAHandler({
            pitch = 1,
            target_yaw = 1,
            edge_yaw = false,
            yaw_offset = 0,
            yaw_modifier = 0,
            desync_type = 2,
            desync_range = random_desync,
            desync_inverted = random_desync,
            inverter = false,
            manual = {
                left = false,
                right = false,
                reset = true
            },
        }, false)
        MT.walkspeed(cmd, speed)
    end

    local doubletap_speeds = {[0] = 14, [1] = 16, [2] = 17, [3] = 18}

    function MT.Ragebot()
        local dt_mode = categorys.RageBot.doubletap_speed:GetInt()
        local disbale_clock = categorys.RageBot.clock_correction:GetValue()
        local instant_recharge = categorys.RageBot.instant_recharge:GetValue()
        local dt_speed = doubletap_speeds[dt_mode]
        local l_cheats = MT.console.get_int('sv_cheats')
        local l_speed = MT.console.get_int('sv_maxusrcmdprocessticks')
        local l_clock = MT.console.get_int('cl_clock_correction')
        local l_clock_amount = MT.console.get_int('cl_clock_correction_adjustment_max_amount')
        local l_force_tick = MT.console.get_int('cl_clock_correction_force_server_tick')
        if l_cheats ~= 1 then
            MT.console.set_int("sv_cheats", 1)
        end
        if l_speed ~= dt_speed then
            MT.console.set_int('sv_maxusrcmdprocessticks', dt_speed)
        end
        if disbale_clock then
            if l_clock == 1 then
                MT.console.set_int("cl_clock_correction", 0)
            end
            if l_clock_amount ~= 450 then
                MT.console.set_int("cl_clock_correction_adjustment_max_amount", 450)
                MT.console.set_int("cl_clock_correction_adjustment_max_offset", 800)
            end
        else
            if l_clock == 0 then
                MT.console.set_int("cl_clock_correction", 1)
            end
            if l_clock_amount ~= 200 then
                MT.console.set_int("cl_clock_correction_adjustment_max_amount", 200)
                MT.console.set_int("cl_clock_correction_adjustment_max_offset", 30)
            end
        end
        if instant_recharge then
            if l_force_tick ~= 1 then
                MT.console.set_int("cl_clockdrift_max_ms", 100)
                MT.console.set_int("cl_clock_correction_force_server_tick", 1)
            end
        else
            if l_force_tick ~= 999 then
                MT.console.set_int("cl_clockdrift_max_ms", 150)
                MT.console.set_int("cl_clock_correction_force_server_tick", 999)
            end
        end
    end

    function MT.player_state(player)
        local velocity = math.floor(player:get_velocity():length_2d())
        local flags = player:get_prop_int("CBasePlayer", "m_fFlags")
        local angles = player:get_angles()
        if angles.x >= 0 and angles.x <= 10 then return "legit" end
        if MT.bit.band(flags, 1) == 0 then return "air" end
        if MT.bit.band(flags, 2) ~= 0 then return "crouching" end
        if velocity > 20 and velocity <= 80 then return "slowwalk" end
        local state = "standing"
        if velocity > 1 then
            state = "moving"
        else
            state = "standing"
        end
        return state
    end

    local resolved = {}
    local last_target_resolve = {}

    function MT.Resolve_nigger(target)
        if resolved[target] then
            local miss_shot = resolved[target]
            resolved[target] = miss_shot + 1
        else
            resolved[target] = 1
        end
    end

    function MT.Resolved(shot)
        local reason = shot.result
        local player_index = shot.target_index
        if reason == "Resolver" then
            local pitch = last_target_resolve.pitch == nil and "unknown" or last_target_resolve.pitch
            local yaw = last_target_resolve.yaw == nil and "unknown" or last_target_resolve.yaw
            local state = last_target_resolve.state == nil and "unknown" or last_target_resolve.state
            print("[MADTECH] missed to PITCH: "..pitch.." Yaw: "..yaw.." state: "..state)
            MT.Resolve_nigger(player_index)
        end
    end

    function MT.Resolver()
        local is_target = MT.get_lowerdist_enemy()
        local localplayer = MT.entitylist.get_local_player()
        if not localplayer then return nil end
        local activeweapon = MT.entitylist.get_weapon_by_player(localplayer)
        if not activeweapon then return end
        local timer = MT.globals.get_curtime()
        if is_target then
            if is_target.entity == nil then return end
            local player_state = MT.player_state(is_target.entity)
            local player_index = is_target.entity:get_index()
            local player_info = MT.engine.get_player_info(player_index)
            local angles = is_target.entity:get_angles()
            local angles_p = math.floor( angles.x )
            local normalize_yaw = MT.normalize_yaw(math.floor( angles.y ))
            local x_z = 400
            local screen_x = MT.engine.get_screen_width() / 2
            local screen_y = MT.engine.get_screen_height() / 2
            local pitch = angles_p
            local real_yaw = normalize_yaw
            local normalize = false
            if 0 > normalize_yaw then
                if -60 > normalize_yaw then
                    normalize = false
                    normalize_yaw = -60
                else
                    normalize = true
                    normalize_yaw = normalize_yaw
                end
            elseif normalize_yaw > 0 then
                if normalize_yaw > 60 then
                    normalize = false
                    normalize_yaw = 60
                else
                    normalize = true
                    normalize_yaw = normalize_yaw
                end
            end
            if angles_p > 70 then
                pitch = 89
            else
                pitch = angles_p
            end
            if normalize then
                if player_state == "moving" or player_state == "slowwalk" then
                    local desync_value = 0
                    if normalize_yaw > 0 and normalize_yaw > 50 then
                        normalize_yaw = normalize_yaw - desync_value
                    elseif normalize_yaw < 0 and normalize_yaw < -50 then
                        normalize_yaw = normalize_yaw + desync_value
                    elseif normalize_yaw > 0 and normalize_yaw < 25 then
                        normalize_yaw = normalize_yaw + desync_value
                    elseif normalize_yaw < 0 and normalize_yaw < -25 then
                        normalize_yaw = normalize_yaw - desync_value
                    end
                elseif player_state == "standing" then
                    normalize_yaw = normalize_yaw
                elseif player_state == "air" then
                    pitch = 50
                    normalize_yaw = math.abs(normalize_yaw) - 11
                elseif player_state == "crouching" then
                    pitch = 30
                    local desync_value = 0
                    if normalize_yaw > 0 and normalize_yaw > 50 then
                        normalize_yaw = normalize_yaw - desync_value
                    elseif normalize_yaw < 0 and normalize_yaw < -50 then
                        normalize_yaw = normalize_yaw + desync_value
                    elseif normalize_yaw > 0 and normalize_yaw < 25 then
                        normalize_yaw = normalize_yaw + desync_value
                    elseif normalize_yaw < 0 and normalize_yaw < -25 then
                        normalize_yaw = normalize_yaw - desync_value
                    end
                end
            end
            last_target_resolve = {pitch = pitch, yaw = normalize_yaw, state = player_state}
            if player_state == "legit" then
                MT.menu.set_bool("player_list.player_settings[" ..is_target.entity:get_index().. "].force_body_yaw", false)
                MT.menu.set_bool("player_list.player_settings[" ..is_target.entity:get_index().. "].force_pitch", false)
            else
                MT.menu.set_bool("player_list.player_settings[" ..is_target.entity:get_index().. "].force_pitch", true)
                MT.menu.set_bool("player_list.player_settings[" ..is_target.entity:get_index().. "].force_body_yaw", true)
            end
            if normalize then
                MT.menu.set_bool("player_list.player_settings[" ..is_target.entity:get_index().. "].force_pitch", true)
            else
                MT.menu.set_bool("player_list.player_settings[" ..is_target.entity:get_index().. "].force_pitch", false)
            end
            MT.menu.set_bool("player_list.player_settings[" ..is_target.entity:get_index().. "].force_body_aim", false)
            local is_mindamge = ragebot_ref.mindamage_key:GetBindState()
            if not is_mindamge then
                local weapon_name = activeweapon:get_class_name()
                if weapon_damages[weapon_name] then
                    local damage = weapon_damages[weapon_name].damage
                    if is_target.entity:get_health() <= 93 then
                        if damage:GetInt() >= is_target.entity:get_health() then
                            MT.menu.set_bool("player_list.player_settings[" ..is_target.entity:get_index().. "].force_body_aim", true)
                        end
                    end
                end
            end
            if (timer % 0.8 >= 0.4) then
                MT.menu.set_int("player_list.player_settings[" ..is_target.entity:get_index().. "].pitch", pitch)
                MT.menu.set_int("player_list.player_settings[" ..is_target.entity:get_index().. "].body_yaw", normalize_yaw)
            end
            MT.render.draw_text(mt_font, screen_x - x_z, screen_y - 100, MT.color.new(255, 255, 255, 255), "NAME: "..player_info.name)
            MT.render.draw_text(mt_font, screen_x - x_z, screen_y - 85, MT.color.new(255, 255, 255, 255), "YAW: "..normalize_yaw)
            MT.render.draw_text(mt_font, screen_x - x_z, screen_y - 70, MT.color.new(255, 255, 255, 255), "PITCH: "..pitch)
            MT.render.draw_text(mt_font, screen_x - x_z, screen_y - 55, MT.color.new(255, 255, 255, 255), "HEALTH: "..is_target.entity:get_health())
            MT.render.draw_text(mt_font, screen_x - x_z, screen_y - 40, MT.color.new(255, 255, 255, 255), "PLAYER DISTANCE: "..is_target.dist)
            MT.render.draw_text(mt_font, screen_x - x_z, screen_y - 25, MT.color.new(255, 255, 255, 255), player_state)
            MT.render.draw_text(mt_font, screen_x - x_z, screen_y - 15, MT.color.new(255, 255, 255, 255), tostring(real_yaw))
        end
    end
    MT.events.register_event("round_end", function()
        resolved = {}
    end)

    function MT.Main(e)
        local antiaims_is_enable = categorys.AntiAim.antiaims_enable:GetValue()
        if antiaims_is_enable then
            local is_legit_aa = categorys.AntiAim.legit_aa_key:GetBindState()
            if is_legit_aa then
                MT.LegitAA(e)
            else
                if not base_aa.is_manual then
                    local is_slowwalk = categorys.AntiAim.lowdelta:GetBindState()
                    if is_slowwalk then
                        MT.lowdelta(e)
                    else
                        MT.desync_handler(e)
                    end
                else
                    local manual_stats = base_aa.manual_stats
                    MT.AAHandler(base_aa.manual_aa[manual_stats], false)
                end
            end
        end
        MT.Ragebot()
    end

    --local ModeNine = MT['render']['create_font']("ModeNine", 16, 500, false, false, false)

    function MT.Spec_c(number)
        local specs = ""
        if number < 9 then specs = string.format("  %s",number)
        elseif number >= 10 and number <= 99 then specs = string.format(" %s",number)
        else specs = string.format("%s",number) end
        return specs
    end
    
    local frame_rate = 0.0
    function MT.get_abs_fps()
        frame_rate = 0.9 * frame_rate + (1.0 - 0.9) * MT.globals.get_frametime()
        return math.floor((1.0 / frame_rate) + 0.5)
    end

    function MT.FakeDesync(localplayer)
        local is_antiaim = antiaim_ref.enable:GetValue()
        if is_antiaim then
            local inverted = antiaim_ref.invert_desync_key:GetBindState()
            local velocity = math.floor(localplayer:get_velocity():length_2d())
            local desync = 0
            if inverted then
                desync = antiaim_ref.desync_range_inverted:GetInt()
            else
                desync = antiaim_ref.desync_range:GetInt()
            end
            if desync > 50 then desync = 50 end
            if velocity > 1 then
                local random_desync = math.min(math.random(desync - 10, desync), 50)
                desync = random_desync
            end
            return desync
        else
            return 12
        end
    end
    local is_Defensive
    function MT.antidefensive()
        local is_enable = categorys.Misc.anti_defensive:GetValue()
        local lagcompensation = MT.console.get_int('cl_lagcompensation')
        if is_enable then
            if is_Defensive then return end
            is_Defensive = true
            if lagcompensation == 1 then
                print("Anti-Defensive activated.")
                MT.console.execute("jointeam 1")
                MT.sleep(1, function ()
                    MT.console.execute("cl_lagcompensation 0")
                    MT.console.execute("teammenu")
                end)
            else
                print("Anti-Defensive has already enabled.")
            end
        else
            if not is_Defensive then return end
            is_Defensive = false

            if lagcompensation == 0 then
                print("Anti-Defensive deactivated.")
                MT.console.execute("jointeam 1")
                MT.sleep(1, function ()
                    MT.console.execute("cl_lagcompensation 1")
                    MT.console.execute("teammenu")
                end)
            else
                print("Anti-Defensive has already disabled.")
            end
        end
    end

    function MT.clan_tag_anim()
        if not MT.engine.is_connected() then return end
        local latency = MT.globals.get_ping() / MT.globals.get_intervalpertick()
        local tickcount_pred = MT.globals.get_tickcount() + latency
        local iter = math.floor(math.fmod(tickcount_pred / 40, #clantag + 1) + 1)
        MT.set_clantag(clantag[iter])
    end

    local Mtlogo = MT.httpImage("https://cdn.discordapp.com", "/attachments/880756070782492692/905342846226296852/madnew.png")
    function MT.Misc()
        if not MT.engine.is_connected() then return end
        local clan_tag = categorys.Misc.clantag:GetValue()
        if clan_tag then
            MT.clan_tag_anim()
        else
            MT.set_clantag("")
        end
        MT.sleep_while()
        MT.antidefensive()
    end

    local open_angles, close_angles
    local selected = 0
    local manual_state = false
    function MT.ManualAA()
        local is_enable = categorys.AntiAim.manual:GetBindState()
        if is_enable ~= manual_state then
            manual_state = is_enable
            if is_enable then
                open_angles = MT.engine.get_view_angles()
            else
                close_angles = MT.engine.get_view_angles()
                selected =  MT.calculate_selection(MT.normalize_yaw(open_angles.x - close_angles.x), MT.normalize_yaw(open_angles.y - close_angles.y), MT.normalize_yaw(open_angles.z - close_angles.z))
                if selected == 3 then
                    base_aa.is_manual = true
                    base_aa.manual_stats = "left"
                    MT.AAHandler(base_aa.manual_aa.left, false)
                elseif selected == 1 then
                    base_aa.is_manual = true
                    base_aa.manual_stats = "right"
                    MT.AAHandler(base_aa.manual_aa.right, false)
                else
                    base_aa.is_manual = false
                    base_aa.manual_stats = "none"
                end
            end
        end
        if is_enable and open_angles then
            local m_color = categorys.AntiAim.manual_color:GetColor()
            local s_x = MT.engine.get_screen_width() / 2
            local s_y = MT.engine.get_screen_height() / 2
            local alpha = math.max(50,math.abs(math.floor(math.sin(MT.globals.get_realtime() * 4) * 100)))
            local r,g,b = m_color:r(), m_color:g(), m_color:b()
            local mad_color = MT.color.new(r, g, b, alpha)
            local cru_angles = MT.engine.get_view_angles()
            selected =  MT.calculate_selection(MT.normalize_yaw(open_angles.x - cru_angles.x), MT.normalize_yaw(open_angles.y - cru_angles.y), MT.normalize_yaw(open_angles.z - cru_angles.z))
            if selected == 3 then
                MT.render.draw_rect_filled(s_x - 91, s_y - 60, 60, 40, mad_color)
            else
                MT.render.draw_rect_filled(s_x - 91, s_y - 60, 60, 40, MT.color.new(0, 0, 0, 110))
            end
            if selected == 2 then
                MT.render.draw_rect_filled(s_x - 30, s_y - 60, 60, 40, mad_color)
            else
                MT.render.draw_rect_filled(s_x - 30, s_y - 60, 60, 40, MT.color.new(0, 0, 0, 110))
            end
            if selected == 1 then
                MT.render.draw_rect_filled(s_x + 31, s_y - 60, 60, 40, mad_color)
            else
                MT.render.draw_rect_filled(s_x + 31, s_y - 60, 60, 40, MT.color.new(0, 0, 0, 110))
            end
        end
    end
    local shared_onground

    -- function MT.anim_breaker()
    --     local localplayer = MT.entitylist.get_local_player()
    --     if not localplayer then return end
    --     local bOnGround = MT.bit.band(localplayer:get_prop_float("CBasePlayer", "m_fFlags"), MT.bit.lshift(1,0)) ~= 0
    --     if not bOnGround then
    --         ffi.cast("CCSGOPlayerAnimationState_534535_t**", ffi_helpers.get_entity_address(localplayer:get_index()) + offset_value)[0].flDurationInAir = 99
    --         ffi.cast("CCSGOPlayerAnimationState_534535_t**", ffi_helpers.get_entity_address(localplayer:get_index()) + offset_value)[0].flHitGroundCycle = 0
    --         ffi.cast("CCSGOPlayerAnimationState_534535_t**", ffi_helpers.get_entity_address(localplayer:get_index()) + offset_value)[0].bHitGroundAnimation = false
    --     end
    --     shared_onground = bOnGround
    --     if bOnGround and not shared_onground then
    --         ffi.cast("CCSGOPlayerAnimationState_534535_t**", ffi_helpers.get_entity_address(localplayer:get_index()) + offset_value)[0].flDurationInAir = 0.5
    --     end
    --     ffi.cast("float*", ffi_helpers.get_entity_address(localplayer:get_index()) + 10100)[0] = 0
    --     antiaim_ref.leg_movement:SetInt(math.random(1, 2))
    -- end

    function MT.Draw()
        MT.Misc()
        -- local anim_breaker = categorys.Misc.anim_breaker:GetValue()
        -- if anim_breaker then
        --     MT.anim_breaker()
        -- end
        local is_resolver = categorys.RageBot.resolver:GetValue()
        if is_resolver then
            MT.Resolver()
        end
        local antiaims_is_enable = categorys.AntiAim.antiaims_enable:GetValue()
        if antiaims_is_enable then
            MT.ManualAA()
        end
        local if_indicator = categorys.Indicators.indicator_enable:GetValue()
        if if_indicator then
            local get_wm_color = categorys.Indicators.WM_color:GetColor()
            local s_x = MT.engine.get_screen_width()
            local s_y = MT.engine.get_screen_height()
            local localplayer = MT.entitylist.get_local_player()
            local get_time = os.date("%X", os.time())
            local get_fps = MT.get_abs_fps()
            local get_ping = MT.globals.get_ping()
            local get_tickrate = math.floor(1.0 / MT.globals.get_intervalpertick())
            MT.render.draw_image(s_x - 55, 0, s_x - 5, 46, Mtlogo)
            if MT.engine.is_connected() then
                local get_velocity = 0
                if localplayer then
                    if localplayer:get_health() ~= 0 then 
                        get_velocity = math.floor(localplayer:get_velocity():length_2d())
                    end
                end
                MT.render.draw_text(ind_font, s_x - 85, 25, MT.color.new(255, 255, 255, 255), "tick")
                MT.render.draw_text(ind_font, s_x - 87, 11, get_wm_color, MT.Spec_c(get_tickrate))
                MT.render.draw_text(ind_font, s_x - 125, 25, MT.color.new(255, 255, 255, 255), "speed")
                MT.render.draw_text(ind_font, s_x - 120, 11, get_wm_color, MT.Spec_c(get_velocity))
                MT.render.draw_text(ind_font, s_x - 155, 25, MT.color.new(255, 255, 255, 255), "ping")
                MT.render.draw_text(ind_font, s_x - 155, 11, get_wm_color, MT.Spec_c(get_ping))
                MT.render.draw_text(ind_font, s_x - 185, 25, MT.color.new(255, 255, 255, 255), "fps")
                MT.render.draw_text(ind_font, s_x - 188, 11, get_wm_color, MT.Spec_c(get_fps))
                MT.render.draw_text(ind_font, s_x - 260, 25, MT.color.new(255, 255, 255, 255), "current time")
                MT.render.draw_text(ind_font, s_x - 255, 11, get_wm_color, get_time)
            else
                MT.render.draw_text(ind_font, s_x - 85, 25, MT.color.new(255, 255, 255, 255), "fps")
                MT.render.draw_text(ind_font, s_x - 88, 11, get_wm_color, MT.Spec_c(get_fps))
                MT.render.draw_text(ind_font, s_x - 160, 25, MT.color.new(255, 255, 255, 255), "current time")
                MT.render.draw_text(ind_font, s_x - 155, 11, get_wm_color, get_time)
            end
            if not localplayer then return end
            if localplayer:get_health() == 0 then return end
            local color = categorys.Indicators.min_color:GetColor()
            local sec_color = categorys.Indicators.sec_color:GetColor()
            local dm_color = categorys.Indicators.dm_color:GetColor()
            local fdesync = MT.FakeDesync(localplayer)
            local screen_x = MT.engine.get_screen_width() / 2
            local screen_y = MT.engine.get_screen_height() / 2
            MT.render.draw_text(mt_font, screen_x - 26, screen_y, color, "MADTECH")
            MT.render.draw_rect_filled(screen_x, screen_y + 15, fdesync - 10, 7, MT.color.new(0, 0, 0, 80))
            MT.render.draw_rect_filled(screen_x - fdesync + 11, screen_y + 15, fdesync - 11, 7, MT.color.new(0, 0, 0, 80))
            MT.render.draw_rect_filled(screen_x, screen_y + 17, fdesync - 12, 3, sec_color)
            MT.render.draw_rect_filled(screen_x - fdesync + 13, screen_y + 17, fdesync - 13, 3, sec_color)
            local activeweapon = MT.entitylist.get_weapon_by_player(localplayer)
            if activeweapon then
                local is_mindamge = ragebot_ref.mindamage_key:GetBindState()
                local weapon_name = activeweapon:get_class_name()
                if weapon_damages[weapon_name] then
                    local damage = weapon_damages[weapon_name].damage
                    local mindamage = weapon_damages[weapon_name].mindamage
                    if not is_mindamge then
                        MT.render.draw_text(ind_font, screen_x + 5, screen_y - 13, dm_color, tostring(damage:GetInt()))
                    else
                        MT.render.draw_text(ind_font, screen_x + 5, screen_y - 13, dm_color, tostring(mindamage:GetInt()))
                    end
                end
            end
        end
    end
    MT.client.add_callback('on_shot', MT.Resolved)
    MT.client.add_callback('on_paint', MT.Draw)
    MT.client.add_callback('create_move', MT.Main)
end

MT.console.execute("clear")
print(string.format("Welcome back, %s", username))
MT.console.execute("clear")
MT.print(string.format("Welcome back, %s", username), MT.color.new(0, 255, 0, 255))
MT.Launching()