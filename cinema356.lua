-- Stable fixed cameras: framing controls cuts; actor facing never selects a camera.
local C={stats={cuts=0,recovery=0}}
local function sees(c,x,y)
 local g=c.grid;if not g then return false end
 local gx,gy=math.floor((x-g.x0)/g.step+.5),math.floor((y-g.y0)/g.step+.5)
 if gx<0 or gy<0 or gx>=g.w or gy>=g.h then return false end
 local n=gy*g.w+gx;return ((c.vis:byte(n//8+1)or 0)>>(n%8))&1==1
end
C.sees=sees
local function framing(c,x,y)
 local edge=1e6;local m=c.m
 for z=0,1.8,1.8 do
  local w=m[4][1]*x+m[4][2]*y+m[4][3]*z+m[4][4];if w<=.15 then return -1e9 end
  local sx=((m[1][1]*x+m[1][2]*y+m[1][3]*z+m[1][4])/w+1)*240
  local sy=(1-(m[2][1]*x+m[2][2]*y+m[2][3]*z+m[2][4])/w)*135
  edge=math.min(edge,sx-5,475-sx,sy-14,266-sy)
 end
 return edge
end
C.framing=framing
local function quality(c,x,y)
 if not sees(c,x,y)then return -1e9 end
 local e=framing(c,x,y);if e<0 then return -1e9 end
 local a=c.anchor;local d=a and math.sqrt((x-a[1])^2+(y-a[2])^2)or 0
 return math.min(e,60)-d*.35-(c.support356 and 6 or 0)
end
C.quality=quality
function C.select(views,x,y,previous,room,allowed)
 local old=previous and views[previous]
 local current=old and not old.rejected368 and(not allowed or allowed[previous])and(not room or old.room==room)and quality(old,x,y)or -1e9
 local oldFrame=current> -1e8 and framing(old,x,y)or -1e9
 -- Keep the shot inside its usable sector. No score-only camera competition.
 if old and old.active367~=false and oldFrame>=10 then return previous end
 local best,score=nil,-1e9
 for i,c in ipairs(views)do
  if not c.rejected368 and(not allowed or allowed[i])and c.active367~=false and(not room or c.room==room)then
   local q=quality(c,x,y);if q>score then best,score=i,q end
  end
 end
 -- Small edge margin prevents a cut to a view with equally poor framing.
 if old and old.active367~=false and oldFrame>=2 and(best==nil or framing(views[best],x,y)<oldFrame+5)then return previous end
 -- A removed view can recover an unsampled edge, rather than selecting an unrelated room.
 if not best then
  for i,c in ipairs(views)do if not c.rejected368 and(not allowed or allowed[i])and(not room or c.room==room)then local q=quality(c,x,y);if q>score then best,score=i,q end end end
  if best then C.stats.recovery=C.stats.recovery+1 end
 end
 if not best and allowed then return C.select(views,x,y,previous,room,nil)end
 if not best then
  -- Retain a framed previous shot across a single coarse visibility cell boundary.
  if old and not old.rejected368 and(not allowed or allowed[previous])and(not room or old.room==room)and framing(old,x,y)>=4 then return previous end
  local fallback,dist=nil,1e9
  for i,c in ipairs(views)do if not c.rejected368 and(not allowed or allowed[i])and(not room or c.room==room)and framing(c,x,y)>=4 then local a=c.anchor;local d=a and(x-a[1])^2+(y-a[2])^2 or 0;if d<dist then fallback,dist=i,d end end end
  best=fallback
 end
 if not best then for i,c in ipairs(views)do if not c.rejected368 and(not allowed or allowed[i])and(not room or c.room==room)then best=i;break end end end
 best=best or previous or 1
 if previous and best~=previous then C.stats.cuts=C.stats.cuts+1 end
 return best
end
function C.pressure()if collectgarbage('count')>2800 then collectgarbage('collect')else collectgarbage('step',96)end end
function C.unpack(raw)
 C.pressure()
 local chunks,parts={},{}
 for j=1,#raw,2 do local n,v=raw:byte(j,j+1);chunks[#chunks+1]=string.rep(string.char(v),n);if #chunks==128 then parts[#parts+1]=table.concat(chunks);for k=128,1,-1 do chunks[k]=nil end end end
 if #chunks>0 then parts[#parts+1]=table.concat(chunks)end;return table.concat(parts)
end
return C
