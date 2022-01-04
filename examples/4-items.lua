--If you're low on fuel, grab fuel from somewhere
local function checkFuel(turtle)
    while turtle:getFuel() < 10 do
        for i = 1, 16 do
            turtle:itemRefuel(i)
        end
        --If you're completely out of fuel, then wait
        --(If you don't do this, the turtle will deadlock all turtles)
        if turtle:getFuel() < 10 then turtle:yield("No fuel") end
    end
end

function init(turtle)
    while true do
        checkFuel(turtle)
        turtle:itemMove(1,2)
        turtle:turnRight()
        turtle:buildForward(4)
    end
end