local C=require('camera117');local M=require('metric_rooms');local sprites={}
for room in pairs(C.data)do for i=0,2 do sprites['camera117_'..room..'_'..i]=true end end
local master={0};for _,pair in ipairs(M.bank)do master[#master+1]=pair[1]end
C.setup(sprites,master)
for room,d in pairs(C.data)do
 local total,b,example=0,0
 for x=.4,d.size[1]-.4,.15 do for y=.4,d.size[2]-.4,.15 do
  local sx,sy=M.project(room,x,y,0)
  if M.walkable(room,sx,sy)then total=total+1;C.active=false
   if C.select(room,x,y)then b=b+1;example={x,y}end
  end
 end end
 assert(b>0,room..' no close camera zone')
 local x,y=table.unpack(example);C.active=false;C.direction(room,0,0,0,0)
 local ux,uy=C.captureDirection(room,x,y,0,-1,.1,1)
 assert(C.select(room,x,y));local tx,ty=C.captureDirection(room,x,y,0,-1,.5,.7)
 assert(math.abs(ux-tx)<1e-12 and math.abs(uy-ty)<1e-12,'Held input reversed')
 local hits=0;C.palette(room,function(i)assert(i>0 and i<224);hits=hits+1 end);assert(hits==191)
 print(room..': '..b..' valid close-camera positions; held direction and palette safe; example '..x..','..y)
end

