-- Keep the bedroom camera until the courier crosses the physical threshold.
local P={}
function P.install(metric,doors,exits)
 local original=metric.walkable
 function metric.walkable(room,sx,sy)
  if doors.isOpen('quarto') and (room=='corredor' or room=='quarto') then
   local x,y=metric.ground(room,sx,sy)
   if room=='corredor' and x>=3.95 and x<=4.25 and y>=1.15 and y<=2.04 then return doors.walkable(room,x,y) end
   if room=='quarto' and x>=1.55 and x<=1.85 and y>=-.20 and y<=.65 then return doors.walkable(room,x,y) end
  end
  return original(room,sx,sy)
 end
 for _,e in pairs(exits.corredor)do
  if e.to=='quarto' then e.world[3],e.world[4]=1.82,2.04;e.transfer.normal=.08 end
 end
 for _,e in pairs(exits.quarto)do
  if e.to=='corredor' then e.world[3],e.world[4]=-.20,-.02;e.transfer.normal=1.70 end
 end
end
return P
