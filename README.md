# Computertest

A ComputerCraft-inspired mod for Minetest!

![Computertest](banner.png)

## Working Features

- LUA can be uploaded and ran on a turtle (see [/examples]())
- Actions like mining, moving and turning the turtle
- Turtles take time to do actions such as moving,mining,turning,etc
- A "computertest" privilege, to limit turtle usage to trusted users (so only users with this privilege can use/edit turtles) 

## Changes are Welcome!

Anyone interested in adding these features can try in entity/turtle.lua, I'd be interested in any great working pull requests!

### Features to Add

- Add dumping into chests to create fully-auto mining
- Add fuel, so everything consumes fuel until it runs out or refuels
- Inventory management commands, such as crafting, sorting, and dropping
- The turtle code isn't sandboxed, so turtles could call dangerous functions. This has been mitigated by the "computertest" privilege, but proper sandboxing would work best.