
local FORMNAME_TURTLE_INVENTORY = "computertest:turtle:inventory:"
local FORMNAME_TURTLE_NOPRIV    = "computertest:turtle:nopriv:"
local FORMNAME_TURTLE_TERMINAL  = "computertest:turtle:terminal:"
local FORMNAME_TURTLE_UPLOAD    = "computertest:turtle:upload:"

local FORM_NOPRIV = "size[9,1;]label[0,0;You do not have the 'computertest' privilege.\nThis is required for interacting with turtles.]";

local TURTLE_INVENTORYSIZE = 4*4

---@returns TurtleEntity of that ID
local function getTurtle(id) return computertest.turtles[id] end
---@returns true
local function isValidInventoryIndex(index) return 0 < index and index <= TURTLE_INVENTORYSIZE end
local function has_computertest_priv(player) return minetest.check_player_privs(player,"computertest") end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local function isForm(name)
        return string.sub(formname,1,string.len(name))==name
    end
    --minetest.debug("FORM SUBMITTED",dump(player),dump(formname),dump(fields))
    if isForm(FORMNAME_TURTLE_INVENTORY) then
        local id = tonumber(string.sub(formname,1+string.len(FORMNAME_TURTLE_INVENTORY)))
        local turtle = getTurtle(id)
        if (fields.upload_code=="Upload Code") then
            minetest.show_formspec(player:get_player_name(),FORMNAME_TURTLE_UPLOAD..id,turtle:get_formspec_upload());
        elseif (fields.open_terminal=="Open Terminal") then
            minetest.show_formspec(player:get_player_name(),FORMNAME_TURTLE_TERMINAL..id,turtle:get_formspec_terminal());
        elseif (fields.factory_reset=="Factory Reset") then
            return not turtle:upload_code_to_turtle(player,"",false)
        end
    elseif isForm(FORMNAME_TURTLE_TERMINAL) then
        if (fields.terminal_out ~= nil) then
            return true
        end
        local id = tonumber(string.sub(formname,1+string.len(FORMNAME_TURTLE_TERMINAL)))
        local turtle = getTurtle(id)
        turtle.lastCommandRan = fields.terminal_in
        local command = fields.terminal_in
        if command==nil or command=="" then
            return nil
        end
        command = "function init(turtle) return "..command.." end"
        local commandResult = turtle:upload_code_to_turtle(player,command, true)
        if (commandResult==nil) then
            minetest.close_formspec(player:get_player_name(),FORMNAME_TURTLE_TERMINAL..id)
            return true
        end
        commandResult = fields.terminal_in.." -> "..commandResult
        turtle.previous_answers[#turtle.previous_answers+1] = commandResult
        minetest.show_formspec(player:get_player_name(),FORMNAME_TURTLE_TERMINAL..id,turtle:get_formspec_terminal());
    elseif isForm(FORMNAME_TURTLE_UPLOAD) then
        local id = tonumber(string.sub(formname,1+string.len(FORMNAME_TURTLE_UPLOAD)))
        if (fields.button_upload == nil or fields.upload == nil) then
            return true
        end
        local turtle = getTurtle(id)
        return not turtle:upload_code_to_turtle(player,fields.upload,false)
    else
        return false--Unknown formname, input not processed
    end
    return true--Known formname, input processed "If function returns `true`, remaining functions are not called"
end)

--Code responsible for updating turtles every turtle_tick
local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    while (timer >= computertest.config.turtle_tick) do
        for _,turtle in pairs(computertest.turtles) do
            if turtle.coroutine then
                if coroutine.status(turtle.coroutine)=="suspended" then
                    if (turtle.fuel>0) then
                        local status, result = coroutine.resume(turtle.coroutine)
                        turtle:debug("coroutine stat "..dump(status).." said "..dump(result))
                        turtle:debug("fuel="..turtle.fuel)
                    else
                        turtle:debug("No Fuel in turtle")
                    end
                end
                --elseif coroutine.status(turtle.coroutine)=="dead" then
                --minetest.log("turtle #"..id.." has coroutine, but it's already done running")
            elseif turtle.code then
                --minetest.log("turtle #"..id.." has no coroutine but has code! Making coroutine...")
                --TODO add some kinda timeout into coroutine
                turtle.coroutine = coroutine.create(function()
                    turtle.code()
                    init(turtle)
                end)
                --else
                --minetest.log("turtle #"..id.." has no coroutine or code, who cares...")
            end
        end
        timer = timer - computertest.config.turtle_tick
    end
end)
--Code responsible for generating turtle entity and turtle interface

