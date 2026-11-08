-- Choose a free destination before committing a room change. Search stays within the doorway.
local P={}
function P.arrival(metric,doors,room,sx,sy,transfer)
 local function free(x,y)
  local px,py=metric.project(room,x,y,0)
  if metric.walkable(room,px,py)and doors.walkable(room,x,y)then return px,py end
 end
 local x,y=metric.ground(room,sx,sy)
 local px,py=free(x,y);if px then return px,py end
 if not transfer then return end
 local lateral=transfer.axis==1 and y or x
 local low,high=transfer.low,transfer.high
 -- A 2.5 cm step fixes contact with the open leaf without jumping across the opening.
 for i=1,math.min(128,math.ceil((high-low)/.025)+1)do
  for _,sign in ipairs({1,-1})do
   local value=lateral+sign*i*.025
   if value>=low-1e-8 and value<=high+1e-8 then
    px,py=free(transfer.axis==1 and x or value,transfer.axis==1 and value or y)
    if px then return px,py end
   end
  end
 end
 -- No clear landing: leave the player in the source room rather than embedding them.
end
return P
