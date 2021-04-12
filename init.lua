
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
    paramtype = "light",
    paramtype2 = "facedir",
})

minetest.register_craft({
    output = 'computertest:turtle',
    recipe = {
        {'default:dirt', '', ''},
        {            '', '', ''},
        {            '', '', ''},
    }
})