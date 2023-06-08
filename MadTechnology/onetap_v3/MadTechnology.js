var MT = {
    UI: UI,
    Cheat: Cheat,
    Trace: Trace,
    Local: Local,
    Input: Input,
    World: World,
    Render: Render,
    Entity: Entity,
    Global: Global,
    Globals:Globals,
    AntiAim: AntiAim,
    UserCMD: UserCMD,
}

var MTSEC = {
    _keyStr : "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",
    X0000 : function (input) {
        var output = "";
        var chr1, chr2, chr3, enc1, enc2, enc3, enc4;
        var i = 0;

        input = MTSEC.x01EWXZ(input);

        while (i < input.length) {

            chr1 = input.charCodeAt(i++);
            chr2 = input.charCodeAt(i++);
            chr3 = input.charCodeAt(i++);

            enc1 = chr1 >> 2;
            enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
            enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
            enc4 = chr3 & 63;

            if (isNaN(chr2)) {
                enc3 = enc4 = 64;
            } else if (isNaN(chr3)) {
                enc4 = 64;
            }

            output = output +
            MTSEC._keyStr.charAt(enc1) + MTSEC._keyStr.charAt(enc2) +
            MTSEC._keyStr.charAt(enc3) + MTSEC._keyStr.charAt(enc4);
        }

        return output;
    },
    X1111 : function (input) {
        var output = "";
        var chr1, chr2, chr3;
        var enc1, enc2, enc3, enc4;
        var i = 0;

        input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");

        while (i < input.length) {

            enc1 = MTSEC._keyStr.indexOf(input.charAt(i++));
            enc2 = MTSEC._keyStr.indexOf(input.charAt(i++));
            enc3 = MTSEC._keyStr.indexOf(input.charAt(i++));
            enc4 = MTSEC._keyStr.indexOf(input.charAt(i++));

            chr1 = (enc1 << 2) | (enc2 >> 4);
            chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
            chr3 = ((enc3 & 3) << 6) | enc4;

            output = output + String.fromCharCode(chr1);

            if (enc3 != 64) {
                output = output + String.fromCharCode(chr2);
            }
            if (enc4 != 64) {
                output = output + String.fromCharCode(chr3);
            }
        }

        output = MTSEC.x02WEAZ(output);

        return output;
    },
    x01EWXZ : function (string) {
        string = string.replace(/\r\n/g,"\n");
        var utftext = "";

        for (var n = 0; n < string.length; n++) {

            var c = string.charCodeAt(n);

            if (c < 128) {
                utftext += String.fromCharCode(c);
            }
            else if((c > 127) && (c < 2048)) {
                utftext += String.fromCharCode((c >> 6) | 192);
                utftext += String.fromCharCode((c & 63) | 128);
            }
            else {
                utftext += String.fromCharCode((c >> 12) | 224);
                utftext += String.fromCharCode(((c >> 6) & 63) | 128);
                utftext += String.fromCharCode((c & 63) | 128);
            }
        }
        return utftext;
    },
    x02WEAZ : function (utftext) {
        var string = "";
        var i = 0;
        var c = c1 = c2 = 0;

        while ( i < utftext.length ) {

            c = utftext.charCodeAt(i);

            if (c < 128) {
                string += String.fromCharCode(c);
                i++;
            }
            else if((c > 191) && (c < 224)) {
                c2 = utftext.charCodeAt(i+1);
                string += String.fromCharCode(((c & 31) << 6) | (c2 & 63));
                i += 2;
            }
            else {
                c2 = utftext.charCodeAt(i+1);
                c3 = utftext.charCodeAt(i+2);
                string += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
                i += 3;
            }
        }
        return string;
    }
}

var x0swq5 = {
    xWdZsTR: "LEGEND",
    XMrsxEX: 1632156830
}

MT.print = function(text, color){
    if (color == null) color = [255, 255, 255, 255]
    MT['Cheat']['PrintColor'](color, text+"\n");
}

