# ComputerTest API

This api is two parts, with notes/documentation above, and functions below.

If you're confused by Minetest terminology (node, ItemStack, etc), read [lua_api.txt](https://raw.githubusercontent.com/minetest/minetest/master/doc/lua_api.txt)

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

The turtle has 16 'turtleslots' numbered 1-16. The top-left is slot 1, to the right is slot 2. The bottom left is slot 16.

## Config

Edit init.lua in the config object at the top to change the config.
Actions take effect on restart/reload.

## Yielding

Many functions (ex: build,mine,scan,move) yield to prevent lag, balance the mod, and to prevent hanging.

You MUST have a yield in all time-consuming processes. For example:
```lua
function init(turtle)
  while (true) do
    turtle:yield("Being a good turtle")
  end
end 
```

If this function didn't have the yield, it would crash the server (freeze the server thread) 

If you don't yield, and your turtle takes too long, the entire server will lag/halt.

## Action Functions (do things)

### `turtle:yield(reason)`
- Yields

See above for the importance of yielding!

The reason can be any string, and is visible in debug.txt (can turn on/off debugging in config)

### `turtle:mine[direction]()`
- Yields
- Uses Fuel

The turtle will mine the block next to it and take the items of the block. It will take items from chests, too
They return true if the block was removed
  
### `turtle:build[direction](turtleslot)`
- Returns true if built

Places the block that's in the turtleslot.

Example: `turtle:buildForward(1)` builds the item in the top-left slot right in front of the turtle


### `turtle:scan[direction]()`
- Returns scan result

Returns the node at the given position as table in the format`{name="node_name", param1=0, param2=0}`

Returns `nil` for unloaded areas

Example `turtle:scanLeft().name=='default:stone_with_gold` tells you there's gold ore to your left

## Inventory/Fuel functions

### `turtle:setAutoRefuel(autoRefuel)`

If your fuel hits zero, with this on, your turtle will consume the first fuel-thing it sees in its inventory

### `turtle:useFuel()`
- Uses Fuel
  
  Burns fuel. Once you run out of fuel, your turtle is stuck.

### `turtle:getFuel()`

Returns the number actions you can take until needing to refuel.

If this is zero, you won't be able to do much except refuel.

### `turtle:itemRefuel(turtleslot)`

Takes fuel from this turtleslot and increases the turtle's fuel
### `turtle:move[direction]()`

- Yields
- Uses Fuel

Moves one block in that direction, yields, and consumes fuel

### `turtle:itemPush[direction](filterList, isWhitelist, listname)`

The opposite of itemSuck. Push everything from the turtle's inventory that matches some filter into the nearby block inventory
Example: `turtle:itemPushRight({"default:coal_lump","wood","tree"},true,'fuel')` takes all coal lumps,wood-group, or tree-group items from the turtle. Puts them into the furnace-to-the-right's fuel slot.
Example: `turtle:itemPushForward()` pushes everything into the front chest

### `turtle:itemSuck[direction](filterList, isWhitelist, listname)`

The opposite of itemPush. Takes everything from the node inventory that matches some filter into the turtle's inventory
Example: `turtle:itemSuckRight({"default:sand","tree"},false)` takes everything except sand or tree-group things (since false means blacklist)
Example: `turtle:itemSuckForward()` takes everything from the front chest
Example: `turtle:itemSuckBackward({},'false','dst')` takes output from the behind furnace (since src is input and dst is output)

### `itemPushTurtleslot[direciton](turtleslot, listname)`

Takes an item from a slot and puts it into the adjacent node

### `itemGet(turtleslot)`

Get the ItemStack inside a turtleslot 

Example: `turtle:itemGet(4 ):get_name()=="default:stone""` tells you if there is stone in slot 4 (the top-right slot)
Example: `turtle:itemGet(13):get_count() > 10` tells you if there is more than 10 items in slot 13 (the bottom-left slot)

### `itemDropTurtleslot[direction](turtleslot)`

Drops an item on the ground. Go to [itemPush](itemPush) for putting into chests

## Info functions

### `turtle:setName(name)`
Sets the turtle's name
### `turtle:debug(string)`
Prints string to debug.txt (can be disabled in config)

## Other Functions

I might be missing some, check out turtle.lua for more!

All functions that start with TurtleEntity are callable (although some shouldn't be such as the ones marked as helper functions)