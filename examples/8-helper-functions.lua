---Dumps everything from the turtle forward if it's in the list
--- @param list - Something like {"default:stone","default:dirt"}
--- @param isWhitelist - If true, only dump things in list.
---         If false, dump everything EXCEPT the items in the list
--- @param listname @see itemPush
--- @return boolean true unless any items can't fit
local function itemPushForwardFiltered(turtle, list, isWhitelist, listname)
    local success = true
    local function intable(item)
        for _,x in pairs(list) do
            if item==x then return true end
        end
        return false
    end
    for turtleslot = 1, 16 do
        if intable(turtle:itemGet(turtleslot):get_name()) == isWhitelist then
            success = success and turtle:itemPushForward(turtleslot,listname)
        end
    end
    return success
end
function init(turtle)
    while true do
        itemPushForwardFiltered(turtle,{"default:cobble","default:sand"}, true, "src")
        itemPushForwardFiltered(turtle,{"default:coal_lump"}, true, "fuel")
        turtle:itemSuckForward({"default:stone","default:glass"},true,"dst")
        turtle:yield("Waiting")
    end
end