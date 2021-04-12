local function tostringVector(vec) return "("..vec.x..","..vec.y..","..vec.z..")" end
---
---@returns true on success
---
local function turtle_move_withHeading(pos,node,numForward,numRight)
    --Get new pos
    local new_pos = vector.new(pos)
    if node.param2%4==0 then pos.z=pos.z-numForward;pos.x=pos.x-numRight; end
    if node.param2%4==1 then pos.x=pos.x-numForward;pos.z=pos.z+numRight; end
    if node.param2%4==2 then pos.z=pos.z+numForward;pos.x=pos.x+numRight; end
    if node.param2%4==3 then pos.x=pos.x+numForward;pos.z=pos.z-numRight; end
    --Verify new pos is empty
    if (minetest.get_node(pos).name~="air") then return false end
    --Take Action
    pos,new_pos = new_pos,pos
    minetest.log("Moving from "..dump(pos).." to "..dump(new_pos))
    minetest.remove_node(pos)
    minetest.add_node(new_pos, node)
    return true
end

local function get_formspec(sweet_output)
    sweet_output = sweet_output or {}
    local parsed_output = "";
    for i=1, #sweet_output do
        parsed_output = parsed_output .. minetest.formspec_escape(sweet_output[i])..","
    end
    return
        "invsize[12,9;]"
        --.."field_close_on_enter[terminal_in;false]"
        .."field[0,0;11,1;terminal_in;;]"
        .."button[11,0;1,1;submit;Submit]"
        .."textlist[0,1;12,4;terminal_out;"..parsed_output.."]"
        .."list[context;main;8,5;4,4;]"
        .."background[8,5;4,4;computertest_inventory.png]"
        .."list[current_player;main;0,5;8,4;]";
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
        meta:from_table({
            out = "output something",
            inventory = {main = {
                [1] = "default:dirt",[2] = "",[3] = "",[4] = "",[5] = "",[6] = "",[7] = "",[8] = "",
                [9] = "",[10] = "",[11] = "",[12] = "",[13] = "",[14] = "default:cobble",[15] = "",[16] = "",
            }},
            fields = {
                formspec = get_formspec(),
                infotext = "Turtle"
            }
        })
    end,
    on_receive_fields = function(pos, formname, fields, sender)
        --minetest.log(dump(pos).."\n\n"..dump(formname).."\n\n"..dump(fields).."\n\n"..dump(sender))
        minetest.debug("TERMINAL OUT ",dump(fields));
        formname = ""..math.random()
        fields.terminal_out = fields.terminal_out or {}
        fields.terminal_in = fields.terminal_in or ""
        fields.terminal_out[#fields.terminal_out+1] = "Output from command \""..fields.terminal_in.."\""
        minetest.debug("show_formspec",sender:get_player_name(),formname,get_formspec(fields.terminal_out));
        minetest.show_formspec(sender:get_player_name(),formname,get_formspec(fields.terminal_out));
    end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)

end)

minetest.register_craft({
    output = 'computertest:turtle',
    recipe = {
        {'default:dirt', '', ''},
        {            '', '', ''},
        {            '', '', ''},
    }
})