// if (MTSEC['X1111'](x0swq5['xWdZsTR']) == MT['Cheat']['GetUsername']()){
    var livetime = Math['floor'](Date['now']() / 1000)
    var pr_time = livetime - x0swq5['XMrsxEX']
    // if (21600 > pr_time){
        MT['Cheat']['ExecuteCommand']("clear");
        MT.logo = function(){
            var mt_color = [0, 139, 219, 255];
            MT['print']("`/++++++++++++++++++++++++oooooooooooooooooooooooo++++++++++++++++++++++++/`", mt_color)       
            MT['print']("-mMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMm-", mt_color)            
            MT['print'](" .dMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMd.", mt_color)              
            MT['print']("  .hMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMh.", mt_color)           
            MT['print']("                                 hMMMMMMh                ", mt_color)
            MT['print']("     `odddddddddddddddddddds`    yMMMMMMy    `sddddddddddddddddddddo`", mt_color)        
            MT['print']("      `oNMMMMMMMMMMMMMMMMMMMy`   yMMMMMMy   `yMMMMMMMMMMMMMMMMMMMNo`", mt_color)
            MT['print']("       `:dMMMMMMMMMMMMMMMMMMMh.  sMMMMMMs  .hMMMMMMMMMMMMMMMMMMMd:`", mt_color)
            MT['print']("         `smmmmmmmmmMMMMMMMMMMd. sMMMMMMs .dMMMMMMMMMMmmmmmmmmms`", mt_color)          
            MT['print']("                    NMMMMMMMMMMm-/MMMMMM/-mMMMMMMMMMMN", mt_color)            
            MT['print']("                    NMMMMMMMMMMMm-+MMMM+-mMMMMMMMMMMMN", mt_color)            
            MT['print']("                    NMMMMMMMMMMMMN:+MM+:NMMMMMMMMMMMMN", mt_color)            
            MT['print']("                    NMMMMMN:NMMMMMM////MMMMMMN:NMMMMMN", mt_color)           
            MT['print']("                    NMMMMMN -mMMMMMM++MMMMMMm- NMMMMMN", mt_color)             
            MT['print']("                    MMMMMMN  .dMMMMMMMMMMMMd.  NMMMMMM", mt_color)             
            MT['print']("                    MMMMMMN   .hMMMMMMMMMMh.   NMMMMMM", mt_color)            
            MT['print']("                    MMMMMMN    `yMMMMMMMMy`    NMMMMMM", mt_color)            
            MT['print']("                    MMMMMMN     `sMMMMMMs`     NMMMMMM", mt_color)            
            MT['print']("                    MMMMMMm      .oNMMNo.      mMMMMMM", mt_color)           
            MT['print']("                    MMMMMMm      /s+NN+s/      mMMMMMM", mt_color)             
            MT['print']("                    MMMMMMm      /Mo::oM/      mMMMMMM", mt_color)            
            MT['print']("                    MMMMMMNo.`   /MMooMM/   `.oNMMMMMM", mt_color)            
            MT['print']("                    MMMMMMMMNy:` +MMMMMM+ `:yNMMMMMMMM", mt_color)            
            MT['print']("                    /hNMMMMMMMM: +MMMMMM+ :MMMMMMMMNh/", mt_color)            
            MT['print']("                      -omMMMMMM: +MMMMMM+ :MMMMMMmo-", mt_color)             
            MT['print']("                        `:yMMMM/ +MMMMMM+ /MMMMy:`", mt_color)               
            MT['print']("                           .+dM/ +MMMMMM+ /Md+.", mt_color)                
            MT['print']("                             `-. :ssssss: .-`", mt_color)
            MT['print']("")  
            MT['print']("                              MadTechnology", [162, 220, 245, 255])  
            MT['print']("- Version: 1.0.1", [162, 220, 245, 255])
            MT['print']("- Discord: discord.gg/bNmtuv3PDM", [162, 220, 245, 255])
            MT['print']("- For downloading the latest version of MadTechnology join discord.", [162, 220, 245, 255])
            MT['print']("- Enjoy and have fun.", [162, 220, 245, 255])
        }
                        
        MT['UI']['AddLabel']("              MadTechnology")
        MT['UI']['AddLabel']("               Version: 1.0.1 ")
        MT['UI']['AddLabel']("        Get Good Get MadTech")
        MT['UI']['AddLabel']("--------------------------------------------")
        MT['UI']['AddLabel']("                    Anti-Aim")
        MT['UI']['AddCheckbox']("Anti-aimbot angles")
        MT['UI']['AddDropdown']("BodyYaw", ["Disabled", "Freestand", "Inverter"] );
        MT['UI']['AddHotkey']("Inverter");
        MT['UI']['AddCheckbox']("Legit AA")
        MT['UI']['AddHotkey']("[LegitAA] OnKey");
        MT['UI']['AddDropdown']("[LegitAA] Modes", ["Static", "Freestand", "Jitter"] );
        MT['UI']['AddCheckbox']("LowDelta")
        MT['UI']['AddHotkey']("[LowDelta] OnKey");
        MT['UI']['AddSliderInt']("[LowDelta] Desync", 20, 60 );
        MT['UI']['AddSliderInt']("[LowDelta] Speed", 1, 60 );
        MT['UI']['AddLabel']("                    Ragebot")
        MT['UI']['AddCheckbox']("Doubletap")
        // MT['UI']['AddCheckbox']("[Doubletap] Recharge")
        MT['UI']['AddSliderInt']("[Doubletap] Speed", 13, 20 );
        
        MT['UI']['AddCheckbox']("Damage override")
        MT['UI']['AddHotkey']("[DamageOverride] OnKey");
        MT['UI']['AddDropdown']("Select", ["GENERAL", "PISTOL", "HEAVYPISTOL", "SCOUT", "AWP", "AUTOSNIPER"]);
        var weapons = ["GENERAL", "PISTOL", "HEAVY PISTOL", "SCOUT", "AWP", "AUTOSNIPER"]    
        for (i=0; i < weapons.length; i++){
            MT['UI']['AddSliderInt']("["+weapons[i]+"] Minimum damage", 0, 130 );
            MT['UI']['AddSliderInt']("["+weapons[i]+"] Minimum damage override", 0, 130 );
        }
        
        MT['UI']['AddLabel']("                    Indicators")
        MT['UI']['AddCheckbox']("Indicators")
        MT['UI']['AddCheckbox']("MadTech Indicator")
        MT['UI']['AddColorPicker']("[MT] color");
        MT['UI']['AddColorPicker']("[MT] secondary color");
        MT['UI']['AddCheckbox']("Damage Indicator")
        MT['UI']['AddColorPicker']("[Damage] color");
        MT['UI']['AddCheckbox']("Watermark")
        MT['UI']['AddColorPicker']("[WM] color");
        MT['UI']['AddColorPicker']("[WM] secondary color");
        MT['UI']['AddColorPicker']("[WM] Background color");
        
        AntiAim_rf = {
            aa_enable: ["Anti-Aim", "Rage Anti-Aim", "Enabled"],
            at_target: ["Anti-Aim", "Rage Anti-Aim", "At targets"],
            auto_direction: ["Anti-Aim", "Rage Anti-Aim", "Auto direction"],
            yaw_offset: ["Anti-Aim", "Rage Anti-Aim", "Yaw offset"],
            jitter_offset: ["Anti-Aim", "Rage Anti-Aim", "Jitter offset"],
            Mouse_dir: ["Anti-Aim", "Rage Anti-Aim", "Mouse dir"],
            Manual_dir: ["Anti-Aim", "Rage Anti-Aim", "Manaul dir"],
            left_dir: ["Anti-Aim", "Rage Anti-Aim", "Left dir"],
            back_dir: ["Anti-Aim", "Rage Anti-Aim", "Back dir"],
            right_dir: ["Anti-Aim", "Rage Anti-Aim", "Right dir"],
            fake_angle: ["Anti-Aim", "Fake angles", "Enabled"],
            air_mode: ["Anti-Aim", "Fake angles", "Air mode"],
            lby_mode: ["Anti-Aim", "Fake angles", "LBY mode"],
            Desync_onshot: ["Anti-Aim", "Fake angles", "Desync on shot"],
            Hide_realangle: ["Anti-Aim", "Fake angles", "Hide real angle"],
            avoid_overlap: ["Anti-Aim", "Fake angles", "Avoid overlap"],
            Fake_desync: ["Anti-Aim", "Fake angles", "Fake desync"],
            inverter: ["Anti-Aim", "Fake angles", "Inverter"],
            inverter_flip: ["Anti-Aim", "Fake angles", "Inverter flip"],
            fake_lag: ["Anti-Aim", "Fake-Lag", "Enabled"],
            Limit: ["Anti-Aim", "Fake-Lag", "Limit"],
            Jitter: ["Anti-Aim", "Fake-Lag", "Jitter"],
            Triggers: ["Anti-Aim", "Fake-Lag", "Triggers"],
            Triggers_limit: ["Anti-Aim", "Fake-Lag", "Trigger limit"],
            pitch: ["Anti-Aim", "Extra", "Pitch"],
            Jitter_move: ["Anti-Aim", "Extra", "Jitter move"],
            fake_duck: ["Anti-Aim", "Extra", "Fake duck"],
            slow_walk: ["Anti-Aim", "Extra", "Slow walk"],
        }
        
        var AntiAims = {
            LegitAA: {
                [0]: {
                    pitch: "0",
                    at_target: false,
                    auto_direction: false,
                    yaw_offset: "-180",
                    fake_offset: "10",
                    real_offset: "-180",
                    lby_offset: "-180",
                    jitter_move: false
                },
                [1]: {
                    pitch: "0",
                    at_target: false,
                    auto_direction: false,
                    yaw_offset: "180",
                    fake_offset: "0",
                    real_offset: "0",
                    lby_offset: "50",
                    jitter_move: false
                }
            },
            Main: {
                ['standing']: {
                    pitch: "1",
                    at_target: false,
                    auto_direction: false,
                    yaw_offset: "0",
                    fake_offset: "0",
                    real_offset: "180",
                    lby_offset: "-60",
                    jitter_move: false
                },
                ['moveing']: {
                    pitch: "1",
                    at_target: false,
                    auto_direction: false,
                    yaw_offset: "0",
                    fake_offset: "1",
                    real_offset: "-100",
                    lby_offset: "100",
                    jitter_move: false
                },
                ['slowwalk']: {
                    pitch: "1",
                    at_target: true,
                    auto_direction: false,
                    yaw_offset: "0",
                    fake_offset: "5",
                    real_offset: "-5",
                    lby_offset: "90",
                    jitter_move: true
                },
                ['air']: {
                    pitch: "1",
                    at_target: true,
                    auto_direction: false,
                    yaw_offset: "0",
                    fake_offset: "0",
                    real_offset: "0",
                    lby_offset: "90",
                    jitter_move: false
                }
            },
            Default:{
                ['standing']: {
                    pitch: "1",
                    at_target: false,
                    auto_direction: false,
                    yaw_offset: "-1",
                    fake_offset: "1",
                    real_offset: "180",
                    lby_offset: "-60",
                    jitter_move: false
                },
                ['moveing']: {
                    pitch: "1",
                    at_target: false,
                    auto_direction: false,
                    yaw_offset: "-1",
                    fake_offset: "0",
                    real_offset: "180",
                    lby_offset: "-60",
                    jitter_move: false
                },
                ['slowwalk']: {
                    pitch: "1",
                    at_target: true,
                    auto_direction: false,
                    yaw_offset: "0",
                    fake_offset: "5",
                    real_offset: "-5",
                    lby_offset: "90",
                    jitter_move: true
                },
                ['air']: {
                    pitch: "1",
                    at_target: true,
                    auto_direction: false,
                    yaw_offset: "0",
                    fake_offset: "0",
                    real_offset: "0",
                    lby_offset: "180",
                    jitter_move: false
                },
                ['crouching']: {
                    pitch: "1",
                    at_target: true,
                    auto_direction: false,
                    yaw_offset: "-1",
                    fake_offset: "1",
                    real_offset: "-180",
                    lby_offset: "180",
                    jitter_move: false
                }
            }
        }
        
        MT.SetDamage = function(weapon, value){
            MT['UI']['SetValue']("Rage", weapon, "Targeting", "Minimum damage", value)
        }
        
        MT.GetDamage = function(weapon){
            return MT['UI']['GetValue']("Rage", weapon, "Targeting", "Minimum damage")
        }
        
        MT.getVelocity = function(localplayer) {
            var velocity = MT['Entity']['GetProp'](localplayer, "CBasePlayer", "m_vecVelocity[0]")
            return Math['sqrt'](velocity[ 0 ] * velocity[ 0 ] + velocity[ 1 ] * velocity[ 1 ])
        }
        
        MT.get_aa_state = function(){
            var localplayer = MT['Entity']['GetLocalPlayer']()
            var velocity = MT['getVelocity'](localplayer)
            var shift = AntiAim_rf['slow_walk']
            var slow_walk = MT['UI']['IsHotkeyActive'](shift[0], shift[1], shift[2])
            var flags = MT['Entity']['GetProp'](localplayer,'CBasePlayer','m_fFlags');
            if (!(flags & 1 << 0) && !(flags & 1 << 18)){return "air"}
            if (flags == 263){return "crouching"}
            if (slow_walk){return "slowwalk"}
            var state = "standing"
            if (velocity > 1){
                state = "moveing"
            }else{
                state = "standing"
            }
            return state
        }
        
        MT.AAHandler = function(data, m_default){
            if (data){
                MT['AntiAim']['SetOverride'](1);
                var pitch = AntiAim_rf['pitch']
                var at_target = AntiAim_rf['at_target']
                var auto_direction = AntiAim_rf['auto_direction']
                var jitter_move = AntiAim_rf['Jitter_move']
                var yaw_offset = AntiAim_rf['yaw_offset']
                if (data['pitch']){
                    MT['UI']['SetValue'](pitch[0], pitch[1], pitch[2], Number(data['pitch']));
                }else if(m_default){
                    MT['UI']['SetValue'](pitch[0], pitch[1], pitch[2], 0);
                }
                if (data['at_target']){
                    MT['UI']['SetValue'](at_target[0], at_target[1], at_target[2], true);
                }else{
                    MT['UI']['SetValue'](at_target[0], at_target[1], at_target[2], false);
                }
                if (data['auto_direction']){
                    MT['UI']['SetValue'](auto_direction[0], auto_direction[1], auto_direction[2], true);
                }else{
                    MT['UI']['SetValue'](auto_direction[0], auto_direction[1], auto_direction[2], false);
                }
                if (data['yaw_offset']){
                    MT['UI']['SetValue'](yaw_offset[0], yaw_offset[1], yaw_offset[2], Number(data['yaw_offset']));
                }else if(m_default){
                    MT['UI']['SetValue'](yaw_offset[0], yaw_offset[1], yaw_offset[2], 1);
                }
                if (data['fake_offset']){
                    MT['AntiAim']['SetFakeOffset'](Number(data['fake_offset']));
                }else if(m_default){
                    MT['AntiAim']['SetFakeOffset'](0);
                }
                if (data['real_offset']){
                    MT['AntiAim']['SetRealOffset'](Number(data['real_offset']));
                }else if(m_default){
                    MT['AntiAim']['SetRealOffset'](0);
                }
                if (data['lby_offset']){
                    MT['AntiAim']['SetLBYOffset'](Number(data['lby_offset']));
                }else if(m_default){
                    MT['AntiAim']['SetLBYOffset'](0);
                }
                if (data['jitter_move']){
                    MT['UI']['SetValue'](jitter_move[0], jitter_move[1], jitter_move[2], true);
                }else{
                    MT['UI']['SetValue'](jitter_move[0], jitter_move[1], jitter_move[2], false);
                }
            }
        }
        
        MT.normalize_yaw = function(angle){
            var adjusted_yaw = angle;
            if (adjusted_yaw < -180)
                adjusted_yaw += 360;
            if (adjusted_yaw > 180)
                adjusted_yaw -= 360;
            return adjusted_yaw;
        }
        
        MT.distanceVector = function(v1, v2){
            var dx = v1[0] - v2[0];
            var dy = v1[1] - v2[1];
            var dz = v1[2] - v2[2];
            return Math['sqrt']( dx * dx + dy * dy + dz * dz );
        }

        MT.distanceVector2d = function(v1, v2)
        {
            var dx = v1[0] - v2[0];
            var dy = v1[1] - v2[1];
            return Math['sqrt']( dx * dx + dy * dy );
        },

        MT.getClosestEnemy = function(){
            enms = MT['Entity']['GetEnemies']();
            dist = 999999;
            enm = null;
            for (i = 0; i < 64; i++) {
                if (enms[i] == undefined) break;
                pos = MT['Entity']['GetRenderOrigin'](enms[i]);
                d = MT['distanceVector'](MT['Entity']['GetRenderOrigin'](MT['Entity']['GetLocalPlayer']()), pos);
                if (d < dist && MT['Entity']['IsAlive'](enms[i])) {dist = d; enm = enms[i];} 
            }
            return [enm, dist];
        }
        
        MT.getCrosshairEnemy = function() {
            enms = MT['Entity']['GetEnemies']();
            dist = 999999;
            enm = null;
            for (i = 0; i < 64; i++) {
                if (enms[i] == undefined) break;
                pos = MT['Entity']['GetRenderOrigin'](enms[i]);
                pos2d = MT['Render']['WorldToScreen'](pos);
                screen = MT['Render']['GetScreenSize']();
                sx = screen[0] / 2;
                sy = screen[1] / 2;
                d = MT['distanceVector2d'](pos2d, [sx, sy]);
                if (d < dist) {
                    dist = d;
                    enm = enms[i];
                }
            }
            return enm;
        }

        MT.getVelocity3d = function(e){
            return MT['Entity']['GetProp'](e, "CBasePlayer", "m_vecVelocity[0]");
        }
        
        MT.addVector = function(v1, v2) {
            var dx = v1[0] + v2[0];
            var dy = v1[1] + v2[1];
            var dz = v1[2] + v2[2];
            return [dx, dy, dz];
        }
        
        MT.vector_angles = function(target, eyepos){
            const vector_substract = function(vec1, vec2)
            {
                return [
                    vec1[0] - vec2[0],
                    vec1[1] - vec2[1],
                    vec1[2] - vec2[2],
                ];
            };
            const ext = vector_substract(target, eyepos);
            const yaw = Math['atan2'](ext[1], ext[0]) * 180 / Math['PI'];
            const pitch = -(Math['atan2'](ext[2], Math['sqrt'](ext[0] ** 2 + ext[1] ** 2)) * 180 / Math['PI']);
            return [pitch, yaw];
        }
        
        MT.deg2rad = function(degress) {
            return degress * Math['PI'] / 180.0;
        }
        
        MT.angle_to_vec = function(pitch, yaw){
            var p = MT['deg2rad'](pitch);
            var y = MT['deg2rad']( yaw)
            var sin_p = Math['sin'](p);
            var cos_p = Math['cos'](p);
            var sin_y = Math['sin'](y);
            var cos_y = Math['cos'](y);
            return [ cos_p * cos_y, cos_p * sin_y, -sin_p ];
        }
        
        MT.getHeadPos = function(entity_id, entity_angles) {
            var entity_vec = MT['angle_to_vec'](entity_angles[0], entity_angles[1]);
            var entity_pos = MT['Entity']['GetRenderOrigin']( entity_id );
            entity_pos[2] += 60;
            var stop = [entity_pos[ 0 ] + entity_vec[0] * 16, entity_pos[1] + entity_vec[1] * 16, (entity_pos[2])  + entity_vec[2] * 16];
            return stop;
        }
        
        MT.getDist = function(entity_id, entity_angles) {
            var entity_vec = MT['angle_to_vec'](entity_angles[0], entity_angles[1]);
            var entity_pos = MT['Entity']['GetRenderOrigin'](entity_id);
            entity_pos[2] += 50;
            var stop = [entity_pos[ 0 ] + entity_vec[0] * 8192, entity_pos[1] + entity_vec[1] * 8192, (entity_pos[2]) + entity_vec[2] * 8192];
            var traceResult = MT['Trace']['Line'](entity_id, entity_pos, stop);
            if(traceResult[1] == 1.0)
            return;
            stop = [entity_pos[ 0 ] + entity_vec[0] * traceResult[1] * 8192, entity_pos[1] + entity_vec[1] * traceResult[1] * 8192, entity_pos[2] + entity_vec[2] * traceResult[1] * 8192];
            var distance = Math['sqrt']((entity_pos[0] - stop[0]) * (entity_pos[0] - stop[0]) + (entity_pos[1] - stop[1]) * (entity_pos[1] - stop[1]) + (entity_pos[2] - stop[2]) * (entity_pos[2] - stop[2]));
            entity_pos = MT['Render']['WorldToScreen'](entity_pos);
            stop = MT['Render']['WorldToScreen'](stop);
            return distance;
        }
        
        MT.desync = function(){
            fakeyaw = MT['Local']['GetFakeYaw']();
            realyaw = MT['Local']['GetRealYaw']();
            return Math['abs'](realyaw - fakeyaw);
        },
        
        MT.freestand = function(){
            var target = MT['getCrosshairEnemy']()
            // if (MT['getClosestEnemy']()[1] < 100) {
            //     target = MT['getClosestEnemy']()[0]
            // }
            var localplayer = MT['Entity']['GetLocalPlayer']();
            if (target != null && !MT['Entity']['IsDormant'](target) && MT['Entity']['IsAlive'](target) && MT['Entity']['IsValid'](target) && MT['Entity']['IsAlive'](localplayer)) {
                pos = MT['Entity']['GetHitboxPosition'](target, 2);
                vel = MT['getVelocity3d'](target);
                pos_prediction = MT['addVector'](pos, vel);
                eye = MT['Entity']['GetEyePosition'](localplayer);
                res_predict = MT['Trace']['Line'](target, pos_prediction, eye)
                res_line = MT['Trace']['Line'](target, pos, eye)
                res_bullet = MT['Trace']['Bullet'](localplayer, target, eye, pos);
        
                if ((MT['Entity']['IsValid'](res_bullet[0]) && MT['Entity']['IsAlive'](res_bullet[0])) || res_line[1] > .05 || res_predict[1] > .5){
                    hasTarget = true;
                    angle = MT['vector_angles'](pos, eye);
                    langle = MT['Local']['GetViewAngles']()[1];
                    base = Math['abs'](langle - angle[1]);
                    fakebool = false;
                    left = [];
                    right = [];
                    left[0] = MT['getDist'](localplayer, [0, angle[1]  -5]);
                    left[1] = MT['getDist'](localplayer, [0, angle[1]  -15]);
                    left[2] = MT['getDist'](localplayer, [0, angle[1] -25]);
                    left[3] = MT['getDist'](localplayer, [0, angle[1]  -55]);
                    left[4] = MT['getDist'](localplayer, [0, angle[1]  -80]);
                    right[0] = MT['getDist'](localplayer, [0, angle[1]  +5]);
                    right[1] = MT['getDist'](localplayer, [0, angle[1]  +15]);
                    right[2] = MT['getDist'](localplayer, [0, angle[1]  +25]);
                    right[3] = MT['getDist'](localplayer, [0, angle[1]  +55]);
                    right[4] = MT['getDist'](localplayer, [0, angle[1]  +80]);
                    dist_right = (left[0] + left[1] + left[2] + left[3]) / 4;
                    dist_left = (right[0] + right[1] + right[2] + right[3]) / 4;
                    if (dist_left < 50 || dist_right < 50 || left[2] < 50 || right[2] < 50) {
                        hposLeft = MT['getHeadPos'](localplayer, [0, angle[1] + 90]);
                        hposRight = MT['getHeadPos'](localplayer, [0, angle[1] - 90]);
                        resLeft = MT['Trace']['Line'](localplayer, hposLeft, pos);
                        resRight = MT['Trace']['Line'](localplayer, hposRight, pos);
                        resLeft[1] > resRight[1] ? direction = 1 : direction = 2;
                    } else {direction = 0;}
                    dist_left < dist_right ? side = 0 : side = 1;
                    if ( langle > angle[1]) base = 0 - base;
                    if (direction == 0) {
                        jitter_counter = Math['floor'](Math['random']() * 11);
                        if (side) {
                            fakebool = true;
                            real = base + jitter_counter;
                            fake = base +60;
                            lby = base -120;
                        } else {
                            fakebool = false;
                            real = base + jitter_counter;
                            fake = base -30;
                            lby = base +120; 
                        }
                    } 
                    else if (direction == 1) {
                        fakebool = false;
                        base = 180;
                        real = base;
                        fake = 1;
                        lby = -90;
                    }
                    else if (direction == 2) {
                        fakebool = true;
                        base = -180;
                        real = base;
                        fake = -1;
                        lby = 90;
                    }
                    return {base: base, real: real, fake: fake, lby: lby, bool: fakebool}
                }
            }
        }
        
        MT['Cheat']['ExecuteCommand']("unbind e");
        MT['Cheat']['ExecuteCommand']("bind f +use");
        MT.LegitAA = function(){
            var Legit_aa_mode = Number(MT['UI']['GetValue']("Script items", "[LegitAA] Modes"));
            var getClosestEnemy = MT['getClosestEnemy']()[0]
            if (Legit_aa_mode == 1){
                if (getClosestEnemy != null){
                    var freestand = MT['freestand']()
                    if (freestand['bool']){
                        AntiAims['LegitAA'][Legit_aa_mode]['fake_offset'] = -10
                        AntiAims['LegitAA'][Legit_aa_mode]['real_offset'] = 60
                        AntiAims['LegitAA'][Legit_aa_mode]['lby_offset'] = 180
                    }else{
                        AntiAims['LegitAA'][Legit_aa_mode]['fake_offset'] = 10
                        AntiAims['LegitAA'][Legit_aa_mode]['real_offset'] = -50
                        AntiAims['LegitAA'][Legit_aa_mode]['lby_offset'] = -180
                    }
                }
            }
            //MT.print(AntiAims['LegitAA'][Legit_aa_mode].pitch)
            MT['AAHandler'](AntiAims['LegitAA'][Legit_aa_mode], false)
        }
        
        MT.inverter = function(){
            var Inverter = MT['UI']['IsHotkeyActive']("Script items", "Inverter");
            var fake, real, lby
            if (Inverter){
                real = 180;
                fake = 1;
                lby = -90;
            }else{
                real = -180;
                fake = -1;
                lby = 90;
            }
            return {fake: fake, real: real, lby: lby}
        }

        MT.SetWalkspeed = function(value){
            var localplayer = MT['Entity']['GetLocalPlayer']()
            var velocity = MT['getVelocity'](localplayer)
            var movement = MT['UserCMD']['GetMovement']()
            var speed = 1
            var forward, side, up
            if (velocity > 1){
                forward = (movement[0] * speed ) / value
                side = (movement[1] * speed ) / value
                up = (movement[2] * speed ) / value
            }
            MT['UserCMD']['SetMovement']([forward, side, up])
        }
        
        MT.Randomint = function(min, max){
            min = Math['ceil'](min);
            max = Math['floor'](max);
            return Math['floor'](Math['random']() * (max - min + 1)) + min; 
        }
        
        MT.LowDelta = function(){
            var lowdelta_desync = MT['UI']['GetValue']("Script items", "[LowDelta] Desync")
            //var multiplierOptions = [-2, -1, 1, 2];
            // * multiplierOptions[MT['Randomint'](0, multiplierOptions['length'])]
            var real_offset = MT['Randomint'](-lowdelta_desync + 10, lowdelta_desync) 
            var fake_offset = MT['Randomint'](-20, 20)
            var lowdelta_speed = MT['UI']['GetValue']("Script items", "[LowDelta] Speed")
            MT['AAHandler']({
                pitch: "1",
                at_target: true,
                auto_direction: false,
                yaw_offset: "1",
                fake_offset: "0",
                real_offset: real_offset,
                lby_offset: "30",
                jitter_move: false
            }, false)
            MT['SetWalkspeed'](lowdelta_speed)
        }
        
        MT.JumpAA = function(){
            var real_offset = MT['Randomint'](-1, 1)
            var fake_offset = MT['Randomint'](-10, 20)
            MT['AAHandler']({
                pitch: "1",
                at_target: true,
                auto_direction: false,
                yaw_offset: "1",
                fake_offset: fake_offset,
                real_offset: real_offset,
                lby_offset: "60",
                jitter_move: false
            }, false)
        }
        
        
        MT.Desync_Handler = function(){
            var BodyYaw = MT['UI']['GetValue']("Script items", "BodyYaw");
            var aa_state = MT['get_aa_state']()
            if (aa_state == "air"){return MT['JumpAA']()}
            if (aa_state != "air" && aa_state != "slowwalk"){
                if (BodyYaw == 1){
                    var freestand = MT['freestand']()
                    if (freestand['bool']){
                        AntiAims['Main'][aa_state]['fake_offset'] = 0
                        AntiAims['Main'][aa_state]['real_offset'] = 0
                        AntiAims['Main'][aa_state]['lby_offset'] = 0
                    }else{
                        AntiAims['Main'][aa_state]['fake_offset'] = 0
                        AntiAims['Main'][aa_state]['real_offset'] = 0
                        AntiAims['Main'][aa_state]['lby_offset'] = 0
                    }
                }else{
                    var inverter = MT['inverter']()
                    AntiAims['Main'][aa_state]['fake_offset'] = inverter['fake']
                    AntiAims['Main'][aa_state]['real_offset'] = inverter['real']
                    AntiAims['Main'][aa_state]['lby_offset'] = inverter['lby']
                }
            }

            MT['AAHandler'](AntiAims['Main'][aa_state], false)
        }
        
        var active_damage = 0;
        prediction = function(){
            var legit_aa = MT['UI']['GetValue']("Script items", "Legit AA")
            var Legit_aa_onkey = MT['UI']['IsHotkeyActive']("Script items", "[LegitAA] OnKey");
            if (legit_aa && Legit_aa_onkey){
                MT['LegitAA']()
            }else{
                var lowdelta = MT['UI']['GetValue']("Script items", "LowDelta");
                var lowdelta_key = MT['UI']['IsHotkeyActive']("Script items", "[LowDelta] OnKey");
                if (lowdelta && lowdelta_key){ return MT['LowDelta']()}
                var getClosestEnemy = MT['getClosestEnemy']()[0]
                if (getClosestEnemy != null){
                    MT['Desync_Handler']()
                }else{
                    var aa_state = MT['get_aa_state']()
                    MT['AAHandler'](AntiAims['Default'][aa_state], false)
                }
            }
        }
        
        MT.Ragebot = function(){
            var Doubletap = MT['UI']['GetValue']("Script items", "Doubletap")
            if (Doubletap){
                var speed = UI.GetValue("Script items", "[Doubletap] Speed")
                Exploit.OverrideShift(speed) 
            }
        }
        
        Misc = function(){
            var d_override = MT['UI']['GetValue']("Script items", "Damage override")
            if (d_override){
                var is_override = MT['UI']['IsHotkeyActive']("Script items", "[DamageOverride] OnKeyy");
                for (i=0; i < weapons.length; i++){
                    var damage = 0
                    if (is_override){
                        damage = MT['UI']['GetValue']("Script items", "["+weapons[i]+"] Minimum damage override")
                    }else{
                        damage = MT['UI']['GetValue']("Script items", "["+weapons[i]+"] Minimum damage")
                    }
                    MT['SetDamage'](weapons[i], damage)
                }
            }
            MT['Ragebot']()
        }
        
        var indicator_ft = false;
        var logo_show = false;
        var last_wp = 0;
        
        var weapon_catg = {
            ['ssg 08']: 3,
            ['awp']: 4,
            ['g3sg1']: 5,
            ['scar 20']: 5,
            ['desert eagle']: 2,
            ['r8 revolver']: 2,
            ['glock 18']: 1,
            ['p2000']: 1,
            ['usp s']: 1,
            ['tec 9']: 1,
            ['dual berettas']: 1,
            ['five seven']: 1,
            ['cz75 auto']: 1,
            ['p250']: 1,
        
        
        }
        MT.Active_weapon_damage = function(){
            var weapon_name = MT['Entity']['GetName'](MT['Entity']['GetWeapon'](MT['Entity']['GetLocalPlayer']()))
            var damage = 0
            if (weapon_catg[weapon_name]){
                damage = MT['GetDamage'](weapons[weapon_catg[weapon_name]])
            }else{
                damage = MT['GetDamage'](weapons[0])
            }
            return damage
        }
        
        Main = function(){
            var aa_enable = MT['UI']['GetValue']("Script items", "Anti-aimbot angles")
            if (aa_enable){
                if (!logo_show){
                    MT['logo']();
                    logo_show = true;
                }
                var Anti_Untrusted = MT['UI']['GetValue']("Information", "Restrictions")
                if (Anti_Untrusted != "0"){
                    MT['UI']['SetValue']("Misc", "PERFORMANCE & INFORMATION", "Information", "Restrictions", 0);
                }
            }else{
                if (logo_show){
                    MT['Cheat']['ExecuteCommand']("clear");
                    MT['Cheat']['ExecuteCommand']("-use");
                    logo_show = false;
                }
            }
            MT['UI']['SetEnabled']("Misc", "JAVASCRIPT", "Script items", "BodyYaw", aa_enable);
            MT['UI']['SetEnabled']("Misc", "JAVASCRIPT", "Script items", "Legit AA", aa_enable);
            MT['UI']['SetEnabled']("Misc", "JAVASCRIPT", "Script items", "LowDelta", aa_enable);
        
            var bodyaw = MT['UI']['GetValue']("Script items", "BodyYaw")
            if (bodyaw == 2){
                MT['UI']['SetEnabled']("Misc", "JAVASCRIPT", "Script items", "Inverter", aa_enable ? true : false);
            }else{
                MT['UI']['SetEnabled']("Misc", "JAVASCRIPT", "Script items", "Inverter", false);
            }
        
            // LEGIT AA
            var legit_aa = MT['UI']['GetValue']("Script items", "Legit AA")
            MT['UI']['SetEnabled']("Misc", "JAVASCRIPT", "Script items", "[LegitAA] OnKey", aa_enable ? legit_aa : false);
            MT['UI']['SetEnabled']("Misc", "JAVASCRIPT", "Script items", "[LegitAA] Modes", aa_enable ? legit_aa : false);
            
            // LOW DELTA
            var Lowdelta = MT['UI']['GetValue']("Script items", "LowDelta")
            MT['UI']['SetEnabled']("Misc", "JAVASCRIPT", "Script items", "[LowDelta] OnKey", aa_enable ? Lowdelta : false);
            MT['UI']['SetEnabled']("Misc", "JAVASCRIPT", "Script items", "[LowDelta] Desync", aa_enable ? Lowdelta : false);
            MT['UI']['SetEnabled']("Misc", "JAVASCRIPT", "Script items", "[LowDelta] Speed", aa_enable ? Lowdelta : false);
        
            // DOUBLETAP
            var Doubletap = MT['UI']['GetValue']("Script items", "Doubletap")
            // MT['UI']['SetEnabled']("Misc", "JAVASCRIPT", "Script items", "[Doubletap] Recharge", Doubletap ? true : false);
            MT['UI']['SetEnabled']("Misc", "JAVASCRIPT", "Script items", "[Doubletap] Speed", Doubletap ? true : false);
        
            //Damage override 
            var d_override = MT['UI']['GetValue']("Script items", "Damage override")
            MT['UI']['SetEnabled']("Misc", "JAVASCRIPT", "Script items", "[DamageOverride] OnKey", d_override);
            MT['UI']['SetEnabled']("Misc", "JAVASCRIPT", "Script items", "Select", d_override);
            var wp_select = MT['UI']['GetValue']("Script items", "Select")
            for (i=0; i < weapons.length; i++){
                if (i == wp_select){
                    MT['UI']['SetEnabled']("Misc", "JAVASCRIPT", "Script items", "["+weapons[i]+"] Minimum damage", d_override ? true : false);
                    MT['UI']['SetEnabled']("Misc", "JAVASCRIPT", "Script items", "["+weapons[i]+"] Minimum damage override",  d_override ? true : false);
                }else{
                    MT['UI']['SetEnabled']("Misc", "JAVASCRIPT", "Script items", "["+weapons[i]+"] Minimum damage", false);
                    MT['UI']['SetEnabled']("Misc", "JAVASCRIPT", "Script items", "["+weapons[i]+"] Minimum damage override", false);
                }
            }
        
            //INDICATORS
            var indicators = MT['UI']['GetValue']("Script items", "Indicators")
            if (indicators){
                if (!indicator_ft){
                    MT['UI']['SetColor']("Misc", "JAVASCRIPT", "Script items", "[MT] color", [10, 182, 255, 255]);
                    MT['UI']['SetColor']("Misc", "JAVASCRIPT", "Script items", "[MT] secondary color", [35, 104, 207, 200]);
                    MT['UI']['SetColor']("Misc", "JAVASCRIPT", "Script items", "[Damage] color", [35, 104, 207, 255]);
                    MT['UI']['SetColor']("Misc", "JAVASCRIPT", "Script items", "[WM] color", [10, 182, 255, 255]);
                    MT['UI']['SetColor']("Misc", "JAVASCRIPT", "Script items", "[WM] secondary color", [35, 104, 207, 200]);
                    MT['UI']['SetColor']("Misc", "JAVASCRIPT", "Script items", "[WM] Background color", [0, 0, 0, 125]);
                    MT['UI']['SetValue']("Misc", "PERFORMANCE & INFORMATION", "Information", "Watermark", false)
                    indicator_ft = true;
        
                }
            }
            MT['UI']['SetEnabled']("Misc", "JAVASCRIPT", "Script items", "MadTech Indicator", indicators);
            MT['UI']['SetEnabled']("Misc", "JAVASCRIPT", "Script items", "Damage Indicator", indicators);
            MT['UI']['SetEnabled']("Misc", "JAVASCRIPT", "Script items", "Watermark", indicators);
        
            var mt_indicator = MT['UI']['GetValue']("Script items", "MadTech Indicator")
            MT['UI']['SetEnabled']("Misc", "JAVASCRIPT", "Script items", "[MT] color", indicators ? mt_indicator : false);
            MT['UI']['SetEnabled']("Misc", "JAVASCRIPT", "Script items", "[MT] secondary color", indicators ? mt_indicator : false);
            var dm_indicator = MT['UI']['GetValue']("Script items", "Damage Indicator")
            MT['UI']['SetEnabled']("Misc", "JAVASCRIPT", "Script items", "[Damage] color", indicators ? dm_indicator : false);
            var wm_indicator = MT['UI']['GetValue']("Script items", "Watermark")
            MT['UI']['SetEnabled']("Misc", "JAVASCRIPT", "Script items", "[WM] color", indicators ? wm_indicator : false);
            MT['UI']['SetEnabled']("Misc", "JAVASCRIPT", "Script items", "[WM] secondary color", indicators ? wm_indicator : false);
            MT['UI']['SetEnabled']("Misc", "JAVASCRIPT", "Script items", "[WM] Background color", indicators ? wm_indicator : false);
        
            var localplayer = MT['Entity']['GetLocalPlayer']();
            if (wm_indicator){
                var today = new Date();
                var hours1 = today['getHours']();
                var minutes1 = today['getMinutes']();
                var seconds1 = today['getSeconds']();
                var hours = hours1 <= 9 ? "0"+hours1+":" : hours1+":";
                var minutes = minutes1 <= 9 ? "0" + minutes1+":" : minutes1+":";
                var seconds = seconds1 <= 9 ? "0" + seconds1 : seconds1;
                var server_tickrate = MT['Globals']['Tickrate']()['toString']()
                var font = MT['Render']['AddFont']("Verdana", 7, 400);
                var delay = Math['round'](MT['Entity']['GetProp'](MT['Entity']['GetLocalPlayer'](), "CPlayerResource", "m_iPing"))['toString']()
                var text = "MadTechnology | " + MT['Cheat']['GetUsername']() + " | delay: " + delay + "ms | " + server_tickrate + "Tick | " + hours + minutes + seconds;
                var w = MT['Render']['TextSizeCustom'](text, font)[0] + 8;
                var x = MT['Global']['GetScreenSize']()[0];
                x = x - w - 10;
                var wm_color = MT['UI']['GetColor']("Script items", "[WM] color");
                var mt_sec_color = MT['UI']['GetColor']("Script items", "[WM] secondary color");
                var mt_back_color = MT['UI']['GetColor']("Script items", "[WM] Background color");
                MT['Render']['GradientRect'](x, 10 , w, 2, 1, wm_color, mt_sec_color);
                MT['Render']['FilledRect'](x, 12, w, 18, mt_back_color);
                MT['Render']['GradientRect'](x, 30 , w, 2, 1, wm_color, mt_sec_color);
                MT['Render']['StringCustom'](x+4, 10 + 4, 0, text, [ 255, 255, 255, 255 ], font);
            }
            if (MT['Entity']['IsAlive'](localplayer) && MT['World']['GetServerString']()){
                var screen_size = MT['Global']['GetScreenSize']();
                var screen_height = screen_size[0] / 2;
                var screen_width = screen_size[1] / 2;
                if (dm_indicator){
                    var damage_color = MT['UI']['GetColor']("Script items", "[Damage] color");
                    var active_damage = MT['Active_weapon_damage']()['toString']()
                    var font = MT['Render']['AddFont']("Tahoma", 7, 700);
                    MT['Render']['StringCustom'](screen_height + 7, screen_width - 10, 0, active_damage, damage_color, font);
                }
                if (mt_indicator){
                    var mt_color = MT['UI']['GetColor']("Script items", "[MT] color");
                    var mt_sec_color = MT['UI']['GetColor']("Script items", "[MT] secondary color");
        
                    var fake = MT['Local']['GetFakeYaw']();
                    var yaw = MT['Local']['GetRealYaw']();
                    var delta = Math['round'](MT['normalize_yaw'](yaw - fake) / 2)  
                    var desync = Math['abs'](delta);
                    if (15 >= desync){
                        desync = 20
                    }
                    if (desync >= 45){
                        desync = 40
                    }
                    var font = MT['Render']['AddFont']("Tahoma", 7, 1000);
                    MT['Render']['StringCustom'](screen_height, screen_width + 5, 1, "MADTECH", [255, 255, 255, 255], font);
                    //MT['Render']['String'](screen_height, screen_width, 1, "MADTECH", mt_color, 3);
                    //MT['Render']['FilledRect'](screen_height, screen_width + 12, desync, 8, [20, 20, 20, 150]);
                    //MT['Render']['FilledRect'](screen_height, screen_width + 20, -desync, -8, [20, 20, 20, 150]);
                    MT['Render']['GradientRect'](screen_height, screen_width + 18, desync - 3, 3, 1, mt_color, mt_sec_color);
                    MT['Render']['GradientRect'](screen_height, screen_width + 21, -desync + 3, -3, 1, mt_color, mt_sec_color);
                }
            }
        
        }
        
    MT['Cheat']['RegisterCallback']("Draw", "Main")
    MT['Cheat']['RegisterCallback']("CreateMove", "prediction")
    MT['Cheat']['RegisterCallback']("CreateMove", "Misc")
//     }else{
//         MT['print']("[MADTECH] Your client expired.\nplease download new client!", [255, 0, 0, 255]);
//     }
// }else{
//    MT['print']("[MADTECH] Your username not match!", [255, 0, 0, 255]);
// }
