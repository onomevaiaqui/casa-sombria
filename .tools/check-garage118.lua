local M=require('metric_rooms')
local C=require('camera_data117').garagem
assert(C.size[1]==4.6 and C.size[2]==5.7,'wrong garage dimensions')
local function walk(x,y)return M.walkable('garagem',M.project('garagem',x,y,0))end
for y=.6,5.35,.05 do assert(walk(3.1,y),'central aisle blocked at '..y)end
for _,p in ipairs({{3.6,1.7},{3.6,2.4},{3.6,3},{3.6,4.5}})do
 assert(walk(p[1],p[2]),'workbench collectible is unreachable')
end
assert(walk(3.6,1.4),'expanded floor is not usable')
assert(not walk(2.2,3),'car wheel collision missing')
assert(not walk(4.3,3.5),'workbench collision missing')
assert(not walk(4.5,1.4),'right wall collision missing')
assert(not walk(4.7,1.4),'outside room is walkable')
local x,y=M.project('garagem',3.1,2.4,0)
local actor=M.vertex('garagem',x,y,0,1.852,0,0)
local hx,hy=M.project('garagem',3.1,2.4,1.8)
assert(math.abs(actor[1]-hx)<=.51 and math.abs(actor[2]-hy)<=.51,'actor height changed')
print('Garage 4.60 x 5.70 m: continuous aisle, tool access, car/bench/wall collisions and 1.80 m actor OK')
