local P=require('perspective')
for room,c in pairs(P.rooms)do
 local head=P.vertex(room,240,c.foot,0,1.852,0,0)
 assert(math.abs(c.foot-head[2]-c.door*1.8/2.1)<1,room..' adult vs door')
 for _,y in ipairs({c.foot,c.foot+25})do
  local x,z=P.ground(room,270,y)
  local sx,sy=P.screen(room,x,z)
  assert(math.abs(sx-270)<1e-8 and math.abs(sy-y)<1e-8,room..' floor inverse')
 end
 for _,running in ipairs({false,true})do
  for _,fps in ipairs({15,30,60})do
   for _,direction in ipairs({{1,0},{0,-1},{1,-1}})do
    local x,y=240,c.foot+25;local total=0
    for i=1,fps do
     local distance
     x,y,distance=P.move(room,x,y,direction[1],direction[2],1/fps,running,function()return true end)
     total=total+distance
    end
    local speed=running and 4.1070557323 or 1.7009575856
    assert(math.abs(total-speed)<1e-6,room..' physical speed / diagonal / fps')
   end
  end
 end
end
print('Eight cameras: adult/door reference, floor inverse, physical walk/run speed, 15/30/60fps and diagonal normalization OK')
