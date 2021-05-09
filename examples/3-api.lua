
function init(turtle)
    ---Yield waits one "turtle_tick"
    turtle:yield()
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
    ---Mine commands break and take the items of the block, and take one "turtle_tick"
    ---They return true if the block was removed
    turtle:mineForward()
    turtle:mineBackward()
    turtle:mineRight()
    turtle:mineLeft()
    turtle:mineUp()
    turtle:mineDown()
    ---Informational commands happen instantly (don't yield)
    turtle:get_loc()--Returns something like {x = -277,y = 6,z = -1558}
end