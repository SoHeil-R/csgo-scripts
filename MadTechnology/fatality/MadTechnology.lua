local MT = {
    menu = gui,
    cvar = cvar,
    utils = utils,
    input = input,
    render = render,
    engine = engine,
    entities = entities,
    global_vars = global_vars,
    version = "2.0.0",
    username = "",
    scope = 0,
    sleep_t = {},
}

function MT.R()
    local mt_location = "lua>tab a";

    local categorys = {
        madtech = MT.menu.add_checkbox("MadTechnology", mt_location),
        enable = MT.menu.add_checkbox("MadTech anti-aim", mt_location),
        at_target = MT.menu.add_checkbox("At target", mt_location),
        bodyyaw = MT.menu.add_combo("BodyYaw", mt_location, {"Disabled", "Freestand", "Movement", "Extended", "Ideal yaw", "Roll Disabled"}),
        legit_aa = MT.menu.add_checkbox("Legit aa", mt_location),
        legit_aa_modes = MT.menu.add_combo("Legit aa modes", mt_location, {"Static", "Freestand", "Jitter"}),
        slow_speed = MT.menu.add_slider("Slow-walk speed", mt_location, 1, 50, 1),
        tank_aa = MT.menu.add_checkbox("Tank aa", mt_location),
        tank_aa_slider = MT.menu.add_slider("Tank Yaw", mt_location, 1, 90, 1),
        tank_aa_fake = MT.menu.add_slider("Tank Fake", mt_location, 1, 50, 1),
        leg_breaker = MT.menu.add_checkbox("Leg breaker", mt_location),
        madtech_r = MT.menu.add_button("Ragebot", mt_location, function() end),
        doubletap_speed = MT.menu.add_slider("Doubletap speed", mt_location, 8, 21, 16),
        idealtick = MT.menu.add_checkbox("Idealtick", mt_location),
        fastduck = MT.menu.add_checkbox("Fastduck", mt_location),
        rollresolver = MT.menu.add_checkbox("Roll Resolver", mt_location),
        clock_correction = MT.menu.add_checkbox("Disable Clock correction", mt_location),
        madtech_i = MT.menu.add_button("Indicators", mt_location, function() end),
        desync_i = MT.menu.add_checkbox("Enable indicator", mt_location),
        fakelag_switch = MT.menu.add_checkbox("Random Fakelag", mt_location),
        fakelag = MT.menu.add_slider("Randomize Limit", mt_location, 3, 14, 14),
    }

    local antiaim_ref = {
        enable = MT.menu.get_config_item("rage>anti-aim>angles>anti-aim"),
        pitch = MT.menu.get_config_item("rage>anti-aim>angles>pitch"),
        freestand = MT.menu.get_config_item("rage>anti-aim>angles>freestand"),
        stats = MT.menu.get_config_item("rage>anti-aim>angles>yaw"),
        yaw_add = MT.menu.get_config_item("rage>anti-aim>angles>yaw add"),
        yaw = MT.menu.get_config_item("rage>anti-aim>angles>add"),
        at_target = MT.menu.get_config_item("rage>anti-aim>angles>at fov target"),
        override = MT.menu.get_config_item("rage>anti-aim>angles>antiaim override"),
        back_m = MT.menu.get_config_item("rage>anti-aim>angles>back"),
        left_m = MT.menu.get_config_item("rage>anti-aim>angles>left"),
        right_m = MT.menu.get_config_item("rage>anti-aim>angles>right"),
        spin = MT.menu.get_config_item("rage>anti-aim>angles>spin"),
        jitter = MT.menu.get_config_item("rage>anti-aim>angles>jitter"),
        jitter_renge = MT.menu.get_config_item("rage>anti-aim>angles>Jitter range"),
        random = MT.menu.get_config_item("rage>anti-aim>angles>random"),
        range = MT.menu.get_config_item("rage>anti-aim>angles>spin range"),
        speed = MT.menu.get_config_item("rage>anti-aim>angles>spin speed"),
        fake = MT.menu.get_config_item("rage>anti-aim>desync>fake"),
        freestand_fake = MT.menu.get_config_item("rage>anti-aim>desync>freestand fake"),
        flip_fake = MT.menu.get_config_item("rage>anti-aim>desync>flip fake with jitter"),
        leg_slide = MT.menu.get_config_item("rage>anti-aim>desync>leg slide"),
        roll_lean = MT.menu.get_config_item("rage>anti-aim>desync>roll lean"),
        lean_amount = MT.menu.get_config_item("rage>anti-aim>desync>lean amount"),
        ensure_lean = MT.menu.get_config_item("rage>anti-aim>desync>ensure lean"),
        flip_lean = MT.menu.get_config_item("rage>anti-aim>desync>flip lean with jitter"),
        fake_amount = MT.menu.get_config_item("rage>anti-aim>desync>fake amount"),
        compensate_angle = MT.menu.get_config_item("rage>anti-aim>desync>compensate angle"),
        slowwalk = MT.menu.get_config_item("misc>movement>slide"),
        quickpeek = MT.menu.get_config_item("misc>movement>peek assist"),
        doubletap = MT.menu.get_config_item("rage>aimbot>aimbot>double tap"),
        hideshot = MT.menu.get_config_item("rage>aimbot>aimbot>hide shot"),
        fakelag = MT.menu.get_config_item("rage>anti-aim>fakelag>limit"),
        fakeduck = MT.menu.get_config_item("misc>movement>fake duck"),
        resolver = MT.menu.get_config_item("rage>aimbot>aimbot>resolver mode")
    }
    
    local antiaim_stats = {
        movement = false,
        last_move = false,
        base = {
            ['standing'] = {
                pitch = 1,
                stats = 1,
                yaw_add = true,
                yaw = 0,
                at_target = true,
                fake = true,
                flip_fake = false,
                flip_lean = false,
                freestand_fake = 2,
                roll_lean = 2,
                lean_amount = 50,
                fake_amount = 100,
                compensate_angle = 50,
                ensure_lean = false,
                jitter = false,
                random = false,
                range = 3,
                override = true
            },
            ['moving'] = {
                pitch = 1,
                stats = 1,
                yaw_add = true,
                yaw = 0,
                at_target = false,
                fake = true,
                flip_fake = false,
                flip_lean = false,
                freestand_fake = 2,
                roll_lean = 2,
                lean_amount = 50,
                fake_amount = 100,
                compensate_angle = 50,
                ensure_lean = false,
                jitter = false,
                random = false,
                range = 3,
                override = true
            },
            ['air'] = {
                pitch = 1,
                stats = 1,
                yaw_add = true,
                yaw = 1,
                at_target = true,
                fake = true,
                flip_fake = false,
                flip_lean = false,
                freestand_fake = 1,
                roll_lean = 6,
                lean_amount = 0,
                fake_amount = 100,
                compensate_angle = 50,
                ensure_lean = false,
                jitter = false,
                random = false,
                range = 3,
                override = false
            },
            ['crouching'] = {
                pitch = 1,
                stats = 1,
                yaw_add = true,
                yaw = 0,
                at_target = true,
                fake = true,
                flip_fake = false,
                flip_lean = false,
                freestand_fake = 1,
                roll_lean = 5,
                lean_amount = 40,
                fake_amount = 100,
                compensate_angle = 50,
                ensure_lean = false,
                jitter = false,
                random = false,
                range = 30,
                override = false
            },
            ['slowwalk'] = {
                pitch = 1,
                stats = 1,
                yaw_add = true,
                yaw = 1,
                at_target = true,   
                fake = true,
                flip_fake = false,
                flip_lean = false,
                freestand_fake = 2,
                roll_lean = 1,
                lean_amount = 50,
                fake_amount = 100,
                compensate_angle = 50,
                ensure_lean = false,
                jitter = true,
                random = true,
                range = 8,
                override = false
            },
        }
    }

    function get_exploit()
        return antiaim_ref.hideshot:get_bool() or antiaim_ref.doubletap:get_bool()
    end

    function MT.Console(message, color, sound)
        MT.utils.print_console("[MADTECH] ", MT.render.color(171, 7, 74, 255))
        MT.utils.print_console(message.."\n", MT.render.color(color.r , color.g, color.b , 255))
        if sound then
            MT.engine.exec("play hostage\\huse\\letsdoit")
        else
            MT.engine.exec("play error")
        end
    end
    
    
    function MT.tcount(table)
        local count = 0
        for k,v in pairs(table) do
            count = count + 1
        end
        return count
    end
    
    
    function MT.getLocalplayer()
        return MT.entities.get_entity(engine.get_local_player());
    end
    
    local g_tickcount = 0
    function tickcount(value)
        return (g_tickcount % value) + 1
    end

    function MT.AAChecker(data)
        for k,v in pairs(data) do
            if k ~= "movement_f" and k ~= "movement_d" then
                local get_value = type(v) == "number" and tonumber(antiaim_ref[k]:get_int()) or antiaim_ref[k]:get_bool()
                if data.movement_d and k == "lean_amount" then 
                    if tonumber(data.movement_f) ~= get_value then 
                        return true
                    end
                else
                    if v ~= get_value then
                        return true
                    end
                end
            end
        end
        return false
    end

    function MT.AAHandler(data, if_else, legit)
        if data then
            if data.pitch then
                antiaim_ref.pitch:set_int(data.pitch)
            elseif if_else then
                antiaim_ref.pitch:set_int(0)
            end
            if data.stats then
                antiaim_ref.stats:set_int(data.stats)
            else
                antiaim_ref.stats:set_int(0)
            end
            if data.yaw_add then
                antiaim_ref.yaw_add:set_bool(true)
            else
                antiaim_ref.yaw_add:set_bool(false)
            end
            if data.yaw then
                antiaim_ref.yaw:set_int(data.yaw)
            elseif if_else then
                antiaim_ref.yaw:set_int(0)
            end
            -- if categorys.at_target:get_bool() and not legit then
            --     antiaim_ref.at_target:set_bool(true)
            -- else

            -- end
            if data.at_target then
                antiaim_ref.at_target:set_bool(true)
            else
                antiaim_ref.at_target:set_bool(false)
            end
            if data.spin then
                antiaim_ref.spin:set_bool(true)
            else
                antiaim_ref.spin:set_bool(false)
            end
            if data.speed then
                antiaim_ref.speed:set_int(data.speed)
            else
                antiaim_ref.speed:set_int(0)
            end
            -- DESYNC
            if data.fake then
                antiaim_ref.fake:set_bool(true)
            elseif if_else then
                antiaim_ref.fake:set_bool(false)
            end
            if data.disable_freestand then
                antiaim_ref.freestand:set_bool(false)
            end
            if data.flip_fake then
                antiaim_ref.flip_fake:set_bool(true)
            else
                antiaim_ref.flip_fake:set_bool(false)
            end
            if data.flip_lean then
                antiaim_ref.flip_lean:set_bool(true)
            else
                antiaim_ref.flip_lean:set_bool(false)
            end
            if data.freestand_fake then
                antiaim_ref.freestand_fake:set_int(data.freestand_fake)
            elseif if_else then
                antiaim_ref.freestand_fake:set_int(0)
            end
            if data.roll_lean then
                antiaim_ref.roll_lean:set_int(data.roll_lean)
            elseif if_else then
                antiaim_ref.roll_lean:set_int(0)
            end
            if data.lean_amount then
                if data.movement_d then
                    antiaim_ref.lean_amount:set_int(data.movement_f)
                else
                    antiaim_ref.lean_amount:set_int(data.lean_amount)
                end
            elseif if_else then
                antiaim_ref.lean_amount:set_int(0)
            end
            if data.fake_amount then
                antiaim_ref.fake_amount:set_int(data.fake_amount)
            else
                antiaim_ref.fake_amount:set_int(0)
            end
            if data.compensate_angle then
                antiaim_ref.compensate_angle:set_int(data.compensate_angle)
            else
                antiaim_ref.compensate_angle:set_int(0)
            end
            if data.jitter then
                antiaim_ref.jitter:set_bool(true)
            else
                antiaim_ref.jitter:set_bool(false)
            end
            if data.random then
                antiaim_ref.random:set_bool(true)
            else
                antiaim_ref.random:set_bool(false)
            end
            if data.ensure_lean then
                antiaim_ref.ensure_lean:set_bool(true)
            else
                antiaim_ref.ensure_lean:set_bool(false)
            end
            if data.range then
                antiaim_ref.range:set_int(data.range)
            elseif if_else then
                antiaim_ref.range:set_int(0)
            end
            if data.override then
                antiaim_ref.override:set_bool(true)
            else
                antiaim_ref.override:set_bool(false)
            end
            if data.jitter_renge then
                antiaim_ref.jitter_renge:set_int(data.jitter_renge)
            else
                antiaim_ref.jitter_renge:set_int(0)
            end
        end
    end

    function MT.Clamp(Value, Min, Max)
        return Value < Min and Min or (Value > Max and Max or Value)
    end

    local aa_stats = {
        ['standing'] = "Standing",
        ['moving'] = "Moving",
        ['air'] = "In Air",
        ['crouching'] = "Crouching",
        ['slowwalk'] = "Slowwalk",
        ['fakeduck'] = "Fakeduck",
        ['legit_aa'] = "Legit aa"
    }

    function get_velocity(local_player)
        local velocity_x = local_player:get_prop("m_vecVelocity[0]")
        local velocity_y = local_player:get_prop("m_vecVelocity[1]")
        local velocity_z = local_player:get_prop("m_vecVelocity[2]")
        local velocity = math.vec3(velocity_x, velocity_y, velocity_z)
        local speed = math.ceil(velocity:length2d())
        return speed
    end

    function MT.get_aa_stats()
        local localplayer = entities.get_entity(engine.get_local_player())
        if localplayer == nil then return end
        local velocity = get_velocity(localplayer);
        local is_slowwalk = antiaim_ref.slowwalk:get_bool();
        local flags = localplayer:get_prop("m_fFlags");
        local inAir = bit.band(flags, 1) == 0 or MT.input.is_key_down(32);
        if inAir then return "air" end
        if is_slowwalk then return "slowwalk" end
        if bit.band(flags, 2) ~= 0 then return "crouching" end
        if velocity > 3 then
            return "moving"
        else
            return "standing"
        end
    end

    function MT.SlowWalkSpeed(cmd)
        local speedvalue = categorys.slow_speed:get_int()
        local default_value = default and tonumber(speedvalue) or 450
        cmd:set_move(default_value, default_value)
    end

    function MT.lowdelta()
        MT.AAHandler({
            pitch = 1,
            stats = 1,
            yaw_add = true,
            yaw = 3,
            at_target = true,
            fake = true,
            flip_fake = false,
            flip_lean = false,
            freestand_fake = 0,
            roll_lean = 2,
            lean_amount = -50,
            fake_amount = -100,
            compensate_angle = 100,
            disable_freestand = true,
            ensure_lean = true,
            jitter = categorys.bodyyaw:get_int() == 5, 
            random = false,
            spin = true,
            range = 7,
            speed = 2,
            jitter_renge = 22,
            override = false
        }, false)
    end

    function MT.crouching()
        MT.AAHandler({
            pitch = 1,
            stats = 1,
            yaw_add = false,
            yaw = -8,
            at_target = true,
            fake = true,
            flip_fake = false,
            flip_lean = false,
            freestand_fake = 0,
            roll_lean = categorys.bodyyaw:get_int() == 5 and 0 or 5,
            lean_amount = 50,
            fake_amount = 100,
            compensate_angle = 0,
            disable_freestand = true,
            ensure_lean = true,
            jitter = true,
            random = false,
            spin = false,
            range = 8,
            speed = 3,
            jitter_renge = 12,
            override = false
        }, false)
    end

    function MT.TankAA()
        local tank_aa_slider = categorys.tank_aa_slider:get_int()
        local tank_aa_fake = categorys.tank_aa_fake:get_int()
        local fake_amount = 0
        local tank_amount = 0
        if MT.global_vars.tickcount % 6 > 3 then
            fake_amount = tank_aa_fake
            tank_amount = tank_aa_slider
        else
            fake_amount = -tank_aa_fake
            tank_amount = -tank_aa_slider
        end
        MT.AAHandler({
            pitch = 1,
            stats = 1,
            yaw_add = true,
            yaw = tank_amount,
            at_target = false,
            fake = true,
            flip_fake = true,
            flip_lean = true,
            freestand_fake = 0,
            roll_lean = 5,
            lean_amount = fake_amount,
            fake_amount = 100,
            compensate_angle = 0,
            ensure_lean = false,
            jitter = false,
            random = false,
            range = 0,
            override = true
        }, false)
    end

    function MT.Legbreaker()
        antiaim_ref.leg_slide:set_int(MT.global_vars.tickcount % 6 > 3 and 0 or 2)
    end

    function MT.LegitAA()
        local faketype = 0
        if categorys.legit_aa_modes:get_int() == 0 then
            faketype = 2
        elseif categorys.legit_aa_modes:get_int() == 1 then
            faketype = 2
        elseif categorys.legit_aa_modes:get_int() == 2 then
            faketype = 5
        end
        MT.AAHandler({
            pitch = 0,
            stats = 0,
            yaw_add = false,
            yaw = 3,
            at_target = false,
            fake = true,
            flip_fake = false,
            flip_lean = false,
            freestand_fake = 0,
            roll_lean = categorys.bodyyaw:get_int() == 5 and 0 or faketype,
            lean_amount = 50,
            fake_amount = 100,
            compensate_angle = 0,
            ensure_lean = true,
            jitter = false,
            random = false,
            range = 0,
            override = false
        }, false, true)
    end

    function MT.Movement()
        local is_left = MT.input.is_key_down(65)
        local is_right = MT.input.is_key_down(68)
        if is_left then
            antiaim_stats.movement = false
        end
        if is_right then
            antiaim_stats.movement = true
        end
        return antiaim_stats.movement
    end

    function MT.InAir()
        MT.AAHandler({
            pitch = 1,
            stats = 1,
            yaw_add = true,
            yaw = 7,
            at_target = true,
            fake = true,
            flip_fake = false,
            flip_lean = true,
            freestand_fake = 0,
            roll_lean = categorys.bodyyaw:get_int() == 5 and 0 or 2,
           --roll_lean = tickcount(100) == 100 and 0 or 2,
            lean_amount = 50,
            fake_amount = -100,
            compensate_angle = 0,
            disable_freestand = true,
            ensure_lean = true,
            jitter = categorys.bodyyaw:get_int() == 5,
            random = false,
            spin = false,
            range = 8,
            speed = 2,
            jitter_renge = 5,
            override = false
        }, false)
    end
    function MT.DesyncHandler()
        local randomize = false
        local aa_stats = MT.get_aa_stats()
        if categorys.tank_aa:get_bool() and aa_stats ~= "air" then
            return MT.TankAA()
        end
        if aa_stats == "slowwalk" then
            return MT.lowdelta()
        elseif aa_stats == "crouching" then
            return MT.crouching()
        elseif aa_stats == "air" then
            return MT.InAir()
        end
        if aa_stats == "standing" or aa_stats == "moving" then
            if categorys.bodyyaw:get_int() == 1 then
                return MT.AAHandler({
                    pitch = 1,
                    stats = 1,
                    yaw_add = false,
                    yaw = 7,
                    at_target = true,
                    fake = true,
                    flip_fake = false,
                    flip_lean = false,
                    freestand_fake = 1,
                    roll_lean = 3,
                    lean_amount = MT.global_vars.tickcount % 6 > 3 and -50 or 50,
                    fake_amount = MT.global_vars.tickcount % 6 > 3 and 100 or -100,
                    compensate_angle = 0,
                    ensure_lean = false,
                    jitter = false,
                    random = false,
                    range = 0,
                    override = true
                }, false, randomize)
            elseif categorys.bodyyaw:get_int() == 2 then
                local DesyncMovement = MT.Movement()
                return MT.AAHandler({
                    pitch = 1,
                    stats = 1,
                    yaw_add = false,
                    yaw = 0,
                    at_target = false,
                    fake = true,
                    flip_fake = false,
                    flip_lean = false,
                    freestand_fake = 2,
                    roll_lean = 4,
                    lean_amount = DesyncMovement and -50 or 50,
                    fake_amount = DesyncMovement and -100 or 100,
                    compensate_angle = 0,
                    ensure_lean = false,
                    jitter = false,
                    random = false,
                    range = 0,
                    override = true
                }, false, randomize)
            elseif categorys.bodyyaw:get_int() == 3 then
                local exploit = get_exploit()
                if aa_stats == "standing" then
                    return MT.AAHandler({
                        pitch = 1,
                        stats = 1,
                        yaw_add = false,
                        yaw = tickcount(6) >= 3 and -20 or 20,
                        at_target = true,
                        fake = true,
                        flip_fake = false,
                        flip_lean = false,
                        freestand_fake = 6,
                        roll_lean = 5, 
                        lean_amount = 0,
                        fake_amount = 100,
                        compensate_angle = 0,
                        ensure_lean = true,
                        jitter = true,
                        random = false,
                        spin = false,
                        range = 3,
                        speed = 1,
                        jitter_renge = 40,
                        override = true
                    }, false, randomize)
                else
                    return MT.AAHandler({
                        pitch = 1,
                        stats = 1,
                        yaw_add = false,
                        yaw = tickcount(6) >= 3 and -5 or 5,
                        at_target = true,
                        fake = true,
                        flip_fake = false,
                        flip_lean = false,
                        freestand_fake = 1,
                        roll_lean = 3, 
                        lean_amount = 06,
                        fake_amount = 100,
                        compensate_angle = 0,
                        ensure_lean = false,
                        jitter = true,
                        random = false,
                        spin = false,
                        range = 5,
                        speed = 1,
                        jitter_renge = 0,
                        override = true
                    }, false, randomize)
                end
            elseif categorys.bodyyaw:get_int() == 4 then
                if aa_stats == "standing" then
                    return MT.AAHandler({
                        pitch = 1,
                        stats = 1,
                        yaw_add = true,
                        yaw = MT.global_vars.tickcount % 6 > 3 and -10 or 10,
                        at_target = true,
                        fake = true,
                        flip_fake = true,
                        flip_lean = true,
                        freestand_fake = 2,
                        roll_lean = 5, 
                        lean_amount = 50,
                        fake_amount = MT.global_vars.tickcount % 6 > 3 and -75 or 75,
                        compensate_angle = 0,
                        ensure_lean = false,
                        jitter = false,
                        random = false,
                        spin = false,
                        range = 3,
                        speed = 1,
                        override = true
                    }, false, randomize)
                else
                    return MT.AAHandler({
                        pitch = 1,
                        stats = 1,
                        yaw_add = true,
                        yaw = -1,
                        at_target = true,
                        fake = true,
                        flip_fake = true,
                        flip_lean = true,
                        freestand_fake = 2,
                        roll_lean = 5, 
                        lean_amount = 35,
                        fake_amount = MT.global_vars.tickcount % 6 > 3 and -75 or 75,
                        compensate_angle = 0,
                        ensure_lean = true,
                        jitter = true,
                        random = false,
                        spin = true,
                        range = 3,
                        speed = 1,
                        override = true
                    }, false, randomize)
                end
            elseif categorys.bodyyaw:get_int() == 5 then
                if aa_stats == "standing" then
                    return MT.AAHandler({
                        pitch = 1, 
                        stats = 1,
                        yaw_add = true,
                        yaw = tickcount(6) >= 3 and -20 or 25,
                        at_target = true,
                        fake = true,
                        flip_fake = false,
                        flip_lean = false,
                        freestand_fake = tickcount(6) >= 3 and 1 or 2,
                        roll_lean = 2, 
                        lean_amount = 0,
                        fake_amount = -170,
                        compensate_angle = 0,
                        ensure_lean = true,
                        jitter = true,
                        random = false,
                        spin = false,
                        range = 3,
                        speed = 1,
                        jitter_renge = 25,
                        override = true
                    }, false, randomize)
                else
                    return MT.AAHandler({
                        pitch = 1,
                        stats = 1,
                        yaw_add = false,
                        yaw = tickcount(6) >= 3 and -math.random(20, 30) or math.random(20, 30),
                        at_target = true,
                        fake = true,
                        flip_fake = false,
                        flip_lean = false,
                        freestand_fake = tickcount(6) >= 3 and 1 or 2,
                        roll_lean = 3, 
                        lean_amount = 0,
                        fake_amount = -170,
                        compensate_angle = 0,
                        ensure_lean = false,
                        jitter = true,
                        random = false,
                        spin = false,
                        range = 5,
                        speed = 1,
                        jitter_renge = 22,
                        override = true
                    }, false, randomize)
                end
            else
                antiaim_stats.base[aa_stats].movement_d = false
            end
        end
    end
    local dt_status = nil
    function MT.Ragebot()
        local mt_speed = categorys.doubletap_speed:get_int()
        local mt_clock = categorys.clock_correction:get_bool()
        local sv_cheat = MT.cvar.sv_cheats
        local sv_maxusrcmd = MT.cvar.sv_maxusrcmdprocessticks
        local disable_clock = MT.cvar.cl_clock_correction
        local disable_clock_amount = MT.cvar.cl_clock_correction_adjustment_max_amount
        local disable_clock_offset = MT.cvar.cl_clock_correction_adjustment_max_offset
        if sv_cheat:get_int() ~= 1 then
            sv_cheat:set_int(1)
        end
        -- if sv_maxusrcmd:get_int() ~= mt_speed then
        --     sv_maxusrcmd:set_int(mt_speed)
        -- end
        -- if mt_clock then
        --     if disable_clock:get_int() == 1 then
        --         disable_clock:set_int(0)
        --         disable_clock_amount:set_int(450)
        --         disable_clock_offset:set_int(800)
        --     end
        -- else
        --     if disable_clock:get_int() == 0 then
        --         disable_clock:set_int(1)
        --         disable_clock_amount:set_int(200)
        --         disable_clock_offset:set_int(30)
        --     end
        -- end
        if categorys.idealtick:get_bool() and antiaim_ref.quickpeek:get_bool() then
            if categorys.rollresolver:get_bool() then
                antiaim_ref.resolver:set_int(0)
            end
            if dt_status == nil then
                dt_status = antiaim_ref.doubletap:get_bool()
            end
            antiaim_ref.doubletap:set_bool(true)
        else
            if categorys.rollresolver:get_bool() then
                antiaim_ref.resolver:set_int(1)
            end
            if dt_status ~= nil then
                antiaim_ref.doubletap:set_bool(dt_status)
                dt_status = nil
            end
        end
    end
    local anim = {
        g_wait = 6,
        g_animtime = 1,
        g_switch = false,
    }

    local glitch = {
        list = {},
        realtime = MT.global_vars.realtime,
        range = 1,
    }

    function MT.AddGlitchText(key, x, y)
        if not glitch.list[key] then
            glitch.list[key] = {}
            glitch.list[key] = {x = x, y = y, g_x = 0, g_y = 0}
        else
            glitch.list[key].x = x
            glitch.list[key].y = y
        end
    end

    function MT.updateGlitchType()
        if (MT.global_vars.realtime % 0.4 >= 0.2) then
            for k,v in pairs(glitch.list) do
                local location = csgo.vector2(math.random(v.x - glitch.range, v.x + glitch.range), math.random(v.y - glitch.range, v.y + glitch.range))
                glitch.list[k].g_x = location.x
                glitch.list[k].g_y = location.y
            end
        end
    end

    local fonts = MT.render.create_font("verdana.ttf", 12)
    local IndFont = MT.render.create_font("tahoma.ttf", 14)
    local Font = MT.render.create_font("verdana.ttf", 10)
    local fastduck = {
        timer = 0,
        in_air = false,
    }
    function MT.FastDK()
        local aa_stats = MT.get_aa_stats()
        if aa_stats == 'air' and MT.input:is_key_down(17) then
            if not fastduck.in_air then
                fastduck.timer = globals.realtime
                fastduck.in_air = true
            end
        else
            if fastduck.in_air then
                if globals.realtime - fastduck.timer >= 0.5 then
                    fastduck.timer = 0
                    fastduck.in_air = false
                    MT.sleep(function ()
                        antiaim_ref.fakeduck:set_bool(true)
                        MT.sleep(function ()
                            antiaim_ref.fakeduck:set_bool(false)
                        end, 0.05)
                    end, 0.2)
                end
            end
        end
    end

    function MT.Main(cmd, send_packet)
        send_packet = false
        if categorys.madtech:get_bool() then
            -- if globals.realtime % 0.3 >= 0.05 then
                local localplayer = MT.getLocalplayer()
                if not localplayer then return end
                if MT.input.is_key_down(69) then
                    MT.LegitAA()
                else
                    MT.DesyncHandler()
                end
                if categorys.leg_breaker:get_bool() then
                    MT.Legbreaker()
                end
                if categorys.fastduck:get_bool() then
                    -- MT.FastDK()
                end
                MT.Ragebot()
            -- end
            if categorys.fakelag_switch:get_bool() then
                antiaim_ref.fakelag:set_int(tickcount(12) > 6 and 1 or categorys.fakelag:get_int())
            end
        end
    end

    function MT.damage_override()
        local localplayer = MT.getLocalplayer()
        local weapon_id = 0
        local weaponHandle = localplayer:get_prop("m_hMyWeapons", 1);
        if weaponHandle then
            local weapon_h = MT.entities.get_entity_from_handle(weaponHandle)
            if weapon_h then
                weapon_id = weapon_h:get_class_id()
            end
        end
        local override = false
        if weapon_id == 242 or weapon_id == 261 then
            override = MT.config:get_weapon_setting("autosniper", "mindmg_override_enabled"):get_bool();
        elseif weapon_id == 267 then
            override = MT.config:get_weapon_setting("scout", "mindmg_override_enabled"):get_bool();
        elseif weapon_id == 233 then
            override = MT.config:get_weapon_setting("awp", "mindmg_override_enabled"):get_bool();
        elseif weapon_id == 46 then
            override = MT.config:get_weapon_setting("heavy_pistol", "mindmg_override_enabled"):get_bool();
        elseif weapon_id == 246 or weapon_id == 245 or weapon_id == 239 or weapon_id == 269 or weapon_id == 241 or weapon_id == 258 then
            override = MT.config:get_weapon_setting("pistol", "mindmg_override_enabled"):get_bool();
        else
            override = MT.config:get_weapon_setting("other", "mindmg_override_enabled"):get_bool();
        end
        return override
    end
    local ind_loc = 0
    local ind_new_loc = 0

    function MT.UI()
        local localplayer = MT.getLocalplayer()
        local screenSize = {MT.render.get_screen_size()}
        local margin_x = 20;
        local paddings = 8;

        local GradientIncrement = ((1 / anim.g_wait) * MT.global_vars.frametime) 
        anim.g_animtime = MT.Clamp(anim.g_animtime + (anim.g_switch and GradientIncrement or - GradientIncrement), 0.5, 1)
        if anim.g_animtime == 0.5 then
            anim.g_switch = true
        elseif anim.g_animtime == 1 then
            anim.g_switch = false
        end
        local GradientAlpha = math.floor(255 * anim.g_animtime)
        GradientLeft = MT.render.color(55, 39, 180, GradientAlpha)
        GradientRight = MT.render.color(171, 7, 74, GradientAlpha)
        GradientCenter = MT.render.color(109, 27, 133, GradientAlpha)
        local localPing = 0;
        local indicator_text = ""
        if localplayer then
            indicator_text = string.format("MadTechnology | Release(%s) | %s[LIVE] | ms: %s", MT.version, MT.username, localPing)
        else
            indicator_text = string.format("MadTechnology | Release(%s) | %s[LIVE]", MT.version, MT.username)
        end
        local watermark_size = {MT.render.get_text_size(fonts, indicator_text)};
        local start_x = screenSize[1] - watermark_size[1] - margin_x - paddings * 1;
        local end_x = screenSize[1] - margin_x;
        MT.render:rect_filled(start_x, 5, watermark_size[1] + paddings * 2, 18, MT.render.color(38, 33, 72, 255))
        MT.render:rect_fade(start_x + paddings - 8, 23, watermark_size[1] + paddings + 8, 2, GradientLeft, GradientRight, true)
        MT.AddGlitchText("MAD", start_x + paddings, 7)
        MT.AddGlitchText("MAD_1", start_x + paddings - 1, 9)
        MT.render:text(fonts, glitch.list['MAD'].g_x, glitch.list['MAD'].g_y + 0.5, indicator_text, MT.render.color(255, 0, 72, 150))
        MT.render:text(fonts, glitch.list['MAD_1'].g_x, glitch.list['MAD_1'].g_y - 0.5, indicator_text, MT.render.color(50, 52, 255, 150))
        MT.render:text(fonts, start_x + paddings, 8, indicator_text, MT.render.color(255, 255, 255, 255));
        local screensize = MT.render:screen_size()
        local screen_h = {screenSize[1] / 2, screenSize[2] / 2}
        if categorys.desync_i:get_bool() and localplayer and localplayer:is_alive() then
            if MT.scope > 0 then
                if ind_loc <= 35 then
                    ind_loc = ind_loc + 1 
                end
            else
                if ind_loc > 0 then
                    ind_loc = ind_loc - 1
                end
            end
            local _h = 8
            MT.AddGlitchText("MADTECH", screen_h[1] - 24 + ind_loc, screen_h[2] + _h)
            MT.AddGlitchText("MADTECH_1", screen_h[1] - 25 + ind_loc, screen_h[2] + _h)
            MT.render:text(IndFont, glitch.list['MADTECH'].g_x, glitch.list['MADTECH'].g_y, "MADTECH", MT.render.color(255, 0, 72, 150))
            MT.render:text(IndFont, glitch.list['MADTECH_1'].g_x, glitch.list['MADTECH_1'].g_y, "MADTECH", MT.render.color(50, 52, 255, 150))
            MT.render:text(IndFont, screen_h[1] - 24 + ind_loc, screen_h[2] + _h, "MADTECH", MT.render.color(255, 255, 255, 255))
            local antiaims_stats = aa_stats[MT.get_aa_stats()]:upper()
            local stats_size = MT.render.get_text_size(IndFont, antiaims_stats);
            MT.AddGlitchText("STATS", math.floor(screen_h[1] - ((stats_size.x / 2) - 0.5)) + ind_loc, screen_h[2] + _h + 10)
            MT.AddGlitchText("STATS_1", math.floor(screen_h[1] - ((stats_size.x / 2) - 1)) + ind_loc, screen_h[2] + _h + 10)
            MT.render:text(IndFont, glitch.list['STATS'].g_x, glitch.list['STATS'].g_y, antiaims_stats, MT.render.color(255, 0, 72, 150))
            MT.render:text(IndFont, glitch.list['STATS_1'].g_x, glitch.list['STATS_1'].g_y, antiaims_stats, MT.render.color(50, 52, 255, 150))
            MT.render:text(IndFont, screen_h[1] - ((stats_size.x / 2) - 0.5) + ind_loc, screen_h[2] + _h + 10, antiaims_stats, MT.render.color(255, 255, 255, 255))
            MT.AddGlitchText("BINDS", screen_h[1] - 24 + ind_loc, screen_h[2] + _h + 21)
            MT.AddGlitchText("BINDS_1", screen_h[1] - 25 + ind_loc, screen_h[2] + _h + 21)
            MT.render:text(Font, glitch.list['BINDS'].g_x, glitch.list['BINDS'].g_y, "DT", MT.render.color(255, 0, 72, 150))
            MT.render:text(Font, glitch.list['BINDS_1'].g_x, glitch.list['BINDS_1'].g_y, "DT", MT.render.color(50, 52, 255, 150))
            MT.render:text(Font, screen_h[1] - 24 + ind_loc, screen_h[2] + _h + 21, "DT", antiaim_ref.doubletap:get_bool() and MT.render.color(196, 166, 255, 255) or MT.render.color(255, 255, 255, 255) )
            MT.render:text(Font, glitch.list['BINDS'].g_x + 18, glitch.list['BINDS'].g_y, "MD", MT.render.color(255, 0, 72, 150))
            MT.render:text(Font, glitch.list['BINDS_1'].g_x + 18, glitch.list['BINDS_1'].g_y, "MD", MT.render.color(50, 52, 255, 150))
            MT.render:text(Font, screen_h[1] - 6 + ind_loc, screen_h[2] + _h + 21, "MD", MT.damage_override() and MT.render.color(196, 166, 255, 255) or MT.render.color(255, 255, 255, 255))
            MT.render:text(Font, glitch.list['BINDS'].g_x + 38, glitch.list['BINDS'].g_y, "HS", MT.render.color(255, 0, 72, 150))
            MT.render:text(Font, glitch.list['BINDS_1'].g_x + 38, glitch.list['BINDS_1'].g_y, "HS", MT.render.color(50, 52, 255, 150))
            MT.render:text(Font, screen_h[1] + 14 + ind_loc, screen_h[2] + _h + 21, "HS", antiaim_ref.hideshot:get_bool() and MT.render.color(196, 166, 255, 255) or MT.render.color(255, 255, 255, 255))

        end
        MT.updateGlitchType()
    end

    function on_paint()
    end
    function on_create_move(cmd, send_packet)
        g_tickcount = g_tickcount + 1
        MT.Main(cmd, send_packet)
    end
end

MT.R()
