--TODO have player context instead of passing block position to user
context = {}

local function tostringVector(vec) return "("..vec.x..","..vec.y..","..vec.z..")" end
local function parseStringVector(str)
    --    Remove Parenthesis
    minetest.log("PARSGING "..str)
    str = string.sub(str,2,string.len(str)-1)
    minetest.log("PARSGING "..str)
    local ret = {}
    for word in string.gmatch(str, '([^,]+)') do
        ret[#ret+1] = word
    end
    ret = vector.new(ret[1],ret[2],ret[3]);
    minetest.log("PARSGING "..dump(ret))
    return ret;
end
local function runTurtleCommand(pos, command)
    --Verify turtle exists
    --return "Output from command \""..dump(command).."\"".." at location \""..dump(pos).."\""
    if command=="forward" then
        if turtle_move_withHeading(pos,1,0) then
            return "Went forward"
        else
            return "Stopped by Obstacle"
        end
    elseif false then

    end
    return "Unknown command"
end

local function get_formspec_terminal(fields)
    local sweet_output = fields.terminal_out or {}
    local parsed_output = "";
    for i=1, #sweet_output do parsed_output = parsed_output .. minetest.formspec_escape(sweet_output[i]).."," end
    local saved_output = "";
    for i=1, #sweet_output do saved_output = saved_output .. minetest.formspec_escape(sweet_output[i]).."\n" end
    return
    "invsize[12,9;]"
            .."field[0,0;0,0;pos;;"..minetest.formspec_escape(fields.pos).."]"
            .."field[0,0;0,0;terminal_out_last;;"..saved_output.."]"
            .."field_close_on_enter[terminal_in;false]"
            .."field[0,0;12,1;terminal_in;;]"
            .."set_focus[terminal_in;true]"
            .."textlist[0,1;12,8;terminal_out;"..parsed_output.."]";
end
local function get_formspec_inventory()
    return "invsize[12,5;]"
            .."button[0,0;2,1;open_terminal;Open Terminal]"
            .."set_focus[open_terminal;true]"
            .."list[context;main;8,1;4,4;]"
            .."background[8,1;4,4;computertest_inventory.png]"
            .."list[current_player;main;0,1;8,4;]";
end

minetest.register_node("computertest:turtle", {
    tiles = {
        "computertest_top.png",
        "computertest_bottom.png",
        "computertest_right.png",
        "computertest_left.png",
        "computertest_back.png",
        "computertest_front.png",
    },
    groups = {oddly_breakable_by_hand=2},
    paramtype = "light",
    paramtype2 = "facedir",
    light_source=14,
    --on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    --    turtle_move_withHeading(pos,node,0,1)
    --end,
    on_construct = function(pos)

        local meta = minetest.get_meta(pos)
        minetest.log("OLD META"..dump(meta:to_table()))
        meta:from_table({
            out = "output something",
            inventory = {main = {
                [1] = "default:dirt",[2] = "",[3] = "",[4] = "",[5] = "",[6] = "",[7] = "",[8] = "",
                [9] = "",[10] = "",[11] = "",[12] = "",[13] = "",[14] = "default:cobble",[15] = "",[16] = "",
            }},
            fields = {
                formspec = get_formspec_inventory(),
                infotext = "Turtle"..#context
            }
        })
        meta:set_int("TURTLE_ID",#context)
        minetest.log("OLD META"..dump(meta:to_table()))
        context[#context+1] = {}
    end,
    on_receive_fields = function(pos, formname, fields, player)
        minetest.show_formspec(player:get_player_name(),"terminal",
                get_formspec_terminal({
                    pos = tostringVector(pos)
                })
        );
    end
})
minetest.register_on_player_receive_fields(function(player, formname, fields)
    minetest.debug("TERMINAL OUT ",dump(fields));

    if (not fields.terminal_in or fields.terminal_in=="") then return end

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
    minetest.show_formspec(player:get_player_name(),formname,get_formspec_terminal(fields));
end)
minetest.register_craft({
    output = 'computertest:turtle',
    recipe = {
        {'default:dirt', '', ''},
        {            '', '', ''},
        {            '', '', ''},
    }
})