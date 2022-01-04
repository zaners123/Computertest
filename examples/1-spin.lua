--This simple example will make the turtle spin clockwise forever (or until it hits an obstacle)

---The turtle calls init(turtle) on startup
---@param turtle self This is the turtle, and has many functions (see the API example for more)
function init(turtle)
    while true do
        --Many actions (moving, turning, mining, etc) take one "turtle_tick"
        --  to run to prevent destruction and increase realism. They also use fuel.
        turtle:moveForward()
        turtle:turnRight()
    end
end