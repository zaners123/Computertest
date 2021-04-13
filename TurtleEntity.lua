minetest.register_entity("computertest:turtle", {
    initial_properties = {
        hp_max = 1,
        weight = 5,
        is_visible = true,
        makes_footstep_sound = false,
        physical = true,
        collisionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
        visual = "cube",
        visual_size = { x = 0.9, y = 0.9 },
        textures = {
            "computertest_top.png",
            "computertest_bottom.png",
            "computertest_right.png",
            "computertest_left.png",
            "computertest_back.png",
            "computertest_front.png",
        },
        automatic_rotate = false,
        channel = "computertest:turtle:" .. 0,
        menu = false,
        id = 0,
        status = 0,
        removed = false,
        ticket = nil,
    },
    on_activate = function(self, staticdata, dtime_s)

    end
})