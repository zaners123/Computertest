computertest = {
    config = {
        --Turtles are yielded after calling long events, and resumed this often (in seconds)
        turtle_tick = 0.5,
        --Fuel is measured in burntime seconds. A 1 second fuel allows this many actions
        fuel_multiplier = 50,
    },
    turtles = {},
    num_turtles = 0,
}
local modpath = minetest.get_modpath("computertest")
dofile(modpath.."/block/turtle.lua")
dofile(modpath.."/entity/turtle.lua")
