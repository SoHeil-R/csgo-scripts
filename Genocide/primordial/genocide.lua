
local math_floor, math_sqrt, math_fmod, globals_tick_count, globals_real_time, globals_interval_per_tick, globals_cur_time = math.floor, math.sqrt, math.fmod, globals.tick_count, globals.real_time, globals.interval_per_tick, globals.cur_time
local menu_find, menu_add_checkbox, menu_add_selection, menu_add_text, menu_set_group_column, menu_add_separator, menu_add_text_input, menu_add_multi_selection, menu_add_slider, menu_set_group_visibility = menu.find, menu.add_checkbox, menu.add_selection, menu.add_text, menu.set_group_column, menu.add_separator, menu.add_text_input, menu.add_multi_selection, menu.add_slider, menu.set_group_visibility
local entity_get_local_player, engine_get_choked_commands, engine_is_connected, engine_get_latency, client_set_clantag = entity_list.get_local_player, engine.get_choked_commands, engine.is_connected, engine.get_latency, client.set_clantag
local callbacks_add, client_log_screen, input_find_key_bound_to_binding, input_is_key_held = callbacks.add, client.log_screen, input.find_key_bound_to_binding, input.is_key_held
ffi.cdef([[
    typedef int(__thiscall* get_clipboard_text_length)(void*);
    typedef void(__thiscall* set_clipboard_text)(void*, const char*, int);
    typedef void(__thiscall* get_clipboard_text)(void*, int, const char*, int);
]])
local fs = (function()local b=require("ffi")local c,a={},{}a.__index=a;local d="filesystem_stdio.dll"local e="VBaseFileSystem011"local f="VFileSystem017"local function g(d,e,h,i)local j=memory.create_interface(d,e)local k=memory.get_vfunc(j,i)local l,m=pcall(b.typeof,h)if not l then error(m,2)end;local n=b.cast(m,k)or error(h..": invalid typecast")return function(...)return n(b.cast("void***",j),...)end end;c={directory=g("engine.dll","VEngineClient014","const char*(__thiscall*)(void*)",36),readfile=g(d,e,"int (__thiscall*)(void*, void*, int, void*)",0),writefile=g(d,e,"int (__thiscall*)(void*, void const*, int, void*)",1),openfile=g(d,e,"void* (__thiscall*)(void*, const char*, const char*, const char*)",2),closefile=g(d,e,"void (__thiscall*)(void*, void*)",3),getfilesize=g(d,e,"unsigned int (__thiscall*)(void*, void*)",7),fileexists=g(d,e,"bool (__thiscall*)(void*, const char*, const char*)",10),removefile=g(d,f,"void (__thiscall*)(void*, const char*, const char*)",20),renamefile=g(d,f,"bool (__thiscall*)(void*, const char*, const char*, const char*)",21),create_directory=g(d,f,"void (__thiscall*)(void*, const char*, const char*)",22),is_directory=g(d,f,"bool (__thiscall*)(void*, const char*, const char*)",23)}local o={["r"]="r",["w"]="w",["a"]="a",["r+"]="r+",["w+"]="w+",["a+"]="a+",["rb"]="rb",["wb"]="wb",["ab"]="ab",["rb+"]="rb+",["wb+"]="wb+",["ab+"]="ab+"}function a.get_directory()return b.string(c.directory()):gsub("\\csgo","")end;function a.exists(p,q)return c.fileexists(p,q)end;function a.rename(r,s,q)c.renamefile(r,s,q)end;function a.remove(p,q)c.removefile(p,q)end;function a.create_directory(p,q)c.create_directory(p,q)end;function a.is_directory(p,q)return c.is_directory(p,q)end;function a.open(p,t,q)if not o[t]then error("Invalid mode!")end;local self=setmetatable({file=p,mode=t,path_id=q,handle=c.openfile(p,t,q)},a)return self end;function a:getsize()return c.getfilesize(self.handle)end;function a:write(u)c.writefile(u,#u,self.handle)end;function a:read()local v=self:getsize()local w=b.new("char[?]",v+1)c.readfile(w,v,self.handle)return b.string(w)end;function a:close()c.closefile(self.handle)end;return a end)()
local json = (function()local a={_version="0.1.2"}local b;local c={["\\"]="\\\\",["\""]="\\\"",["\b"]="\\b",["\f"]="\\f",["\n"]="\\n",["\r"]="\\r",["\t"]="\\t"}local d={["\\/"]="/"}for e,f in pairs(c)do d[f]=e end;local function g(h)return c[h]or string.format("\\u%04x",h:byte())end;local function i(j)return"null"end;local function k(j,l)local m={}l=l or{}if l[j]then error("circular reference")end;l[j]=true;if rawget(j,1)~=nil or next(j)==nil then local n=0;for e in pairs(j)do if type(e)~="number"then error("invalid table: mixed or invalid key types")end;n=n+1 end;if n~=#j then error("invalid table: sparse array")end;for o,f in ipairs(j)do table.insert(m,b(f,l))end;l[j]=nil;return"["..table.concat(m,",").."]"else for e,f in pairs(j)do if type(e)~="string"then error("invalid table: mixed or invalid key types")end;table.insert(m,b(e,l)..":"..b(f,l))end;l[j]=nil;return"{"..table.concat(m,",").."}"end end;local function p(j)return'"'..j:gsub('[%z\1-\31\\"]',g)..'"'end;local function q(j)if j~=j or j<=-math.huge or j>=math.huge then error("unexpected number value '"..tostring(j).."'")end;return string.format("%.14g",j)end;local r={["nil"]=i,["table"]=k,["string"]=p,["number"]=q,["boolean"]=tostring}b=function(j,l)local s=type(j)local t=r[s]if t then return t(j,l)end;error("unexpected type '"..s.."'")end;function a.encode(j)return b(j)end;local u;local function v(...)local m={}for o=1,select("#",...)do m[select(o,...)]=true end;return m end;local w=v(" ","\t","\r","\n")local x=v(" ","\t","\r","\n","]","}",",")local y=v("\\","/",'"',"b","f","n","r","t","u")local z=v("true","false","null")local A={["true"]=true,["false"]=false,["null"]=nil}local function B(C,D,E,F)for o=D,#C do if E[C:sub(o,o)]~=F then return o end end;return#C+1 end;local function G(C,D,H)local I=1;local J=1;for o=1,D-1 do J=J+1;if C:sub(o,o)=="\n"then I=I+1;J=1 end end;error(string.format("%s at line %d col %d",H,I,J))end;local function K(n)local t=math.floor;if n<=0x7f then return string.char(n)elseif n<=0x7ff then return string.char(t(n/64)+192,n%64+128)elseif n<=0xffff then return string.char(t(n/4096)+224,t(n%4096/64)+128,n%64+128)elseif n<=0x10ffff then return string.char(t(n/262144)+240,t(n%262144/4096)+128,t(n%4096/64)+128,n%64+128)end;error(string.format("invalid unicode codepoint '%x'",n))end;local function L(M)local N=tonumber(M:sub(3,6),16)local O=tonumber(M:sub(9,12),16)if O then return K((N-0xd800)*0x400+O-0xdc00+0x10000)else return K(N)end end;local function P(C,o)local Q=false;local R=false;local S=false;local T;for U=o+1,#C do local V=C:byte(U)if V<32 then G(C,U,"control character in string")end;if T==92 then if V==117 then local W=C:sub(U+1,U+5)if not W:find("%x%x%x%x")then G(C,U,"invalid unicode escape in string")end;if W:find("^[dD][89aAbB]")then R=true else Q=true end else local h=string.char(V)if not y[h]then G(C,U,"invalid escape char '"..h.."' in string")end;S=true end;T=nil elseif V==34 then local M=C:sub(o+1,U-1)if R then M=M:gsub("\\u[dD][89aAbB]..\\u....",L)end;if Q then M=M:gsub("\\u....",L)end;if S then M=M:gsub("\\.",d)end;return M,U+1 else T=V end end;G(C,o,"expected closing quote for string")end;local function X(C,o)local V=B(C,o,x)local M=C:sub(o,V-1)local n=tonumber(M)if not n then G(C,o,"invalid number '"..M.."'")end;return n,V end;local function Y(C,o)local V=B(C,o,x)local Z=C:sub(o,V-1)if not z[Z]then G(C,o,"invalid literal '"..Z.."'")end;return A[Z],V end;local function _(C,o)local m={}local n=1;o=o+1;while 1 do local V;o=B(C,o,w,true)if C:sub(o,o)=="]"then o=o+1;break end;V,o=u(C,o)m[n]=V;n=n+1;o=B(C,o,w,true)local a0=C:sub(o,o)o=o+1;if a0=="]"then break end;if a0~=","then G(C,o,"expected ']' or ','")end end;return m,o end;local function a1(C,o)local m={}o=o+1;while 1 do local a2,j;o=B(C,o,w,true)if C:sub(o,o)=="}"then o=o+1;break end;if C:sub(o,o)~='"'then G(C,o,"expected string for key")end;a2,o=u(C,o)o=B(C,o,w,true)if C:sub(o,o)~=":"then G(C,o,"expected ':' after key")end;o=B(C,o+1,w,true)j,o=u(C,o)m[a2]=j;o=B(C,o,w,true)local a0=C:sub(o,o)o=o+1;if a0=="}"then break end;if a0~=","then G(C,o,"expected '}' or ','")end end;return m,o end;local a3={['"']=P,["0"]=X,["1"]=X,["2"]=X,["3"]=X,["4"]=X,["5"]=X,["6"]=X,["7"]=X,["8"]=X,["9"]=X,["-"]=X,["t"]=Y,["f"]=Y,["n"]=Y,["["]=_,["{"]=a1}u=function(C,D)local a0=C:sub(D,D)local t=a3[a0]if t then return t(C,D)end;G(C,D,"unexpected character '"..a0 .."'")end;function a.decode(C)if type(C)~="string"then error("expected argument of type string, got "..type(C))end;local m,D=u(C,B(C,1,w,true))D=B(C,D,w,true)if D<=#C then G(C,D,"trailing garbage")end;return m end;return a end)()
local base64 = (function()local a,b,c=bit.lshift,bit.rshift,bit.band;local d,e,f,g,h,i,tostring,error,pairs=string.char,string.byte,string.gsub,string.sub,string.format,table.concat,tostring,error,pairs;local j=function(k,l,m)return c(b(k,l),a(1,m)-1)end;local function n(o)local p,q={},{}for r=1,65 do local s=e(g(o,r,r))or 32;if q[s]~=nil then error('invalid alphabet: duplicate character '..tostring(s),3)end;p[r-1]=s;q[s]=r-1 end;return p,q end;local t,u={},{}t['base64'],u['base64']=n('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=')t['base64url'],u['base64url']=n('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_')local v={__index=function(w,x)if type(x)=='string'and x:len()==64 or x:len()==65 then t[x],u[x]=n(x)return w[x]end end}setmetatable(t,v)setmetatable(u,v)local function y(z,p)p=t[p or'base64']or error('invalid alphabet specified',2)z=tostring(z)local A,B,C={},1,#z;local D=C%3;local E={}for r=1,C-D,3 do local F,G,H=e(z,r,r+2)local k=F*0x10000+G*0x100+H;local I=E[k]if not I then I=d(p[j(k,18,6)],p[j(k,12,6)],p[j(k,6,6)],p[j(k,0,6)])E[k]=I end;A[B]=I;B=B+1 end;if D==2 then local F,G=e(z,C-1,C)local k=F*0x10000+G*0x100;A[B]=d(p[j(k,18,6)],p[j(k,12,6)],p[j(k,6,6)],p[64])elseif D==1 then local k=e(z,C)*0x10000;A[B]=d(p[j(k,18,6)],p[j(k,12,6)],p[64],p[64])end;return i(A)end;local function J(K,q)q=u[q or'base64']or error('invalid alphabet specified',2)local L='[^%w%+%/%=]'if q then local M,N;for O,P in pairs(q)do if P==62 then M=O elseif P==63 then N=O end end;L=h('[^%%w%%%s%%%s%%=]',d(M),d(N))end;K=f(tostring(K),L,'')local E={}local A,B={},1;local C=#K;local Q=g(K,-2)=='=='and 2 or g(K,-1)=='='and 1 or 0;for r=1,Q>0 and C-4 or C,4 do local F,G,H,R=e(K,r,r+3)local S=F*0x1000000+G*0x10000+H*0x100+R;local I=E[S]if not I then local k=q[F]*0x40000+q[G]*0x1000+q[H]*0x40+q[R]I=d(j(k,16,8),j(k,8,8),j(k,0,8))E[S]=I end;A[B]=I;B=B+1 end;if Q==1 then local F,G,H=e(K,C-3,C-1)local k=q[F]*0x40000+q[G]*0x1000+q[H]*0x40;A[B]=d(j(k,16,8),j(k,8,8))elseif Q==2 then local F,G=e(K,C-3,C-2)local k=q[F]*0x40000+q[G]*0x1000;A[B]=d(j(k,16,8))end;return i(A)end;return{encode=y,decode=J}end)()
local clipboard = (function()local a=ffi.cast(ffi.typeof("void***"),memory.create_interface("vgui2.dll","VGUI_System010"))local b=ffi.cast("get_clipboard_text_length",a[0][7])local c=ffi.cast("get_clipboard_text",a[0][11])local d=ffi.cast("set_clipboard_text",a[0][9])local e={}e.set=function(f)d(a,f,#f)end;e.get=function()local g=b(a)if g>0 then local h=ffi.new("char[?]",g)c(a,0,h,g*ffi.sizeof("char[?]",g))return ffi.string(h,g-1)end end;return e end)()
local genocide = {
    name = "Genocide",
    username = "Soheil",
    build = "BETA",
    version = "1.0.0",
    path = "GENOCIDE/primordial/",
    callbacks = {}
}

local reference = {
    enable_aa = menu_find("antiaim", "main", "desync", "engine"),
    pitch = menu_find("antiaim", "main", "angles", "pitch"),
    yawbase = menu_find("antiaim", "main", "angles", "yaw base"),
    yawadd = menu_find("antiaim", "main", "angles", "yaw add"),
    rotate = menu_find("antiaim", "main", "angles", "rotate"),
    rotaterange = menu_find("antiaim", "main", "angles", "rotate range"),
    rotatespeed = menu_find("antiaim", "main", "angles", "rotate speed"),
    jittermode = menu_find("antiaim", "main", "angles", "jitter mode"),
    jittertype = menu_find("antiaim", "main", "angles", "jitter type"),
    jitteradd = menu_find("antiaim", "main", "angles", "jitter add"),
    bodylean = menu_find("antiaim", "main", "angles", "body lean"),
    bodyleanvalue = menu_find("antiaim", "main", "angles", "body lean value"),
    bodyleanjitter = menu_find("antiaim", "main", "angles", "body lean jitter"),
    bodyleanmoving = menu_find("antiaim", "main", "angles", "moving body lean"),
    extendedangle = menu_find("antiaim", "main", "extended angles", "enable"),
    extended_moving = menu_find("antiaim", "main", "extended angles", "enable while moving"),
    extended_pitch = menu_find("antiaim", "main", "extended angles", "pitch"),
    extended_type = menu_find("antiaim", "main", "extended angles", "type"),
    extended_offset = menu_find("antiaim", "main", "extended angles", "offset"),
    extended_jitter = menu_find("antiaim", "main", "extended angles", "jitter"),
    side = menu_find("antiaim", "main", "desync", "stand", "side"),
    defaultside = menu_find("antiaim", "main", "desync", "stand", "default side"),
    leftamount = menu_find("antiaim", "main", "desync", "stand", "left amount"),
    rightamount = menu_find("antiaim", "main", "desync", "stand", "right amount"),
    antibruteforce = menu_find("antiaim", "main", "desync","anti bruteforce"),
    onshot = menu_find("antiaim", "main", "desync","on shot"),
    override_moving = menu_find("antiaim", "main", "desync", "move", "override stand#move"),
    override_slowwalk = menu_find("antiaim", "main", "desync", "move", "override stand#slow walk"),
    slowwalk = menu_find("misc", "main", "movement", "slow walk"),
    maxbodylean = menu_find("misc", "utility", "server settings", "max body lean"),
    fakelag = menu_find("antiaim", "main", "fakelag", "amount"),
    breaklag_compensation = menu_find("antiaim", "main", "fakelag", "break lag compensation"),
    roll_resolver = menu_find("aimbot", "general", "aimbot", "body lean resolver"),
    doubletap = menu_find("aimbot", "general", "exploits", "Doubletap", "enable"),
    hideshot = menu_find("aimbot", "general", "exploits", "hideshots", "enable"),
    autopeek = menu_find("aimbot", "general", "misc", "autopeek"),
    scout_autostop = menu_find("aimbot", "scout", "accuracy", "options"),
    scout_delayshot = menu_find("aimbot", "scout", "accuracy", "Delay Shot"),
    legslide = menu_find("antiaim", "main", "general", "leg slide"),
    sv_maxusrcmdprocessticks = cvars.sv_maxusrcmdprocessticks,
    cl_clock_correction = cvars.cl_clock_correction,
    cl_clock_correction_amount = cvars.cl_clock_correction_adjustment_max_amount,
    cl_clock_correction_offset = cvars.cl_clock_correction_adjustment_max_offset
}

local function main()
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
                callbacks_add(e_callbacks[k], r.callback)
            end
        end
    end

    local lastTag = nil
    local function set_clantag(clantag)
        if clantag == lastTag then return end
        lastTag = clantag
        client_set_clantag(clantag or "")
    end

    local function build_tag(tag)
        local ret = {' '}
        for i = 1, #tag do
            table.insert(ret, tag:sub(1, i))
        end
        for i = #ret - 1, 1, -1 do
            table.insert(ret, ret[i])
        end
        return ret
    end

    local clantag_isrunning = false
    local genocide_clantag = build_tag(string.format("  %s  ", genocide.name:upper()))
    local function tag_animation(switch)
        if switch then
            if not engine_is_connected() then return end
            clantag_isrunning = true
            local tickinterval = globals_interval_per_tick()
            local tickcount = globals_tick_count()
            local latency = engine_get_latency() / tickinterval
            local tickcount_predict = tickcount + latency
            local key = math_floor(math_fmod(tickcount_predict / 40, #genocide_clantag + 1) + 1)
            set_clantag(genocide_clantag[key])
        elseif clantag_isrunning then
            clantag_isrunning = false
            set_clantag("")
        end
    end

    local function add_keybind(group, name, bind)
        local checkbox = menu_add_checkbox(group, name)
        local keybind = checkbox:add_keybind(bind)
        return checkbox, keybind
    end

    local function get_velocity()
        local localplayer = entity_get_local_player()
        if not localplayer then return 0 end
        local x, y, z = localplayer:get_prop("m_vecVelocity").x, localplayer:get_prop("m_vecVelocity").y, localplayer:get_prop("m_vecVelocity").z
        return math_floor(math_sqrt(x*x + y*y + z*z))
    end

    local function is_exploit()
        return reference.hideshot[2]:get() or reference.doubletap[2]:get()
    end


    function math.tickcount(value)
        return (math_floor(globals_cur_time() * 100) % value) + 1
    end

    local delays = {}
    function math.delay(index, value)
        if delays[index] then
            if (globals_real_time() - delays[index]) * 1000 >= value then
                delays[index] = globals_real_time()
                return true
            else
                return false
            end
        else
            delays[index] = globals_real_time()
            return true
        end
    end

    local data = {
        active = "Default",
        list = {"Default"},
        autoload = false,
    }

    local function encode(value)
        return "GENOCIDE_PRIMORDIAL_"..base64.encode(value)
    end

    local function decode(value)
        value = value:gsub("GENOCIDE_PRIMORDIAL_", "")
        return base64.decode(value)
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

    local function savedata()
        local database = fs.open(genocide.path.."database.gc", "wb+")
        database:write(encode(json.encode(data)))
        database:close()
    end

    local function loaddata()
        local database = fs.open(genocide.path.."database.gc", "rb+")
        data = json.decode(decode(database:read()))
        database:close()
        return data
    end

    fs.create_directory(genocide.path)
    if not fs.exists(genocide.path.."database.gc") then
        local database = fs.open(genocide.path.."database.gc", "wb+")
        database:write(encode(json.encode(data)))
        database:close()
    else
        loaddata()
    end

    local mc = {"AntiAim", "Ragebot", "Visual", "Misc"}
    local antiaim_types = {"Exploit", "Fakelag"}
    local antiaim_states = {"Global", "Standing", "Moving", "Air", "Air-crouch", "Slowwalk", "Crouching", "On key"}
    local antiaim_conditions = {"Global", "Terrorist", "Counter terrorist"}
    local antiaim_preset = {}
    local categorys = menu_add_selection(genocide.name, "Tabs", mc)
    menu_add_text("Config System", string.format("User: %s | %s", user.name, user.uid))
    menu_add_text("Config System", string.format("Build: %s", genocide.build))
    menu_add_text("Config System", string.format("Version: %s", genocide.version))
    menu_set_group_column("Config System", 3)
    menu_add_separator("Config System")
    menu_add_separator(genocide.name)
    local configname = menu_add_text_input("Config System", "Name")
    local configs = menu_add_selection("Config System", "Configs", data.list)

    menu.add_button("Config System", "Save", function ()
        local selectedcfg = configs:get()
        local cfginput = configname:get()
        local cfgname = data.list[selectedcfg]
        local cfgdata = save_config()
        data.autoload = startup:get()
        local database = fs.open(string.format("%s%s.gc", genocide.path, cfgname), "wb+")
        if #cfginput > 0 then
            database = fs.open(string.format("%s%s.gc", genocide.path, cfginput), "wb+")
            cfgname = cfginput
            local m, k = table.exist(data.list, cfginput)
            if not m then
                table.insert(data.list, cfginput)
                configs:set_items(data.list)
                configs:set(#data.list)
                database:write(encode(json.encode(cfgdata)))
            else
                configs:set(k)
                database:write(encode(json.encode(cfgdata)))
            end
        else
            database:write(encode(json.encode(cfgdata)))
        end
        database:close()
        savedata()
        client_log_screen(string.format("Genocide: (%s) successfully saved.", cfgname))
    end)

    menu.add_button("Config System", "Load", function ()
        local selectedcfg = configs:get()
        local cfgname = data.list[selectedcfg]
        local database = fs.open(string.format("%s%s.gc", genocide.path, cfgname), "rb+")
        local configdata = json.decode(decode(database:read()))
        database:close()
        if table.count(configdata) > 0 then
            data.active = cfgname
            savedata()
            load_config(configdata)
            client_log_screen(string.format("Genocide: config (%s) successfully loaded.", cfgname))
        else
            client_log_screen(string.format("Genocide|Error: Failed to load config!"))
        end
    end)

    menu.add_button("Config System", "Delete", function ()
        local selectedcfg = configs:get()
        local cfgname = data.list[selectedcfg]
        if #data.list > 1 then
            table.remove(data.list, selectedcfg)
            configs:set_items(data.list)
            savedata()
            fs.remove(string.format("%s%s.gc", genocide.path, cfgname))
            client_log_screen(string.format("Genocide: config (%s) successfully deleted.", cfgname))
        else
            client_log_screen(string.format("Genocide|Error: You cant delete all configs!"))
        end
    end)

    menu.add_button("Config System", "Export", function ()
        local selectedcfg = configs:get()
        local cfgname = data.list[selectedcfg]
        local database = fs.open(string.format("%s%s.gc", genocide.path, cfgname), "rb+")
        local sconfig = database:read()
        database:close()
        clipboard.set(sconfig)
        client_log_screen(string.format("Genocide: config (%s) successfully exported.", cfgname))
    end)

    menu.add_button("Config System", "Import", function ()
        local configdata = clipboard.get()
        if #configdata > 20 then
            configdata = json.decode(decode(configdata))
            load_config(configdata)
            client_log_screen(string.format("Genocide: config successfully imported!"))
        else
            client_log_screen(string.format("Genocide|Error: Failed to load config!"))
        end
    end)
    startup = menu_add_checkbox("Config System", "Load on startup", data.autoload)

    local IS_READY = false
    client.delay_call(function()
        IS_READY = true
        if data.autoload then
            local cfgname = data.active
            local exist, key = table.exist(data.list, cfgname)
            if exist then
                local database = fs.open(string.format("%s%s.gc", genocide.path, cfgname), "rb+")
                local configdata = json.decode(decode(database:read()))
                database:close()
                configs:set(key)
                load_config(configdata)
                client_log_screen(string.format("Genocide: config (%s) successfully loaded.", cfgname))
            end
        end
    end, 1)

    local ui = {
        [mc[1]] = {
            enable = menu_add_checkbox(genocide.name, "Enable Anti-aims"),
            animation =  menu_add_multi_selection(genocide.name, "Animation Breaker", {"Follow direction", "Static legs in air", "Zero pitch on land", "Move lean", "Moonwalk", "Moonwalk on air"}),
            custom_aa = menu_add_selection("Custom Anti-aim", "State", antiaim_states),
            builder = {}
        },
        [mc[2]] = {
            idealtick = menu_add_checkbox(genocide.name, "Idealtick"),
            delayshot = menu_add_multi_selection(genocide.name, "Delay Shot", {"Lethal", "Safe"}),
            autostop = menu_add_multi_selection(genocide.name, "Autostop", {"Full Stop", "Stop Between Shots", "Early", "Dont Stop In Fire", "Delay Shot Until Fully Accurate", "Crouch"})
        },
        [mc[3]] = {
        },
        [mc[4]] = {
            clantag = menu_add_checkbox(genocide.name, "Clantag"),
        }
    }
    menu_set_group_column("Custom Anti-aim", 2)

    for k,v in pairs(antiaim_states) do
        local build = ui[mc[1]].builder
        build[v] = {}
        build.binds = {}
        antiaim_preset[v] = {}
        build[v].conditions = menu_add_selection("Custom Anti-aim", ""..v.." - Conditions", antiaim_conditions)
        build[v].type = menu_add_selection("Custom Anti-aim", ""..v.." - Types", antiaim_types)
        for c, d in pairs(antiaim_conditions) do
            build[v][d] = {}
            antiaim_preset[v][d] = {}
            for _,z in pairs(antiaim_types) do
                local cond_txt = (d == "Global" and "" or (d == "Terrorist" and "TR" or "CT").." - ")
                build[v][d][z] = {}
                antiaim_preset[v][d][z] = {}
                build[v][d][z].enable = menu_add_checkbox(v.." - "..cond_txt..z, "Enable")
                if v == "On key" then
                    if not build.binds.onkey then
                        build.binds.onkey_l = menu_add_text("Custom Anti-aim", "Onkey")
                        build.binds.onkey = build.binds.onkey_l:add_keybind("on key")
                    end
                end
                local pitch_t = {"Disabled", "Down", "Up", "Zero", "Jitter", "Custom"}
                if z == "Fakelag" then
                    table.insert(pitch_t, "Fake Up")
                else
                    table.insert(pitch_t, "Defensive")
                end
                build[v][d][z].pitch = menu_add_selection(v.." - "..cond_txt..z, "Pitch", pitch_t)
                if z == "Exploit" then
                    build[v][d][z].defensive_pitch = menu_add_selection(v.." - "..cond_txt..z, "Defensive Pitch", {"Up", "Zero"})
                    build[v][d][z].pitch_delay_type = menu_add_selection(v.." - "..cond_txt..z, "Delay Types", {"Tickbase", "Realtime", "3-WAY"})
                    build[v][d][z].pitch_delay_t = menu_add_slider(v.." - "..cond_txt..z, "Delay", 1, 64, nil, nil, "t")
                    build[v][d][z].pitch_delay_r = menu_add_slider(v.." - "..cond_txt..z, "Delay", 1, 1000, nil, nil, "ms")
                end
                build[v][d][z].custom_pitch = menu_add_slider(v.." - "..cond_txt..z, "Custom Pitch", -89, 89, nil, nil, "°")
                build[v][d][z].yawbase = menu_add_selection(v.." - "..cond_txt..z, "Yaw Base", {"Disabled", "Viewangle", "At Target (Crosshair)", "At Target (Distance)", "Velocity"})
                build[v][d][z].yawadd = menu_add_slider(v.." - "..cond_txt..z, "Yaw Add", -180, 180, nil, nil, "°")
                build[v][d][z].rotate = menu_add_checkbox(v.." - "..cond_txt..z, "Rotate")
                build[v][d][z].rotaterange = menu_add_slider(v.." - "..cond_txt..z, "Rotate Range", 0, 360, nil, nil, "°")
                build[v][d][z].rotatespeed = menu_add_slider(v.." - "..cond_txt..z, "Rotate Speed", 0, 100, nil, nil, "%")
                build[v][d][z].jittermode = menu_add_selection(v.." - "..cond_txt..z, "Jitter Mode", {"Disabled", "Static", "Random", "3-WAY"})
                build[v][d][z].jittertype = menu_add_selection(v.." - "..cond_txt..z, "Jitter Type", {"Offset", "Center"})
                build[v][d][z].jitteradd = menu_add_slider(v.." - "..cond_txt..z, "Jitter Add", -180, 180, nil, nil, "°")
                build[v][d][z].jitterdelay = menu_add_slider(v.." - "..cond_txt..z, "Delay", 1, 64, nil, nil, "t")
                for i=1, 3 do
                    build[v][d][z]['offset_'..i] = menu_add_slider(v.." - "..cond_txt..z, "Offset ["..i.."]", -180, 180, nil, nil, "°")
                end
                build[v][d][z].inverter = menu_add_checkbox(v.." - "..cond_txt..z, "Inverter")
                build[v][d][z].leftlimit = menu_add_slider(v.." - "..cond_txt..z, "Left limit", 0, 100, nil, nil, "%")
                build[v][d][z].rightlimit = menu_add_slider(v.." - "..cond_txt..z, "Right limit", 0, 100, nil, nil, "%")
                build[v][d][z].bodyyaw = menu_add_selection(v.." - "..cond_txt..z, "Body Yaw", {"Disabled", "Jitter", "Body Sway"})
                if z == "Fakelag" then
                    build[v][d][z].options = menu_add_multi_selection(v.." - "..cond_txt..z, "Options", {"Extended Desync", "Anti Bruteforce"})
                else
                    build[v][d][z].options = menu_add_multi_selection(v.." - "..cond_txt..z, "Options", {"Defensive", "Anti Bruteforce"})
                    build[v][d][z].defensive_delay = menu_add_slider(v.." - "..cond_txt..z, "Defensive Delay", 1, 64, nil, nil, "t")
                end
                build[v][d][z].freestanding = menu_add_selection(v.." - "..cond_txt..z, "Freestanding", {"Off", "Peek Fake", "Peek Real"})
                build[v][d][z].onshot = menu_add_selection(v.." - "..cond_txt..z, "On Shot", {"Disabled", "Opposite", "Same Side", "Random"})
                build[v][d][z].bodylean = menu_add_selection(v.." - "..cond_txt..z, "Body Lean", {"Disabled", "Static", "Static Jitter", "Random Jitter", "Sway", "Override"})
                build[v][d][z].bodylean_static = menu_add_slider(v.." - "..cond_txt..z, "Body Lean Value", -50, 50, nil, nil, "°")
                build[v][d][z].bodylean_jitter = menu_add_slider(v.." - "..cond_txt..z, "Body Lean Jitter", 0, 100, nil, nil, "%")
                build[v][d][z].bodylean_override = menu_add_slider(v.." - "..cond_txt..z, "Body Lean Value", -100, 100, nil, nil, "°")
                build[v][d][z].maxbodylean = menu_add_slider(v.." - "..cond_txt..z, "Max Body Lean", 0, 180, nil, nil, "°")
                if z == "Fakelag" then
                    build[v][d][z].extendedangle = menu_add_checkbox(v.." - "..cond_txt..z, "Extended Angles")
                    build[v][d][z].extendedpitch = menu_add_slider(v.." - "..cond_txt..z, "Pitch", -89, 89, nil, nil, "°")
                    build[v][d][z].extendedtype = menu_add_selection(v.." - "..cond_txt..z, "Type", {"Static", "Static Jitter", "Random Jitter", "Sway"})
                    build[v][d][z].extendedoffset = menu_add_slider(v.." - "..cond_txt..z, "Offset", -180, 180, nil, nil, "°")
                    build[v][d][z].extendedjitter = menu_add_slider(v.." - "..cond_txt..z, "Jitter", 0, 100, nil, nil, "%")
                    build[v][d][z].extendedfakelimit = menu_add_slider(v.." - "..cond_txt..z, "Fakelag Limit", 0, 15, nil, nil, "t")
                end
            end
        end
    end

    local function menu_update()
        local selected = categorys:get()
        if mc[selected] == mc[1] then
            local aa_enable = ui[mc[1]].enable:get()
            local state = ui[mc[1]].custom_aa:get()
            for k,v in pairs(ui[mc[1]]) do
                if k ~= "enable" then
                    if type(v) ~= "table" then
                        v:set_visible(aa_enable)
                    else
                        for z,x in pairs(v) do
                            if x.type then
                                local antiaim_type = antiaim_types[x.type:get()]
                                local antiaim_condition = antiaim_conditions[x.conditions:get()]
                                x.type:set_visible(aa_enable and antiaim_states[state] == z)
                                x.conditions:set_visible(aa_enable and antiaim_states[state] == z)
                                for c,d in pairs(antiaim_conditions) do
                                    for e,t in pairs(antiaim_types) do
                                        local cond_txt = (d == "Global" and "" or (d == "Terrorist" and "TR" or "CT").." - ")
                                        menu_set_group_visibility(z.." - "..cond_txt..t, aa_enable and antiaim_states[state] == z and d == antiaim_condition and t == antiaim_type)
                                        menu_set_group_column(z.." - "..cond_txt..t, 2)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            for k,v in pairs(ui[mc[1]].builder) do
                if antiaim_states[state] == k then
                    local antiaim_type = antiaim_types[v.type:get()]
                    local antiaim_condition = antiaim_conditions[v.conditions:get()]
                    if type(v) == "table" then
                        local enable = v[antiaim_condition][antiaim_type].enable:get()
                        ui[mc[1]].builder.binds.onkey:set_visible(k == "On key")
                        ui[mc[1]].builder['binds'].onkey_l:set_visible(k == "On key")
                        v[antiaim_condition][antiaim_type].pitch:set_visible(enable)
                        local pitch = v[antiaim_condition][antiaim_type].pitch:get()
                        if antiaim_type == "Exploit" then
                            v[antiaim_condition][antiaim_type].defensive_pitch:set_visible(enable and pitch == 7)
                            v[antiaim_condition][antiaim_type].pitch_delay_type:set_visible(enable and pitch == 7)
                            local delay_types = v[antiaim_condition][antiaim_type].pitch_delay_type:get()
                            v[antiaim_condition][antiaim_type].pitch_delay_t:set_visible(enable and pitch == 7 and delay_types == 1)
                            v[antiaim_condition][antiaim_type].pitch_delay_r:set_visible(enable and pitch == 7 and delay_types == 2)
                        end
                        v[antiaim_condition][antiaim_type].custom_pitch:set_visible(enable and pitch == 6)
                        v[antiaim_condition][antiaim_type].yawbase:set_visible(enable)
                        local yawbase = v[antiaim_condition][antiaim_type].yawbase:get()
                        v[antiaim_condition][antiaim_type].yawadd:set_visible(enable and yawbase ~= 1)
                        v[antiaim_condition][antiaim_type].rotate:set_visible(enable)
                        local rotate = v[antiaim_condition][antiaim_type].rotate:get()
                        v[antiaim_condition][antiaim_type].rotaterange:set_visible(enable and rotate)
                        v[antiaim_condition][antiaim_type].rotatespeed:set_visible(enable and rotate)
                        v[antiaim_condition][antiaim_type].jittermode:set_visible(enable)
                        local jittermode = v[antiaim_condition][antiaim_type].jittermode:get()
                        v[antiaim_condition][antiaim_type].jittertype:set_visible(enable and jittermode ~= 1 and jittermode ~= 4)
                        v[antiaim_condition][antiaim_type].jitteradd:set_visible(enable and jittermode ~= 1 and jittermode ~= 4)
                        v[antiaim_condition][antiaim_type].jitterdelay:set_visible(enable and jittermode == 4)
                        for i=1, 3 do
                            v[antiaim_condition][antiaim_type]['offset_'..i]:set_visible(enable and jittermode == 4)
                        end
                        v[antiaim_condition][antiaim_type].inverter:set_visible(enable)
                        v[antiaim_condition][antiaim_type].leftlimit:set_visible(enable)
                        v[antiaim_condition][antiaim_type].rightlimit:set_visible(enable)
                        v[antiaim_condition][antiaim_type].bodyyaw:set_visible(enable)
                        v[antiaim_condition][antiaim_type].options:set_visible(enable)
                        if antiaim_type == "Exploit" then
                            v[antiaim_condition][antiaim_type].defensive_delay:set_visible(enable and v[antiaim_condition][antiaim_type].options:get(1))
                        end
                        v[antiaim_condition][antiaim_type].freestanding:set_visible(enable)
                        v[antiaim_condition][antiaim_type].onshot:set_visible(enable)
                        v[antiaim_condition][antiaim_type].bodylean:set_visible(enable)
                        local bodylean = v[antiaim_condition][antiaim_type].bodylean:get()
                        v[antiaim_condition][antiaim_type].bodylean_static:set_visible(enable and bodylean == 2)
                        v[antiaim_condition][antiaim_type].bodylean_jitter:set_visible(enable and (bodylean == 3 or bodylean == 4))
                        v[antiaim_condition][antiaim_type].bodylean_override:set_visible(enable and bodylean == 6)
                        v[antiaim_condition][antiaim_type].maxbodylean:set_visible(enable and bodylean == 6)
                        if antiaim_type == "Fakelag" then
                            v[antiaim_condition][antiaim_type].extendedangle:set_visible(enable)
                            local extendedangle = v[antiaim_condition][antiaim_type].extendedangle:get()
                            v[antiaim_condition][antiaim_type].extendedpitch:set_visible(enable and extendedangle)
                            v[antiaim_condition][antiaim_type].extendedtype:set_visible(enable and extendedangle)
                            v[antiaim_condition][antiaim_type].extendedfakelimit:set_visible(enable and extendedangle)
                            local extendedtype = v[antiaim_condition][antiaim_type].extendedtype:get()
                            v[antiaim_condition][antiaim_type].extendedoffset:set_visible(enable and extendedangle and extendedtype == 1)
                            v[antiaim_condition][antiaim_type].extendedjitter:set_visible(enable and extendedangle and (extendedtype == 2 or extendedtype == 3))
                        end
                    end
                end
            end
        elseif mc[selected] == mc[2] then
            local idealtick = ui[mc[2]].idealtick:get()
            ui[mc[2]].delayshot:set_visible(idealtick)
            ui[mc[2]].autostop:set_visible(idealtick)
        end
    end

    _LAST_CATEGORY = nil
    local function category_update()
        local selected = categorys:get()
        if mc[selected] ~= _LAST_CATEGORY then
            _LAST_CATEGORY = mc[selected]
            for k,v in pairs(mc) do
                for x,z in pairs(ui[v]) do
                    if type(z) ~= "table" then
                        z:set_visible(v == mc[selected])
                    else
                        for a,s in pairs(z) do
                            for c,t in pairs(s) do
                                if type(t) == "table" then
                                    for e,m in pairs(t) do
                                        for i,a in pairs(m) do
                                            if type(a) ~= "table" then
                                                a:set_visible(v == mc[selected])
                                            else
                                                for h,b in pairs(a) do
                                                    b:set_visible(v == mc[selected])
                                                end
                                            end
                                        end
                                    end
                                else
                                    t:set_visible(v == mc[selected])
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    local function get_multiselection(menu, rtn)
        local multi_selection = {}
        if rtn then
            for k,v in pairs(menu:get_items()) do
                if menu:get(v) then
                    table.insert(multi_selection, v)
                end
            end
        else
            for i=1, #menu:get_items() do
                multi_selection[i] = menu:get(i)
            end
        end
        return multi_selection
    end

    function save_config()
        local data = {}
        for k,v in pairs(ui) do
            data[k] = {}
            for z,x in pairs(v) do
                if type(x) ~= "table" then
                    if z ~= "autostop" and z ~= "delayshot" and z ~= "animation" then
                        data[k][z] = x:get()
                    else
                        data[k][z] = get_multiselection(x)
                    end
                else
                    data[k][z] = {}
                    for s,m in pairs(x) do
                        data[k][z][s] = {}
                        for c,d in pairs(m) do
                            if type(d) ~= "table" then
                                data[k][z][s][c] = d:get()
                            else
                                data[k][z][s][c] = {}
                                for e,t in pairs(d) do
                                    data[k][z][s][c][e] = {}
                                    for i,q in pairs(t) do
                                        if i == "options" then
                                            data[k][z][s][c][e][i] = get_multiselection(q)
                                        else
                                            data[k][z][s][c][e][i] = q:get()
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
            for z,x in pairs(v) do
                if type(x) ~= "table" then
                    if ui[k][z] then
                        ui[k][z]:set(x)
                    end
                elseif z == "autostop" or z == "delayshot" or z == "animation" then
                    for ww,ee in pairs(x) do
                        ui[k][z]:set(ww, ee)
                    end
                else
                    for q,w in pairs(x) do
                        if q ~= "binds" then
                            for e,r in pairs(w) do
                                if type(r) ~= "table" then
                                    ui[k][z][q][e]:set(r)
                                else
                                    for y,u in pairs(r) do
                                        for xe,t in pairs(u) do
                                            if xe == "options" then
                                                if type(t) == "table" then
                                                    for hw,xw in pairs(t) do
                                                        ui[k][z][q][e][y][xe]:set(hw, xw)
                                                    end
                                                    antiaim_preset[q][e][y][xe] = get_multiselection(ui[k][z][q][e][y][xe], true)
                                                end
                                            else
                                                pcall(function(menu, args)
                                                    menu:set(args)
                                                end, unpack({ui[k][z][q][e][y][xe], t}))
                                                antiaim_preset[q][e][y][xe] = t
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
    end

    local function get_preset()
        for k,v in pairs(ui[mc[1]].builder) do
            for c,d in pairs(v) do
                if type(d) == "table" then
                    for e,p in pairs(d) do
                        for i,t in pairs(p) do
                            if i == "options" then
                                antiaim_preset[k][c][e][i] = get_multiselection(t, true)
                            else
                                antiaim_preset[k][c][e][i] = t:get()
                            end
                        end
                    end
                end
            end
        end
    end

    local function is_moving()
        local movements = {"FORWARD", "BACK", "MOVELEFT", "MOVERIGHT"}
        for k,v in pairs(movements) do
            if input_is_key_held(input_find_key_bound_to_binding(v)) then
                return true
            end
        end
        return false
    end

    local function get_state()
        local velocity = get_velocity()
        local localplayer = entity_get_local_player()
        local ON_GROUND = localplayer:has_player_flag(e_player_flags.ON_GROUND)
        local air_key = input_find_key_bound_to_binding("jump")
        local speed_key = input_find_key_bound_to_binding("speed")
        local crouch_key = input_find_key_bound_to_binding("duck")
        local slow, slow_key = unpack(reference.slowwalk)
        local onkey = ui[mc[1]].builder['binds'].onkey:get()
        if onkey then return "On key" end
        if input_is_key_held(air_key) and input_is_key_held(crouch_key) and not ON_GROUND then return "Air-crouch" end
        if input_is_key_held(air_key) and not ON_GROUND then return "Air" end
        if input_is_key_held(crouch_key) then return "Crouching" end
        if input_is_key_held(speed_key) and slow_key:get() then return "Slowwalk" end
        if velocity > 1 then
            return "Moving"
        else
            return "Standing"
        end
    end
    local history = {}
    local history_t = 1
    function genocide.update(index, data)
        if not history[index] then
            history[index] = {data = data, time = globals_real_time()}
            reference[index]:set(data)
        else
            if (globals_real_time() - history[index].time) >= history_t then
                history[index] = {data = nil, time = 0}
            end
            if history[index].data ~= data then
                history[index] = {data = data, time = globals_real_time()}
                reference[index]:set(data)
            end
        end
    end

    local g_antiaim = {
        ex_desync = false,
        ex_move = 0.00001,
        ways = 1,
        startway = true
    }
    local function extended_desync(cmd)
        if g_antiaim.ex_desync then
            local localplayer = entity_get_local_player()
            local velocity = get_velocity()
            if velocity > 88 then return end
            if localplayer:get_prop("m_MoveType") == 9 then return end
            local in_back = cmd:has_button(e_cmd_buttons.BACK)
            local in_forward = cmd:has_button(e_cmd_buttons.FORWARD)
            if in_back or in_forward then return end
            cmd:add_button(e_cmd_buttons.FORWARD)
            cmd.move.x = g_antiaim.ex_move
        end
    end

    local function antiaim_update(ctx, data, state)
        if data then
            local localplayer = entity_get_local_player()
            local get_team = localplayer:get_prop("m_iTeamNum") == 2 and "Terrorist" or "Counter terrorist"
            local get_exploit = is_exploit() and "Exploit" or "Fakelag"
            --local is_enable = ui[mc[1]].builder[state][get_exploit].enable:get()
            if data[get_team][get_exploit].enable then
                data = data[get_team][get_exploit]
            elseif data['Global'][get_exploit].enable then
                data = data['Global'][get_exploit]
            else
                if antiaim_preset['Global'][get_team][get_exploit].enable then
                    data = antiaim_preset['Global'][get_team][get_exploit]
                else
                    data = antiaim_preset['Global']['Global'][get_exploit]
                end
            end
            if data.pitch ~= 6 and data.pitch ~= 7 then
                genocide.update('pitch', data.pitch)
            elseif data.pitch == 6 then
                ctx:set_pitch(data.custom_pitch)
            end
            genocide.update('yawbase', data.yawbase)
            genocide.update('yawadd', data.yawadd)
            genocide.update('rotate', data.rotate)
            genocide.update('rotaterange', data.rotaterange)
            genocide.update('rotatespeed', data.rotatespeed)
            if data.jittermode ~= 4 then
                genocide.update('jittermode', data.jittermode)
                genocide.update('jittertype', data.jittertype)
                genocide.update('jitteradd', data.jitteradd)
            else
                if math.tickcount(data.jitterdelay) >= math_floor(data.jitterdelay / 2) then
                    if startway then
                        if (g_antiaim.ways + 1) >= 4 then
                            startway = false
                        else
                            g_antiaim.ways = g_antiaim.ways + 1
                        end
                    else
                        if (g_antiaim.ways - 1) == 0 then
                            startway = true
                        else
                            g_antiaim.ways = g_antiaim.ways - 1
                        end
                    end

                    genocide.update('jittermode', 1)
                    genocide.update('yawadd', data['offset_'..g_antiaim.ways])
                end
            end
            genocide.update('leftamount', data.leftlimit)
            genocide.update('rightamount', data.rightlimit)
            genocide.update('antibruteforce', table.exist(data.options, "Anti Bruteforce"))
            genocide.update('defaultside', 2)
            if data.freestanding == 1 then
                if data.bodyyaw == 1 then
                    genocide.update('side', data.inverter and 3 or 2)
                elseif data.bodyyaw == 2 then
                    genocide.update('side', 4)
                elseif data.bodyyaw == 3 then
                    genocide.update('side', 7)
                end
            elseif data.freestanding == 2 then
                genocide.update('side', 5)
            elseif data.freestanding == 3 then
                genocide.update('side', 5)
            end
            genocide.update('onshot', data.onshot)
            genocide.update('bodylean', data.bodylean == 6 and 2 or data.bodylean)
            genocide.update('bodyleanvalue', data.bodylean_static)
            genocide.update('bodyleanjitter', data.bodylean_jitter)
            genocide.update('bodyleanmoving', data.bodylean ~= 1)
            if data.bodylean == 6 then
                ctx:set_body_lean(data.bodylean_override / 100)
                genocide.update('maxbodylean', data.maxbodylean)
            else
                genocide.update('maxbodylean', 50)
            end
            if get_exploit == "Fakelag" then
                g_antiaim.ex_desync = table.exist(data.options, "Extended Desync") and engine_get_choked_commands() ~= 1
                if data.pitch == 7 then
                    local fakelag = data.extendedangle and data.extendedfakelimit or reference.fakelag:get()
                    ctx:set_pitch(engine_get_choked_commands() == data.extendedfakelimit and -89 or 89)
                end
                if data.extendedangle and reference.extendedangle[2]:get() then
                    ctx:set_fakelag(engine_get_choked_commands() <= data.extendedfakelimit - 1 or engine_get_choked_commands() == 1)
                end
                genocide.update('extended_moving', data.extendedangle)
                genocide.update('extended_pitch', data.extendedpitch)
                genocide.update('extended_type', data.extendedtype)
                genocide.update('extended_offset', data.extendedoffset)
                genocide.update('extended_jitter', data.extendedjitter)
            else
                if data.pitch == 7 then
                    local pitch_value = data.defensive_pitch == 1 and -89 or 0
                    if data.pitch_delay_type == 1 then
                        ctx:set_pitch(math.tickcount(data.pitch_delay_t) >= math_floor(data.pitch_delay_t / 2) and pitch_value or 88)
                    elseif data.pitch_delay_type == 2 then
                        ctx:set_pitch(not math.delay("defensive", data.pitch_delay_r) and pitch_value or 88)
                    elseif data.pitch_delay_type == 3 then
                        if data.jittermode == 4 then
                            if g_antiaim.ways == 1 then
                                ctx:set_pitch(pitch_value)
                            elseif g_antiaim.ways == 2 then
                                ctx:set_pitch(88)
                            elseif g_antiaim.ways == 3 then
                                ctx:set_pitch(pitch_value)
                            end
                        end
                    end
                end
                local is_defensive = table.exist(data.options, "Defensive")
                g_antiaim.ex_desync = is_defensive
                if is_defensive then
                    ctx:set_fakelag(math.tickcount(data.defensive_delay) < data.defensive_delay / 2)
                end
            end
            genocide.update('override_moving', false)
            genocide.update('override_slowwalk', false)
        end
    end

    _IDEALTICK = false
    _LAST_AUTOSTOPS = {}
    _LAST_DELAYSHOT = {}
    local function idealtick()
        local autostop = ui[mc[2]].autostop
        local delayshot = ui[mc[2]].delayshot
        local scout_autostop = reference.scout_autostop
        local scout_delayshot = reference.scout_delayshot
        if reference.autopeek[2]:get() then
            if not _IDEALTICK then
                _IDEALTICK = true
                for i=1, #scout_autostop:get_items() do
                    _LAST_AUTOSTOPS[i] = scout_autostop:get(i)
                    scout_autostop:set(i, autostop:get(i))
                end
                for i=1, #scout_delayshot:get_items() do
                    _LAST_DELAYSHOT[i] = scout_delayshot:get(i)
                    scout_delayshot:set(i, delayshot:get(i))
                end
            end
        else
            if _IDEALTICK then
                _IDEALTICK = false
                for i=1, #scout_autostop:get_items() do
                    scout_autostop:set(i, _LAST_AUTOSTOPS[i])
                end
                for i=1, #scout_delayshot:get_items() do
                    scout_delayshot:set(i, _LAST_DELAYSHOT[i])
                end
                _LAST_AUTOSTOPS = {}
                _LAST_DELAYSHOT = {}
            end
        end
    end
    local on_ground, end_time = 0, 0
    local function animation_breakers(ctx, state)
        local anim = ui[mc[1]].animation
        local is_moving = is_moving()
        if anim:get(5) then
            if state == "Moving" then
                genocide.update('legslide', 2)
                ctx:set_render_pose(e_poses.MOVE_YAW, 0)
                ctx:set_render_animlayer(e_animlayers.MOVEMENT_MOVE, is_moving and 1 or 0)
            end
        else
            if anim:get(1) then
                if state == "Moving" then
                    genocide.update('legslide', 3)
                    ctx:set_render_pose(e_poses.RUN, 1)
                end
            end
        end
        if anim:get(6) then
            if state == "Air" or state == "Air-crouch" then
                ctx:set_render_pose(e_poses.MOVE_YAW, 0)
                ctx:set_render_pose(e_poses.JUMP_FALL, not is_moving and 0.75 or 0)
                ctx:set_render_animlayer(e_animlayers.MOVEMENT_MOVE, is_moving and 1 or 0)
            end
        else
            if anim:get(2) then
                if state == "Air" or state == "Air-crouch" then
                    ctx:set_render_pose(e_poses.JUMP_FALL, 1)
                end
            end
        end
        if anim:get(3) then
            if state == "Air" or state == "Air-crouch" then
                on_ground = 0
                end_time = globals_real_time() + 1
            else
                on_ground = on_ground + 1
            end
            if on_ground > 25 and end_time > globals_real_time() then
                ctx:set_render_pose(e_poses.BODY_PITCH, 0.5)
            end
        end
        if anim:get(4) then
            ctx:set_render_animlayer(e_animlayers.LEAN, 1)
        end
    end

    local function antiaim(cmd)
        if not IS_READY then return end
        local enable = ui[mc[1]].enable:get()
        if enable then
            local get_state = get_state()
            antiaim_update(cmd, antiaim_preset[get_state], get_state)
            animation_breakers(cmd, get_state)
        end
    end

    local EXPLOIT = false
    local EXPLOIT_TIMER = 0
    local function ragebot()
        local ideal = ui[mc[2]].idealtick:get()
        local get_exploit = is_exploit()
        if EXPLOIT ~= get_exploit then
            EXPLOIT = get_exploit
            EXPLOIT_TIMER = 0
        else
            EXPLOIT_TIMER = EXPLOIT_TIMER + 1
        end
        if ideal then
            idealtick()
        end
    end

    local function on_paint()
        local clantag = ui[mc[4]].clantag:get()
        if menu.is_open() then
            get_preset()
            category_update()
            menu_update()
        end
        tag_animation(clantag)
    end

    local function shutdown()
        client_set_clantag("")
    end

    genocide.subscribe('ANTIAIM', {antiaim})
    genocide.subscribe('PAINT', {on_paint})
    genocide.subscribe('RUN_COMMAND', {ragebot})
    genocide.subscribe('SETUP_COMMAND', {extended_desync})
    genocide.subscribe('SHUTDOWN', {shutdown})
    genocide.launch()
end
main()