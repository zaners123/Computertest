local function buildAny(turtle)
    local ret = false
    for i = 1, 16 do
        ret = ret or turtle:buildForward(i)
    end
    return ret
end
---Builds a sphere centered on the turtle
local function buildSphere(turtle, radius)
    local x,y,z = 0,0,0
    local function shouldBuildSphere(x,y,z) return x*x + y*y + z*z <= radius * radius end
    local function moreLeftToBuild()
        for x2=x,radius do
            if shouldBuildSphere(x2,y,z,radius) then return true end
        end
        return false
    end
    turtle:moveBackward()
    for _=1,radius do
        turtle:moveLeft();z=z-1
        turtle:moveBackward();x=x-1
        turtle:moveDown();y=y-1
    end
    while true do
        while true do
            while x<=radius and moreLeftToBuild() do
                if turtle:moveForward() then x=x+1 end
            end
            while x>-radius do
                if turtle:moveBackward() then x=x-1 end
                if shouldBuildSphere(x,y,z) then
                    while not buildAny(turtle) do
                        turtle:yield("NO BLOCKS")
                    end
                end
            end
            if z==radius then break end
            if turtle:moveRight() then z=z+1 end
        end
        if y==radius then break end
        while z>-radius do
            if turtle:moveLeft() then z=z-1 end
        end
        if turtle:moveUp() then y=y+1 end
    end
end

function init(turtle)
    for _=1,21 do turtle:moveUp() end
    buildSphere(turtle,20)
end