local TurtleEntity = {
    initial_properties = {
        hp_max = 20,
        is_visible = true,
        makes_footstep_sound = false,
        physical = true,
        collisionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
        visual = "cube",
        visual_size = { x = 0.9, y = 0.9 },
        textures = {
            "computertest_top.png",
            "computertest_bottom.png",
            "computertest_right.png",
            "computertest_left.png",
            "computertest_back.png",
            "computertest_front.png",
        },
        automatic_rotate = 0,
        id = -1
    },
}

--MAIN TURTLE HELPER FUNCTIONS------------------------------------------
function TurtleEntity:getTurtleslot(turtleslot)
    if not isValidInventoryIndex(turtleslot) then return nil end
    return self.inv:get_stack("main",turtleslot)
end
function TurtleEntity:setTurtleslot(turtleslot, stack)
    if not isValidInventoryIndex(turtleslot) then return false end
    self.inv:set_stack("main", turtleslot,stack)
    return true
end
function TurtleEntity:move(nodeLocation)
    --Verify new pos is empty
    if (nodeLocation == nil or minetest.get_node(nodeLocation).name~="air") then
        self:yield("Moving")
        return false
    end
    --Take Action
    self.object:set_pos(nodeLocation)
    self:yield("Moving",true)
    return true
end
function TurtleEntity:mine(nodeLocation)
    if nodeLocation == nil then
        return false
    end
    local node = minetest.get_node(nodeLocation)
    if (node.name=="air") then
        return false
    end
    --Try sucking the inventory (in case it's a chest)
    self:itemSuck(nodeLocation)
    local drops = minetest.get_node_drops(node)
    --TODO NOTE This violates spawn protection, but I know of no way to mine that abides by spawn protection AND picks up all items and contents (dig_node drops items and I don't know how to pick them up)
    minetest.remove_node(nodeLocation)
    for _, iteminfo in pairs(drops) do
        local stack = ItemStack(iteminfo)
        if self.inv:room_for_item("main",stack) then
            self.inv:add_item("main",stack)
        end
    end
    self:yield("Mining",true)
    return true
end
function TurtleEntity:build(nodeLocation, turtleslot)
    if nodeLocation == nil then return false end
    if not isValidInventoryIndex(turtleslot) then return false end

    local node = minetest.get_node(nodeLocation)
    if node.name~="air" then return false end

    --Build and consume item
    local stack = self:getTurtleslot("main", turtleslot)
    if stack:is_empty() then return false end
    local newstack, position_placed = minetest.item_place_node(stack, nil, { type="node", under=nodeLocation, above=self:get_pos()})
    self.inv:set_stack("main", turtleslot,newstack)

    if position_placed == nil then
        self:yield("Building")
        return false
    end

    self:yield("Building",true)
    return true
end
function TurtleEntity:scan(nodeLocation) return minetest.get_node(nodeLocation) end

--[[    Sucks inventory (chest, node, furnace, etc) at nodeLocation into turtle
@returns true if it sucked everything up]]
--function TurtleEntity:suckBlock(nodeLocation)
--    local suckedEverything = true
--    local nodeInventory = minetest.get_inventory({type="node", pos=nodeLocation})
--    if not nodeInventory then
--        return true --No node inventory, nothing left to suck
--    end
--    for listname,listStacks in pairs(nodeInventory:get_lists()) do
--        for stackI,itemStack in pairs(listStacks) do
--            if self.inv:room_for_item("main",itemStack) then
--                local remainingItemStack = self.inv:add_item("main",itemStack)
--                nodeInventory:set_stack(listname, stackI, remainingItemStack)
--            else
--                suckedEverything = false
--            end
--        end
--    end
--    return suckedEverything
--end

---Takes everything from block that matches list
--- @param filterlist - Something like {"default:stone","default:dirt"}
--- @param isWhitelist - If true, only take things in list.
---         If false, take everything EXCEPT the items in the list
--- @param listname - take only from specific listname. If nil, take from every list
--- @return boolean true unless any items can't fit
function TurtleEntity:itemSuck(nodeLocation, filterlist, isWhitelist, listname)
    filterlist = filterlist or {}
    local suckedEverything = true
    local nodeInventory = minetest.get_inventory({type="node", pos=nodeLocation})
    if not nodeInventory then
        return true --No node inventory, nothing left to suck
    end

    local function suckList(listname, listStacks)
        local function intable(item)
            for _,x in pairs(filterlist) do
                if item==x then return true end
            end
            return false
        end
        for stackI,itemStack in pairs(listStacks) do
            if intable(itemStack:get_name()) == isWhitelist then
                local remainingItemStack = self.inv:add_item("main",itemStack)
                nodeInventory:set_stack(listname, stackI, remainingItemStack)
                suckedEverything = suckedEverything and remainingItemStack:is_empty()
            end
        end
    end

    if listname then
        suckList(listname, nodeInventory:get_list(listname))
    else
        for listname,listStacks in pairs(nodeInventory:get_lists()) do
            suckList(listname, listStacks)
        end
    end
    return suckedEverything
end

function TurtleEntity:itemSuckForward(filterlist, isWhitelist, listname) return self:itemSuck(self:getLocForward(), filterlist, isWhitelist, listname) end

---Takes everything from block that matches list
--- @param filterlist - Something like {"default:stone","default:dirt"}
--- @param isWhitelist - If true, only take things in list.
---         If false, take everything EXCEPT the items in the list
--- @param listname - take only from specific listname. If nil, take from every list
--- @return boolean true if stack completely pushed
function TurtleEntity:itemPush(nodeLocation, turtleslot, filterlist, isWhitelist, listname)
    listname = listname or "main"

    local nodeInventory = minetest.get_inventory({type="node", pos=nodeLocation})--InvRef
    if not nodeInventory then
        return false --No node inventory (Ex: Not a chest)
    end

    --Try putting my stack somewhere
    local toPush = self:getTurtleslot(turtleslot)
    local remainingItemStack = nodeInventory:add_item(listname,toPush)
    self:setTurtleslot(turtleslot, remainingItemStack)

    return remainingItemStack:is_empty()
end
---
---@returns true on success
---
function TurtleEntity:upload_code_to_turtle(player, code_string,run_for_result)
    --Check permissions
    if (not has_computertest_priv(player)) then
        --minetest.debug(player:get_player_name().." does not have computertest priv")
        return false
    end
    local function sandbox(code)
        --TODO sandbox this!
        --Currently returns function that defines init and loop. In the future, this should probably just initialize it using some callbacks
        if (code =="") then return nil end
        return loadstring(code)
    end
    self.codeUncompiled = code_string
    self.coroutine = nil
    self.code = sandbox(self.codeUncompiled)
    if (run_for_result) then
        --TODO run subroutine once, if it returns a value, return that here
        return "Ran"
    end
    return self.code ~= nil
end
--MAIN TURTLE USER INTERFACE------------------------------------------
function TurtleEntity:get_formspec_inventory()
    return "size[12,5;]"
            .."button[0,0;2,1;open_terminal;Open Terminal]"
            .."button[2,0;2,1;upload_code;Upload Code]"
            .."button[4,0;2,1;factory_reset;Factory Reset]"
            .."set_focus[open_terminal;true]"
            .."list[".. self.inv_fullname..";main;8,1;4,4;]"
            .."background[8,1;1,1;computertest_inventory.png]"
            .."list[current_player;main;0,1;8,4;]";
end
function TurtleEntity:get_formspec_terminal()
    local previous_answers = self.previous_answers
    local parsed_output = "";
    for i=1, #previous_answers do
        parsed_output = parsed_output .. minetest.formspec_escape(previous_answers[i])..","
    end
    return
        "size[12,9;]"
        .."field_close_on_enter[terminal_in;false]"
        .."field[0,0;12,1;terminal_in;;"..minetest.formspec_escape(self.lastCommandRan or "").."]"
        .."set_focus[terminal_in;true]"
        .."textlist[0,1;12,8;terminal_out;"..parsed_output.."]";
end
function TurtleEntity:get_formspec_upload()
    --TODO could indicate if code is already uploaded
    return
        "size[12,9;]"
        .."button[0,0;3,1;button_upload;Upload Code to '"..self.name.."']"
        .."field_close_on_enter[upload;false]"
        .."textarea[0,1;12,8;upload;;"..minetest.formspec_escape(self.codeUncompiled or "").."]"
        .."set_focus[upload;true]";
end
--MAIN TURTLE ENTITY FUNCTIONS------------------------------------------
function TurtleEntity:on_activate(staticdata, dtime_s)
    --TODO use staticdata to load previous state, such as inventory and whatnot
    --Give ID
    computertest.num_turtles = computertest.num_turtles+1
    self.id = computertest.num_turtles
    self.name = "Unnamed #"..self.id
    --self.owner = minetest.get_meta(pos):get_string("owner")
    self.heading = 0
    self.previous_answers = {}
    self.coroutine = nil
    self.fuel = computertest.config.fuel_initial
    --Give her an inventory
    self.inv_name = "computertest:turtle:".. self.id
    self.inv_fullname = "detached:".. self.inv_name
    local inv = minetest.create_detached_inventory(self.inv_name,{})
    if inv == nil or inv == false then error("Could not spawn inventory")end
    inv:set_size("main", TURTLE_INVENTORYSIZE)
    if self.inv ~= nil then inv.set_lists(self.inv) end
    self.inv = inv
    -- Add to turtle list
    computertest.turtles[self.id] = self
end
function TurtleEntity:on_rightclick(clicker)
    if not clicker or not clicker:is_player() then
        return
    end
    if (not has_computertest_priv(clicker))then
        minetest.show_formspec(clicker:get_player_name(),FORMNAME_TURTLE_NOPRIV,FORM_NOPRIV);
        return
    end
    minetest.show_formspec(clicker:get_player_name(), FORMNAME_TURTLE_INVENTORY.. self.id,
            self:get_formspec_inventory())
end
function TurtleEntity:get_staticdata()
    minetest.debug("Deleting/Forgetting all data of turtle "..self.name)
    local static = {}

    --    TODO convert inventory and internal code to string and back somehow, or else it'll be deleted every time the entity gets unloaded
    --static = self -- Would this work..? no.


    static.complete = true
    return minetest.serialize(static)
end
--MAIN PLAYER INTERFACE (CALL THESE)------------------------------------------
function TurtleEntity:getLoc()     return self.object:get_pos() end
function TurtleEntity:getLocRelative(numForward,numUp,numRight)
    local pos = self:getLoc()
    if pos==nil then
        return nil -- To prevent unloaded turtles from trying to load things
    end
    local new_pos = vector.new(pos)
    if self:get_heading()%4==0 then new_pos.z=pos.z-numForward;new_pos.x=pos.x-numRight; end
    if self:get_heading()%4==1 then new_pos.x=pos.x+numForward;new_pos.z=pos.z-numRight; end
    if self:get_heading()%4==2 then new_pos.z=pos.z+numForward;new_pos.x=pos.x+numRight; end
    if self:get_heading()%4==3 then new_pos.x=pos.x-numForward;new_pos.z=pos.z+numRight; end
    new_pos.y = pos.y + (numUp or 0)
    return new_pos
end
function TurtleEntity:getLocForward()  return self:getLocRelative( 1,0,0) end
function TurtleEntity:getLocBackward() return self:getLocRelative(-1,0,0) end
function TurtleEntity:getLocUp()       return self:getLocRelative(0, 1,0) end
function TurtleEntity:getLocDown()     return self:getLocRelative(0,-1,0) end
function TurtleEntity:getLocRight()    return self:getLocRelative(0,0, 1) end
function TurtleEntity:getLocLeft()     return self:getLocRelative(0,0,-1) end
---Consumes a fuel point
function TurtleEntity:useFuel()
    if self.fuel > 0 then
        self.fuel = self.fuel - 1;
    end
end
--- From 0 to 3
function TurtleEntity:set_heading(heading)
    heading = (tonumber(heading) or 0)%4
    if self.heading ~= heading then
        self.heading = heading
        self.object:set_yaw(self.heading * 3.14159265358979323/2)
        if (coroutine.running() == self.coroutine) then self:yield("Turning",true) end
    end
end
function TurtleEntity:get_heading() return self.heading end
function TurtleEntity:turnLeft()    return self:set_heading(self:get_heading()+1) end
function TurtleEntity:turnRight()   return self:set_heading(self:get_heading()-1) end

function TurtleEntity:moveForward()  return self:move(self:getLocForward()) end
function TurtleEntity:moveBackward() return self:move(self:getLocBackward()) end
function TurtleEntity:moveUp()       return self:move(self:getLocUp()) end
function TurtleEntity:moveDown()     return self:move(self:getLocDown()) end
function TurtleEntity:moveRight()    return self:move(self:getLocRight()) end
function TurtleEntity:moveLeft()     return self:move(self:getLocLeft()) end

function TurtleEntity:mineForward()     return self:mine(self:getLocForward()) end
function TurtleEntity:mineBackward()    return self:mine(self:getLocBackward()) end
function TurtleEntity:mineUp()          return self:mine(self:getLocUp()) end
function TurtleEntity:mineDown()        return self:mine(self:getLocDown()) end
function TurtleEntity:mineRight()       return self:mine(self:getLocRight()) end
function TurtleEntity:mineLeft()        return self:mine(self:getLocLeft()) end

function TurtleEntity:buildForward(turtleslot)    return self:build(self:getLocForward(),turtleslot) end
function TurtleEntity:buildBackward(turtleslot)   return self:build(self:getLocBackward(),turtleslot) end
function TurtleEntity:buildUp(turtleslot)         return self:build(self:getLocUp(),turtleslot) end
function TurtleEntity:buildDown(turtleslot)       return self:build(self:getLocDown(),turtleslot) end
function TurtleEntity:buildRight(turtleslot)      return self:build(self:getLocRight(),turtleslot) end
function TurtleEntity:buildLeft(turtleslot)       return self:build(self:getLocLeft(),turtleslot) end

---Scan gets the info of this node
function TurtleEntity:scanForward()     return self:scan(self:getLocForward()) end
function TurtleEntity:scanBackward()    return self:scan(self:getLocBackward()) end
function TurtleEntity:scanUp()          return self:scan(self:getLocUp()) end
function TurtleEntity:scanDown()        return self:scan(self:getLocDown()) end
function TurtleEntity:scanRight()       return self:scan(self:getLocRight()) end
function TurtleEntity:scanLeft()        return self:scan(self:getLocLeft()) end

function TurtleEntity:yield(reason,useFuel)
    -- Yield at least once
    if (coroutine.running() == self.coroutine) then
        coroutine.yield(reason)
    end
    --Use a fuel if requested
    if useFuel then self:useFuel() end
end

--Inventory Interface
-- MAIN INVENTORY COMMANDS--------------------------
---    TODO drops item onto ground
function TurtleEntity:itemDrop(itemslot)

end
--- TODO Returns ItemStack on success or nil on failure
---Ex: turtle:itemGet(3):get_name() -> "default:stone"
function TurtleEntity:itemGet(turtleslot)
    return self:getTurtleslot(turtleslot)
end
---    Swaps itemstacks in slots A and B
function TurtleEntity:itemMove(turtleslotA, turtleslotB)
    if (not isValidInventoryIndex(turtleslotA)) or (not isValidInventoryIndex(turtleslotB)) then
        self:yield("Inventorying")
        return false
    end

    local stackA = self:getTurtleslot(turtleslotA)
    local stackB = self:getTurtleslot(turtleslotB)

    self:setTurtleslot(turtleslotA,stackB)
    self:setTurtleslot(turtleslotB,stackA)

    self:yield("Inventorying")
    return true
end

function TurtleEntity:itemPushForward(turtleslot, listname) return self:itemPush(turtleslot, self:getLocForward(), listname) end
function TurtleEntity:itemPushBackward(turtleslot, listname) return self:itemPush(turtleslot, self:getLocBackward(), listname) end
function TurtleEntity:itemPushUp(turtleslot, listname) return self:itemPush(turtleslot, self:getLocUp(), listname) end
function TurtleEntity:itemPushDown(turtleslot, listname) return self:itemPush(turtleslot, self:getLocDown(), listname) end
function TurtleEntity:itemPushRight(turtleslot, listname) return self:itemPush(turtleslot, self:getLocRight(), listname) end
function TurtleEntity:itemPushLeft(turtleslot, listname) return self:itemPush(turtleslot, self:getLocLeft(), listname) end

---    TODO craft using top right 3x3 grid, and put result in itemslotResult
function TurtleEntity:itemCraft(itemslotResult)
--    Use minetest.get_craft_result
end
--- @returns True if fuel was consumed. False if itemslot did not have fuel.
function TurtleEntity:itemRefuel(turtleslot)
    if (not isValidInventoryIndex(turtleslot)) then
        return false
    end

    local stack = self:getTurtleslot(turtleslot)

    local burntime = 0
    local quantity = stack:get_count()

    --TODO how do you get burntime?
    --minetest.debug(dump(minetest.get_all_craft_recipes("default:coal_lump")))
    if (stack:get_name() == "default:coal_lump") then burntime = 40 end

    if (burntime <= 0) then
        return false
    end

    self:setTurtleslot(turtleslot,nil)
    self.fuel = self.fuel + quantity * burntime * computertest.config.fuel_multiplier
    self:yield("Fueling")
    return true
end

function TurtleEntity:getFuel()    return self.fuel end
function TurtleEntity:setName(name) self.name = minetest.formspec_escape(name) end

function TurtleEntity:debug(string)
    if computertest.config.debug then
        minetest.debug("computertest turtle #"..self.id..": "..string)
    end
end
function TurtleEntity:dump(object) return dump(object) end

--    MAIN TURTLE INTERFACE END---------------------------------------
--    MAIN TURTLE INTERFACE END---------------------------------------
--    MAIN TURTLE INTERFACE END---------------------------------------

minetest.register_entity("computertest:turtle", TurtleEntity)