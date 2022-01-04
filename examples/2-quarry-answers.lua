--WARNING this is the answers to example #2, look at example #2 first!
--WARNING this is the answers to example #2, look at example #2 first!
--WARNING this is the answers to example #2, look at example #2 first!
--WARNING this is the answers to example #2, look at example #2 first!
--WARNING this is the answers to example #2, look at example #2 first!

--One solution is to do the same thing, just with more loops
local function quarry_with_loops(turtle, size)
    local x,y,z = 0,0,0
    while true do
        while true do
            while x<size-1 do
                turtle:mineForward()
                if turtle:moveForward() then x=x+1 end
            end
            while x>0 do
                if turtle:moveBackward() then x=x-1 end
            end
            if z==size then break end
            turtle:mineRight()
            if turtle:moveRight() then z=z+1 end
        end
        while z>0 do
            if turtle:moveLeft() then z=z-1 end
        end
        if y==size then break end
        turtle:mineDown()
        if turtle:moveDown() then y=y+1 end
    end
    while y>0 do
        if turtle:moveUp() then y=y-1 end
    end
end

local function quarry_with_lambdas(turtle, size)
    local function quarryLine(moveIn,moveOut,lineEnd)
        for _ = 1, size-1 do moveIn() end
        lineEnd()
        for _ = 1, size-1 do moveOut() end
    end
    local quarryX = (function()
        quarryLine(
            (function()             turtle:mineForward() turtle:moveForward() end),
            (function()turtle:moveBackward()end),
            (function()end))
    end)
    local quarryY = (function()
        quarryLine(
                (function() quarryX()turtle:mineRight();turtle:moveRight();end),
                (function()turtle:moveLeft()end),
                (function()quarryX()end))
    end)
    local quarryZ = (function()
        quarryLine(
                (function() quarryY() turtle:mineDown() turtle:moveDown() end),
                (function() turtle:moveUp() end),
                (function()quarryY()end))
    end )
    quarryZ()
end
function init(turtle)
    quarry_with_lambdas(turtle,3)
    turtle:turnRight()
    turtle:turnRight()
    quarry_with_loops(turtle,3)
end