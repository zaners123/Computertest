--- Mines an entire forest

local x,y,z = 0,0,0
local turtle = nil

function dumpItems()
    local sx,sy,sz = x,y,z -- save
    moveTo(0,0,0)
    turtle:turnLeft()
    turtle:turnLeft()
    for i = 1, 16 do turtle:itemPushForward(i) end
    turtle:turnLeft()
    turtle:turnLeft()
    moveTo(sx,sy,sz)
end

function moveTo(tox,toy,toz)
    while y<toy do turtle:mineUp()       ; turtle:moveUp()       ; y=y+1 end
    while x>tox do turtle:mineBackward() ; turtle:moveBackward() ; x=x-1 end
    while x<tox do turtle:mineForward()  ; turtle:moveForward()  ; x=x+1 end
    while z>toz do turtle:mineLeft()     ; turtle:moveLeft()     ; z=z-1 end
    while z<toz do turtle:mineRight()    ; turtle:moveRight()    ; z=z+1 end
    while y>toy do turtle:mineDown()     ; turtle:moveDown()     ; y=y-1 end
    x=tox; y=toy; z=toz
end

function scan()
    local scanlist = {}
    table.insert(scanlist,{0,0,0})
    local function processScan(point,name)
        local names = {'default:tree', 'default:leaves',
                       'default:jungletree','default:jungleleaves',
                       'default:pine_tree','default:pine_needles',
                       'default:acacia_tree','default:acacia_leaves',
                       'default:aspen_tree','default:aspen_leaves'}
        local function has(array,value)
            for k,v in pairs(array) do
                if value==v then
                    return true
                end
            end
            return false
        end

        if has(names,name) then
            turtle:debug("name: "..turtle:dump(name))
            table.insert(scanlist,point)
        end
    end
    local function mineHere()
        local point = table.remove(scanlist,#scanlist)
        moveTo(point[1],point[2],point[3])

        processScan({point[1]-1,point[2],point[3]},turtle:scanBackward().name)
        processScan({point[1]+1,point[2],point[3]},turtle:scanForward() .name)

        processScan({point[1],point[2]-1,point[3]},turtle:scanDown()    .name)
        processScan({point[1],point[2]+1,point[3]},turtle:scanUp()      .name)

        processScan({point[1],point[2],point[3]-1},turtle:scanLeft()    .name)
        processScan({point[1],point[2],point[3]+1},turtle:scanRight()   .name)

        table.sort(scanlist,(function(a,b) return a[1] < b[1] end))
    end
    while next(scanlist) do
        mineHere()
    end
    moveTo(0,0,0)
end

function init(turtleL)
    turtle = turtleL
    while true do
        scan()
        turtle:yield("Done Scanning")
    end
end