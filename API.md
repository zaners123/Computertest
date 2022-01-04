# ComputerTest API

This api is two parts, with notes/documentation above, and functions below

## Init Function
See README.md for basic setup.

Once you have a turtle, you need an init function such as:
```lua
function init(turtle)
    turtle:moveForward()
end
```
## Directions
Many commands have directions. These come in sets like:
```lua
turtle:moveForward()
turtle:moveBackward()
turtle:moveRight()
turtle:moveLeft()
turtle:moveUp()
turtle:moveDown()
```

This will be referred to as `turtle:move[direction]()`

Up and down are always the same, but orientation is changed with 
```lua
turtle:turnLeft()
turtle:turnRight()
```

## The turtle's inventory

The turtle has 16 'turtleslots' numbered 1-16.

## Config

Edit init.lua in the config object at the top to change the config.
Actions take effect on restart/reload.

## Action Functions (do things)

### `turtle:yield(reason)`
- Yields

Many functions yield to prevent lag, balance the mod, and to prevent hanging.
You MUST have a yield in all time-consuming processes.
If you don't yield, and your turtle takes too long, the entire server will lag/halt.
The reason can be any string, and is visible in debug.txt (can turn on/off debugging in config)
###`turtle:mine[direction]()`
- Yields
- Uses Fuel
The turtle will mine the block next to it and take the items of the block. It will take items from chests, too
They return true if the block was removed
  
## Inventory/Fuel functions

### `turtle:useFuel()`
- Uses Fuel
  Burns fuel. Once you run out of fuel, your turtle is stuck.
### `turtle:getFuel()`
Returns the number actions you can take until needing to refuel.
If this is zero, you won't be able to do much except refuel.
### `turtle:itemRefuel(turtleslot)`
Takes fuel from this turtleslot and increases the turtle's fuel
###`turtle:move[direction]()`
- Yields
- Uses Fuel

Moves one block in that direction, yields, and consumes fuel

## Info functions

###`turtle:setName(name)`
Sets the turtle's name
###`turtle:debug(string)`
Prints string to debug.txt (can be disabled in config)

## Other Functions

I might be missing some, check out turtle.lua for more!

All functions that start with TurtleEntity are callable (although some shouldn't be such as the ones marked as helper functions)