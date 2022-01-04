--Have logs in slot 1, and all other slots clear
function craftPick(turtle)
    turtle:itemSplitTurtleslot(1,2)
    turtle:itemCraft(5)--craft 4 planks -> 5
    turtle:itemSplitTurtleslot(5,2,2)
    turtle:itemCraft(9)--craft 4 sticks -> 9
    turtle:itemSplitTurtleslot(5,2)
    turtle:itemSplitTurtleslot(5,3)
    turtle:itemSplitTurtleslot(5,4)
    turtle:itemSplitTurtleslot(9,7)
    turtle:itemSplitTurtleslot(9,11)
    turtle:itemCraft(13)
    turtle:itemCraft(14)
end
function init(turtle)
    while true do
        turtle:moveForward()
        craftPick(turtle)
        --turtle:itemPushForward()
        turtle:yield("Waiting 1")
        --turtle:itemSuckForward()
        turtle:moveBackward()
        turtle:itemSuckLeft ({"default:cobble","default:dirt"},true)
        turtle:itemPushRight({"default:coal_lump","wood","tree"},true,'fuel')
        turtle:yield("Waiting")
    end
end