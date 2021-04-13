--- Functions in this file are callable by user-code

function stuff()
    return "Success! I am result of stuff()"
end

---
---@returns true on success
---
function turtle_move_withHeading(pos,numForward,numRight)
    --Get new pos
    local node = minetest.get_node(pos)
    local new_pos = vector.new(pos)
    if node.param2%4==0 then new_pos.z=pos.z-numForward;new_pos.x=pos.x-numRight; end
    if node.param2%4==1 then new_pos.x=pos.x-numForward;new_pos.z=pos.z+numRight; end
    if node.param2%4==2 then new_pos.z=pos.z+numForward;new_pos.x=pos.x+numRight; end
    if node.param2%4==3 then new_pos.x=pos.x+numForward;new_pos.z=pos.z-numRight; end
    --Verify new pos is empty
    if (minetest.get_node(new_pos).name~="air") then return false end
    --Take Action
    minetest.log("Moving from "..dump(pos).." to "..dump(new_pos))
    local metadata = minetest.get_meta(pos)
    minetest.remove_node(pos)
    minetest.add_node(new_pos, node)
    minetest.get_meta(new_pos):from_table(metadata:to_table())
    return true
end