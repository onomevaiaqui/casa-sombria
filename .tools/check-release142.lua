local refs=dofile('.tools/sprites168.lua')
local data=require('camera_data168');local mem=require('memory168');local count=0
for room in pairs(data.firstprefix)do
 local views=data[room]
 assert(package.loaded['camera_mem168_'..room]==nil,'room leaked into require cache')
 for _,c in ipairs(views)do
  assert(type(c.visibilityHex)=='string'and #c.visibilityHex==2*math.ceil(c.visibilityWidth*c.visibilityHeight/8))
  for _,s in pairs(c.states)do
   for i=0,2 do assert(refs[s.prefix..'_'..i],'missing native bitmap '..s.prefix)end
   assert(#mem.depth(s)==s.depthWidth*s.depthHeight,'truncated depth buffer')
   count=count+1
  end
 end
end
print('PASS release: '..count..' states, all native bitmaps and depth buffers, lazy room cache')
