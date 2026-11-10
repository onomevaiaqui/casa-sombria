local golden=dofile('.tools/camera199-golden.lua')
local C=require('cameras168');local data=require('camera_data168');local memory=require('memory168')
local function hash(s)local h=2166136261;for i=1,#s do h=((h~s:byte(i))*16777619)&0xffffffff end;return h end
local cells,states=0,0
for room,views in pairs(golden)do
 local actual=data[room]
 for shot,g in pairs(views)do
  local c=actual[shot];local h=2166136261
  for i=1,g.cells do h=((h~(C.isVisible(c,i)and 49 or 48))*16777619)&0xffffffff end
  assert(h==g.visibility,'visibility changed: '..room..' '..shot);cells=cells+g.cells
  for mask,expected in pairs(g.states)do assert(hash(memory.depth(c.states[mask]))==expected,'depth changed: '..room..' '..shot..' '..mask);states=states+1 end
 end
end
print('PASS exact original visibility/depth digests: '..cells..' cells, '..states..' depth states')
