
local FORMNAME_TURTLE_INVENTORY = "computertest:turtle:inventory:"
local FORMNAME_TURTLE_TERMINAL  = "computertest:turtle:terminal:"
local FORMNAME_TURTLE_UPLOAD    = "computertest:turtle:upload:"

local function getTurtle(id) return computertest.turtles[id] end
minetest.register_on_player_receive_fields(function(player, formname, fields)
    local function isForm(name)
        return string.sub(formname,1,string.len(name))==name
    end
    --minetest.debug("FORM SUBMITTED",dump(formname),dump(fields))
    if isForm(FORMNAME_TURTLE_INVENTORY) then
        local id = tonumber(string.sub(formname,1+string.len(FORMNAME_TURTLE_INVENTORY)))
        local turtle = getTurtle(id)
        if (fields.upload_code=="Upload Code") then
            minetest.show_formspec(player:get_player_name(),FORMNAME_TURTLE_UPLOAD..id,turtle:get_formspec_upload());
        elseif (fields.open_terminal=="Open Terminal") then
            minetest.show_formspec(player:get_player_name(),FORMNAME_TURTLE_TERMINAL..id,turtle:get_formspec_terminal());
        elseif (fields.factory_reset=="Factory Reset") then
            minetest.debug("Stop Code")
            return not turtle:upload_code_to_turtle("",false)
        end
    elseif isForm(FORMNAME_TURTLE_TERMINAL) then
        if (fields.terminal_out ~= nil) then return true end
        local id = tonumber(string.sub(formname,1+string.len(FORMNAME_TURTLE_TERMINAL)))
        local turtle = getTurtle(id)
        turtle.lastCommandRan = fields.terminal_in
        local command = fields.terminal_in
        if command==nil or command=="" then return nil end
        command = "function init(turtle) return "..command.." end"
        local commandResult = turtle:upload_code_to_turtle(command, true)
        if (commandResult==nil) then
            minetest.close_formspec(player:get_player_name(),FORMNAME_TURTLE_TERMINAL..id)
            return true
        end
        commandResult = fields.terminal_in.." -> "..commandResult
        turtle.previous_answers[#turtle.previous_answers+1] = commandResult
        minetest.show_formspec(player:get_player_name(),FORMNAME_TURTLE_TERMINAL..id,turtle:get_formspec_terminal());
    elseif isForm(FORMNAME_TURTLE_UPLOAD) then
        local id = tonumber(string.sub(formname,1+string.len(FORMNAME_TURTLE_UPLOAD)))
        if (fields.button_upload == nil or fields.upload == nil) then return true end
        local turtle = getTurtle(id)
        return not turtle:upload_code_to_turtle(fields.upload,false)
    else
        return false--Unknown formname, input not processed
    end
    return true--Known formname, input processed "If function returns `true`, remaining functions are not called"
end)
minetest.register_entity("computertest:turtle", {
    initial_properties = {
        hp_max = 1,
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
        id = -1,
    },

    --MAIN TURTLE USER INTERFACE------------------------------------------
    get_formspec_inventory = function(turtle)
        return "size[12,5;]"
                .."button[0,0;2,1;open_terminal;Open Terminal]"
                .."button[2,0;2,1;upload_code;Upload Code]"
                .."button[4,0;2,1;factory_reset;Factory Reset]"
                .."set_focus[open_terminal;true]"
                .."list[".. turtle.inv_fullname..";main;8,1;4,4;]"
                .."background[8,1;1,1;computertest_inventory.png]"
                .."list[current_player;main;0,1;8,4;]";
    end,
    get_formspec_terminal = function(turtle)
        local previous_answers = turtle.previous_answers
        local parsed_output = "";
        for i=1, #previous_answers do parsed_output = parsed_output .. minetest.formspec_escape(previous_answers[i]).."," end
        --local saved_output = "";
        --for i=1, #previous_answers do saved_output = saved_output .. minetest.formspec_escape(previous_answers[i]).."\n" end
        return
        "size[12,9;]"
                .."field_close_on_enter[terminal_in;false]"
                .."field[0,0;12,1;terminal_in;;"..minetest.formspec_escape(turtle.lastCommandRan or "").."]"
                .."set_focus[terminal_in;true]"
                .."textlist[0,1;12,8;terminal_out;"..parsed_output.."]";
    end,
    get_formspec_upload = function(turtle)
        --TODO could indicate if code is already uploaded
        return
        "size[12,9;]"
                .."button[0,0;2,1;button_upload;Upload Code to #"..turtle.id.."]"
                .."field_close_on_enter[upload;false]"
                .."textarea[0,1;12,8;upload;;"..minetest.formspec_escape(turtle.codeUncompiled or "").."]"
                .."set_focus[upload;true]";
    end,
    upload_code_to_turtle = function(turtle, code_string,run_for_result)
        local function sandbox(code)
            --TODO sandbox this!
            --Currently returns function that defines init and loop. In the future, this should probably just initialize it using some callbacks
            if (code =="") then return nil end
            return loadstring(code)
        end
        turtle.codeUncompiled = code_string
        turtle.coroutine = nil
        turtle.code = sandbox(turtle.codeUncompiled)
        minetest.debug("Stop Code2",dump(turtle))

        if (run_for_result) then
            --TODO run subroutine once, if it returns a value, return that here
            return "Ran"
        end
        return turtle.code ~= nil
    end,
    --MAIN END TURTLE USER INTERFACE------------------------------------------

    --- From 0 to 3
    set_heading = function(turtle,heading)
        heading = (tonumber(heading) or 0)%4
        if turtle.heading ~= heading then
            turtle.heading = heading
            turtle.object:set_yaw(turtle.heading * 3.14159265358979323/2)
            if (coroutine.running() == turtle.coroutine) then turtle:yield("Turning") end
        end
    end,
    get_heading = function(self)
        return self.heading
    end,
    on_activate = function(self, staticdata, dtime_s)
        --TODO use staticdata to load previous state, such as inventory and whatnot
        --Give ID
        computertest.num_turtles = computertest.num_turtles+1
        self.id = computertest.num_turtles
        self.heading = 0
        self.previous_answers = {}
        self.coroutine = nil
        --Give her an inventory
        self.inv_name = "computertest:turtle:"..self.id
        self.inv_fullname = "detached:"..self.inv_name
        local inv = minetest.create_detached_inventory(self.inv_name,{})
        if inv == nil or inv == false then error("Could not spawn inventory")end
        inv:set_size("main", 4*4)
        if self.inv ~= nil then inv.set_lists(self.inv) end
        self.inv = inv
        -- Add to turtle list
        computertest.turtles[self.id] = self
    end,
    on_rightclick = function(self, clicker)
        if not clicker or not clicker:is_player() then return end
        minetest.show_formspec(clicker:get_player_name(), FORMNAME_TURTLE_INVENTORY.. self.id, self:get_formspec_inventory())
    end,
    get_staticdata = function(self)
    --    TODO convert inventory and internal code to string and back somehow, or else it'll be deleted every time the entity gets unloaded
        minetest.debug("Deleting all data of turtle")
    end,
    turtle_move_withHeading = function (turtle,numForward,numRight,numUp)
        local new_pos = turtle:getNearbyPos(numForward,numRight,numUp)
        --Verify new pos is empty
        if (new_pos == nil or minetest.get_node(new_pos).name~="air") then
            turtle:yield("Moving")
            return false
        end
        --Take Action
        turtle.object:set_pos(new_pos)
        turtle:yield("Moving")
        return true
    end,
    getNearbyPos = function(turtle, numForward, numRight, numUp)
        local pos = turtle.object:get_pos()
        if pos==nil then return nil end -- To prevent unloaded turtles from trying to load things
        local new_pos = vector.new(pos)
        if turtle:get_heading()%4==0 then new_pos.z=pos.z-numForward;new_pos.x=pos.x-numRight; end
        if turtle:get_heading()%4==1 then new_pos.x=pos.x+numForward;new_pos.z=pos.z-numRight; end
        if turtle:get_heading()%4==2 then new_pos.z=pos.z+numForward;new_pos.x=pos.x+numRight; end
        if turtle:get_heading()%4==3 then new_pos.x=pos.x-numForward;new_pos.z=pos.z+numRight; end
        new_pos.y = pos.y + (numUp or 0)
        return new_pos
    end,
    mine = function(turtle, nodeLocation)
        if nodeLocation == nil then
            turtle:yield("Mining")
            return false
        end
        local node = minetest.get_node(nodeLocation)
        if (node.name=="air") then return false end
        local drops = minetest.get_node_drops(node)
        minetest.remove_node(nodeLocation)
        for _, iteminfo in ipairs(drops) do
            local stack = ItemStack(iteminfo)
            --minetest.log("dropping "..stack:get_count().."x "..itemname)
            if turtle.inv:room_for_item("main",stack) then
                turtle.inv:add_item("main",stack)
            else
                minetest.log("Totally deleted not-picked-up item")
            end
        end
        turtle:yield("Mining")
        return true
    end,
--    MAIN TURTLE INTERFACE    ---------------------------------------
    yield = function(turtle,reason) if (coroutine.running() == turtle.coroutine) then coroutine.yield(reason) end end,
    moveForward = function(turtle)  turtle:turtle_move_withHeading( 1, 0, 0) end,
    moveBackward = function(turtle) turtle:turtle_move_withHeading(-1, 0, 0) end,
    moveRight = function(turtle)    turtle:turtle_move_withHeading( 0, 1, 0) end,
    moveLeft = function(turtle)     turtle:turtle_move_withHeading( 0,-1, 0) end,
    moveUp = function(turtle)       turtle:turtle_move_withHeading( 0, 0, 1) end,
    moveDown = function(turtle)     turtle:turtle_move_withHeading( 0, 0,-1) end,
    turnLeft = function(turtle)     turtle:set_heading(turtle:get_heading()+1) end,
    turnRight = function(turtle)    turtle:set_heading(turtle:get_heading()-1) end,
    mineForward = function(turtle)  turtle:mine(turtle:getNearbyPos(1,0,0)) end,
    mineUp = function(turtle)       turtle:mine(turtle:getNearbyPos(0,0,1)) end,
    mineDown = function(turtle)     turtle:mine(turtle:getNearbyPos(0,0,-1)) end,
--    MAIN TURTLE INTERFACE END---------------------------------------
})

local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if (timer >= computertest.config.globalstep_interval) then
        for _,turtle in pairs(computertest.turtles) do
            if turtle.coroutine then
                if coroutine.status(turtle.coroutine)=="suspended" then
                    --minetest.log("turtle #"..id.." has suspended/new coroutine!")
                    local status, result = coroutine.resume(turtle.coroutine)
                    minetest.log("coroutine stat "..dump(status).." said "..dump(result))
                --elseif coroutine.status(turtle.coroutine)=="dead" then
                    --minetest.log("turtle #"..id.." has coroutine, but it's already done running")
                end
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
        timer = timer - computertest.config.globalstep_interval
    end
end)