--This simple example will make the turtle spin clockwise forever (or until it hits an obstacle)
--1. Install the ComputerTest mod
--2. Get a turtle block (craftable from one dirt)
--3. Place the block
--4. Click "Upload Code"
--5. Paste this into the large field (sometimes Minetest requires you to paste twice) and click "Upload Code"
--6. Watch as it digs a hole!

---The turtle calls init(turtle) on startup
---@param turtle self This is the turtle, and has many functions (see example 3 for more)
function init(turtle)
    while true do
        --All actions (moving, turning, mining, etc) take one "turtle_tick"
        --  to run to prevent destruction and increase realism
        turtle:moveForward()
        turtle:turnRight()
    end
end