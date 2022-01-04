--[[
    The turtle block is only used to spawn the turtle entity, then it deletes itself
]]
minetest.register_node("computertest:turtle", {
    description = "Turtle",
    tiles = {
        "computertest_top.png",
        "computertest_bottom.png",
        "computertest_right.png",
        "computertest_left.png",
        "computertest_back.png",
        "computertest_front.png",
    },
    groups = {oddly_breakable_by_hand=2},
    paramtype2 = "facedir",
    after_place_node = function(pos, placer)
        if placer and placer:is_player() then
            local meta = minetest.get_meta(pos)
            meta:set_string("owner", placer:get_player_name())
        end
    end,
    on_construct = function(pos)
        local turtle = minetest.add_entity(pos,"computertest:turtle")
        turtle = turtle:get_luaentity()
        minetest.remove_node(pos)
    end,
})
minetest.register_craft({
    output = 'computertest:turtle',
    recipe = {
        {'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
        {'default:steel_ingot', 'default:chest',       'default:steel_ingot'},
        {'default:steel_ingot', 'default:mese',        'default:steel_ingot'},
    }
})