computertest = {
    config = {
        globalstep_interval = 0.5,
    },
    turtles = {},
    num_turtles = 0,
}
local modpath = minetest.get_modpath("computertest")
dofile(modpath.."/block/turtle.lua")
dofile(modpath.."/entity/turtle.lua")
