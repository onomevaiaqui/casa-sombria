local T=require('frame_time')
local P=require('perspective')
for _,fps in ipairs({2,3,5,8,9,10,15,30,60})do
 local dt=T.sample({stat=function(option)assert(option==7);return fps end})
 assert(math.abs(dt-1/fps)<1e-9)
 for _,running in ipairs({false,true})do
  local x,y,total=240,211,0
  for _=1,fps do
   local d;x,y,d=P.move('sala',x,y,1,0,dt,running,function()return true end)
   total=total+d
  end
  assert(math.abs(total-(running and 4.1070557323 or 1.7009575856))<1e-7,'low-FPS slowdown')
 end
end
T.sample({stat=function()return 5 end})
assert(T.sample({stat=function()return 0/0 end})==.2,'invalid reading should keep last valid FPS')
assert(T.sample({})==.2)
assert(T.sample({stat=function()error('unavailable')end})==.2)
for room,c in pairs(P.rooms)do
 for _,facing in ipairs({0,.4,2.5})do
  local project=P.projector(room,240,c.foot+25,facing)
  for _,v in ipairs({{0,0,0},{.3,1.8,-.1},{-.4,.7,.2}})do
   local a=project(table.unpack(v))
   local b=P.vertex(room,240,c.foot+25,v[1],v[2],v[3],facing)
   for i=1,3 do assert(math.abs(a[i]-b[i])<1e-8,'cached camera changed geometry')end
  end
 end
end
print('2..60 FPS real-time travel, invalid-stat recovery and cached projection equivalence OK')
