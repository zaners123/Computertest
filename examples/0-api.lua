
-- Generally speaking, "do action" functions return true on success and false on failure
-- See example #1 for information on how to run code

function init(turtle)
    ---set_name can be used in identification
    turtle:set_name("Mining Turtle")

    ---Move commands move the turtle relative to its heading, and take one "turtle_tick"
    ---They return true if the turtle successfully moved
    turtle:moveForward()
    turtle:moveBackward()
    turtle:moveRight()
    turtle:moveLeft()
    turtle:moveUp()
    turtle:moveDown()
    ---Turn commands turn the turtle 90 degrees, and take one "turtle_tick"
    turtle:turnLeft()
    turtle:turnRight()
    ---Mine commands break and take the items of the block, take one "turtle_tick", and use fuel
    ---They return true if the block was removed
    turtle:mineForward()
    turtle:mineBackward()
    turtle:mineRight()
    turtle:mineLeft()
    turtle:mineUp()
    turtle:mineDown()

    ---Informational commands happen instantly (don't yield)
    turtle:get_pos()--Returns something like {x = -277,y = 6,z = -1558}
    ---More turtle commands can be viewed in entity/turtle.lua (only use the ones in the interface)

    ---For inventory commands, remember that lua starts from one (itemslots go from 1-16)
    turtle:itemMove(1,2) -- Swap item in slot 1 with item in slot two
    turtle:itemRefuel(5) -- Takes fuel from slot five. The turtle needs fuel to do actions

    --- Build commands take an Itemstack and place it as a Node. Give them an inventory itemnumber (1-16)
    --- Build commands yield and use fuel
    turtle:buildForward(1) -- Places the block in slot one infront of it
    turtle:buildBackward(1)
    turtle:buildLeft(5) -- Places the block in slot five (under slot one) to the left of it
    turtle:buildRight(1)
    turtle:buildUp(1)
    turtle:buildDown(1)


    ---IMPORTANT:
    ---Yield waits one "turtle_tick" (the time this takes can be changed in the config). It does not use fuel.
    ---You MUST yield in anything that could be an infinite loop, or else your turtle will deadlock and die
    ---  Infinite loops, such as "while true do end", MUST be replaced with "while true do turtle:yield() end"
    ---  or else the server thread will freeze (This is VERY bad, the server would need restarting)
    turtle:yield(reason_string) -- Reason string can be something like "Ran out of Fuel"
end