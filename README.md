# Computertest

A ComputerCraft-inspired mod for Minetest!

![Computertest](banner.png)

## Working Features

- LUA can be uploaded and ran on a turtle. See the [API](API.md) and the [examples](/examples/EXAMPLES.md)
- The turtle can do actions like mining, moving, turning, inventory management, and more!
- A "computertest" privilege, to limit turtle usage to trusted users (so only users with this privilege can use/edit turtles) 
- Turtles consume fuel after completing hard actions such as mining (configurable)

## An example of how to use this mod

1. Install the ComputerTest mod
2. Get a turtle block using either
    - The command `/giveme computertest:turtle`
    - The creative menu
    - The recipe
  ```
III
ICI
IMI
I = Steel Ingot , C = Chest , M = Mesa Block
```
3. Place the turtle
4. Right click it and click "Upload Code"
5. Paste this into the large field (sometimes Minetest requires you to paste twice) and click "Upload Code"
```lua
function init(turtle)
    while true do
        turtle:moveForward()
        turtle:turnRight()
    end
end
```   
6. Watch as it spins around!

## Other Information

The [API.md](API.md) contains important documentation for programming.

[EXAMPLES.md](examples/EXAMPLES.md) contains some fun examples 

## Changes are Welcome!

Anyone interested in adding these features can! in entity/turtle.lua, I'd be interested in any great working pull requests!

### Features to Add

- Inventory management commands, such as crafting and sorting
- The turtle code isn't sandboxed, so turtles could call dangerous functions. This has been mitigated by the "computertest" privilege, but proper sandboxing would work best.
