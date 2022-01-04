computertest = {
    config = {
        --Turtles are yielded after calling long events, and resumed this often (in seconds)
        --This is how long timed turtle actions take, such as mining, moving, and placing
        turtle_tick = .5,--Default: 0.5 seconds
        --Fuel is measured in burntime seconds. A 1 second fuel allows this many actions
        fuel_multiplier = 50,--Default: 50 actions per fuel second
        --Fuel inside of turtles when they spawn
        fuel_initial = 10000000000,--Default: 1000 actions
        --Allows turtle:debug(string) to go to debug.txt
        debug = true,
    },
    turtles = {},
    num_turtles = 0,
}
local modpath = minetest.get_modpath("computertest")
dofile(modpath.."/block/turtle.lua")
dofile(modpath.."/entity/turtle.lua")
minetest.register_privilege("computertest", {
    description = "DANGEROUS: User can script on turtles. Only give to trusted users.",
})