--This example shows how to practically program the turtle for useful things, like auto-mining
--This mines in two dimensions. Perhaps to learn how to make changes by telling it to mine in three dimensions

--See example #1 on how to upload code
function init(turtle)
    local size = 5
    local z =0
    while z <size do
        local x=0
        while x<size do
            turtle:mineForward()
            if turtle:moveForward() then x=x+1 end
        end
        while x>0 do
            if turtle:moveBackward() then x=x-1 end
        end
        turtle:mineRight()
        if turtle:moveRight() then z = z +1 end
    end
    while z >0 do
        if turtle:moveLeft() then z = z -1 end
    end
end