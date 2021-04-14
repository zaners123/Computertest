local turtles = {}
local num_turtles = 0

local FORMNAME_TURTLE_INVENTORY = "computertest:turtle:inventory:"
local FORMNAME_TURTLE_TERMINAL = "computertest:turtle:terminal:"

local function tostringVector(vec) return "("..vec.x..","..vec.y..","..vec.z..")" end
local function parseStringVector(str)
    --    Remove Parenthesis
    str = string.sub(str,2,string.len(str)-1)
    local ret = {}
    for word in string.gmatch(str, '([^,]+)') do ret[#ret+1] = word end
    ret = vector.new(ret[1],ret[2],ret[3]);
    return ret;
end
local function getTurtle(id) return turtles[id] end
local function runTurtleCommand(turtle, command)
    if command==nil then return "No command passed" end
    --Verify turtle exists
    --TODO learn how to do this using loadstring, then eventually replace this with some kinda lua sandbox like https://github.com/APItools/sandbox.lua
    command = "function init(turtle) "..command.." end"
    minetest.log("COMMAND IS \""..command.."\"")
    local loadUserCommand = loadstring(command)

    loadUserCommand()
    init(turtle)
    turtle:turnLeft()


    --return "Output from command \""..dump(command).."\"".." at location \""..dump(pos).."\""
    --if command=="forward" then if moveForward(turtle) then return "Went forward" else return "Stopped by Obstacle" end
    --elseif command=="left" then
    --    turnLeft(turtle)
    --    return "Turned Left"
    --end
    --return "Unknown command"
    return "Done"
end

local function get_formspec_terminal(id, previous_answers)
    local parsed_output = "";
    for i=1, #previous_answers do parsed_output = parsed_output .. minetest.formspec_escape(previous_answers[i]).."," end
    local saved_output = "";
    for i=1, #previous_answers do saved_output = saved_output .. minetest.formspec_escape(previous_answers[i]).."\n" end
    return
    "invsize[12,9;]"
            .."field_close_on_enter[terminal_in;false]"
            .."field[0,0;12,1;terminal_in;;]"
            .."set_focus[terminal_in;true]"
            .."textlist[0,1;12,8;terminal_out;"..parsed_output.."]";
end

local function get_formspec_inventory(self)
    return "invsize[12,5;]"
            .."button[0,0;2,1;open_terminal;Open Terminal]"
            .."set_focus[open_terminal;true]"
            .."list["..self.inv_fullname..";main;8,1;4,4;]"
            .."background[8,1;4,4;computertest_inventory.png]"
            .."list[current_player;main;0,1;8,4;]";
end
minetest.register_on_player_receive_fields(function(player, formname, fields)
    --minetest.debug("FORMNAME ",dump(formname));
    minetest.debug("FIELDS ",dump(fields));

    --main Verify form starts with "computertest:turtle:terminal:id" to run command on id

    --Verify form starts with "FORMNAME_TURTLE_INVENTORY:id" to open terminal on id
    if (string.sub(formname,1,string.len(FORMNAME_TURTLE_INVENTORY))==FORMNAME_TURTLE_INVENTORY) then
        local id = tonumber(string.sub(formname,1+string.len(FORMNAME_TURTLE_INVENTORY)))
        --minetest.debug("FORMNAME IS FOR TURTLE INVENTORY\""..id.."\"");
        --Todo add "Upload Code" button/text/url/something
        if (fields.open_terminal=="Open Terminal") then
            --open terminal
            minetest.show_formspec(player:get_player_name(),FORMNAME_TURTLE_TERMINAL..id,get_formspec_terminal(id, {}));
        end
    --Verify form starts with "FORMNAME_TURTLE_TERMINAL:id" to open terminal on id
    elseif (string.sub(formname,1,string.len(FORMNAME_TURTLE_TERMINAL))==FORMNAME_TURTLE_TERMINAL) then
        local id = tonumber(string.sub(formname,1+string.len(FORMNAME_TURTLE_TERMINAL)))
        --minetest.debug("FORMNAME IS FOR TURTLE TERMINAL"..id);
        local turtle = getTurtle(id)
        runTurtleCommand(turtle, fields.terminal_in)

        --TODO command log
        --[[    if (not fields.terminal_in or fields.terminal_in=="") then return end
        --parse last commands to remember history
        local parsedChatlog = {}
        for word in string.gmatch(fields.terminal_out_last, '([^\n]+)') do
            parsedChatlog[#parsedChatlog+1]=word
        end
        fields.terminal_out_last = parsedChatlog
        --Run command, give output
        fields.terminal_out = fields.terminal_out_last or {}
        fields.terminal_out[#fields.terminal_out+1] = runTurtleCommand(parseStringVector(fields.pos),fields.terminal_in)
        minetest.debug("FIELDS:", dump(fields));
        minetest.debug("show_formspec", player:get_player_name(),formname,get_formspec_terminal(fields));
        minetest.show_formspec(player:get_player_name(),formname,get_formspec_terminal(fields));]]
    end
end)

minetest.register_entity("computertest:turtle", {
    initial_properties = {
        hp_max = 1,
        weight = 5,
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
        automatic_rotate = false,
        channel = "computertest:turtle:" .. 0,
        menu = false,
        id = 0,
        status = 0,
        removed = false,
        ticket = nil,
    },
    --- From 0 to 3
    set_heading = function(turtle,heading)
        turtle.heading = (tonumber(heading) or 0)%4
        turtle.object:set_yaw(turtle.heading * 3.14159265358979323/2)
    end,
    get_heading = function(turtle)
        return turtle.heading
    end,
    ---
    ---@returns true on success
    ---
    turtle_move_withHeading = function (turtle,numForward,numRight,numUp)
        --minetest.log("YAW"..dump(turtle.object:get_yaw()))
        --minetest.log("NUMFORWARD"..dump(numForward))
        --minetest.log("NUMRIGHT"..dump(numRight))
        local pos = turtle.object:get_pos()
        local new_pos = vector.new(pos)
        if turtle:get_heading()%4==0 then new_pos.z=pos.z-numForward;new_pos.x=pos.x-numRight; end
        if turtle:get_heading()%4==1 then new_pos.x=pos.x+numForward;new_pos.z=pos.z-numRight; end
        if turtle:get_heading()%4==2 then new_pos.z=pos.z+numForward;new_pos.x=pos.x+numRight; end
        if turtle:get_heading()%4==3 then new_pos.x=pos.x-numForward;new_pos.z=pos.z+numRight; end
        new_pos.y = pos.y + (numUp or 0)
        --Verify new pos is empty
        if (minetest.get_node(new_pos).name~="air") then return false end
        --Take Action
        turtle.object:set_pos(new_pos)
        return true
    end,
    on_activate = function(self, staticdata, dtime_s)
        --Give ID
        num_turtles = num_turtles+1
        self.id = num_turtles
        self.heading = 0
        turtles[self.id] = self
        --Give her an inventory
        self.inv_name = "computertest:turtle:"..self.id
        self.inv_fullname = "detached:"..self.inv_name
        local inv = minetest.create_detached_inventory(self.inv_name,{})
        if inv == nil or inv == false then error("Could not spawn inventory for drone.")end
        inv:set_size("main", 4*4)
        if self.inv ~= nil then inv.set_lists(self.inv) end
        self.inv = inv
    end,
    on_rightclick = function(self, clicker)
        if not clicker or not clicker:is_player() then return end
        minetest.show_formspec(clicker:get_player_name(), FORMNAME_TURTLE_INVENTORY..self.id, get_formspec_inventory(self))
    end,
--    MAIN TURTLE INTERFACE
--    TODO move this to a literal OO interface wrapper thingy
    moveForward = function(turtle) turtle:turtle_move_withHeading( 1, 0, 0) end,
    moveBackward = function(turtle) turtle:turtle_move_withHeading(-1, 0, 0) end,
    moveRight = function(turtle) turtle:turtle_move_withHeading( 0, 1, 0) end,
    moveLeft = function(turtle) turtle:turtle_move_withHeading( 0,-1, 0) end,
    moveUp = function(turtle) turtle:turtle_move_withHeading( 0, 0, 1) end,
    moveDown = function(turtle) turtle:turtle_move_withHeading( 0, 0,-1) end,
    turnLeft = function(turtle) turtle:set_heading(turtle:get_heading()+1) end,
    turnRight = function(turtle) turtle:set_heading(turtle:get_heading()-1) end,
})