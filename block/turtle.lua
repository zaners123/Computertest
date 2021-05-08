--[[
    The turtle block is only used to spawn the turtle entity, then it deletes itself
]]
minetest.register_node("computertest:turtle", {
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
    on_construct = function(pos)
        local turtle = minetest.add_entity(pos,"computertest:turtle")
        turtle = turtle:get_luaentity()
        minetest.remove_node(pos)
    end,
})
minetest.register_craft({
    output = 'computertest:turtle',
    recipe = {
        {'default:dirt', '', ''},
        {            '', '', ''},
        {            '', '', ''},
    }
})