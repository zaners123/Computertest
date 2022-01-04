function buildcube(turtle, size)
    local function buildLine(moveIn,moveOut,each)
        for _ = 1, size-1 do moveIn() end
        for _ = size-1,1,-1 do
            each()
            moveOut()
        end
        each()
    end
    local buildX = (function()
        buildLine((function()turtle:moveForward()end),
                (function()turtle:moveBackward()end),
                (function()turtle:buildForward(1)end))
    end)
    local buildY = (function()
        buildLine((function()turtle:moveRight()end),
                (function()turtle:moveLeft()end),
                (function()buildX()end))
    end)
    local buildZ = (function()
        buildLine((function()turtle:moveUp()end),
                (function()turtle:moveDown()end),
                (function()buildY()end))
    end)
    buildZ()
end
function init(turtle)
    buildcube(turtle,3)
end