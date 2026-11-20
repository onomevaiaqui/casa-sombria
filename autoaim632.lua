local A={enabled=true,held=false,pending=nil}
function A.set(value)A.enabled=not not value;A.pending=nil;return A.enabled end
function A.toggle()return A.set(not A.enabled)end
local function alive(e,room)
 return e and e.enabled~=false and e.room==room and (e.hp or 0)>0 and e.state~='waiting'and e.state~='sleep'and e.state~='sequence'and e.state~='dead'and e.state~='dying'and e.state~='escaped'
end
function A.nearest(room,x,y,one,two,clear)
 local best,dist=nil,81
 for _,e in ipairs({one or false,two or false})do
  if alive(e,room)then local d=(e.x-x)^2+(e.y-y)^2
   if d<dist and (not clear or clear(room,x,y,e.x,e.y))then best,dist=e,d end
  end
 end
 return best
end
function A.update(guard,dt,context,current,targetAngle)
 local pressed=guard and not A.held;A.held=guard
 if not A.enabled or not guard then A.pending=nil;return current end
 if targetAngle then A.pending={context=context,angle=targetAngle}
 elseif pressed then A.pending=nil end
 local p=A.pending
 if not p or p.context~=context then return current end
 local delta=math.atan(math.sin(p.angle-current),math.cos(p.angle-current));local step=14*math.max(0,math.min(.1,dt or 0))
 if math.abs(delta)<=step then A.pending=nil;return p.angle%(2*math.pi)end
 return (current+(delta>0 and step or -step))%(2*math.pi)
end
function A.house(guard,dt,room,x,y,current,one,two)
 local target
 if A.enabled and guard then
  local metric=require('metric_rooms');local doors=require('doors131')
  local function clear(r,ax,ay,bx,by)
   return require('pursuit605').lineClear(r,ax,ay,bx,by)
  end
  local e=A.nearest(room,x,y,one,two,clear)
  if e then target=metric.facing(room,e.x-x,e.y-y)end
 end
 return A.update(guard,dt,room,current,target)
end
function A.street(guard,dt,x,y,current,e,walkable)
 local angle
 if A.enabled and guard and e and e.hp>0 and e.state~='sleep'and e.state~='dead'and (e.x-x)^2+(e.y-y)^2<81 then
  local clear=true
  for i=1,10 do local t=i/11;if not walkable(x+(e.x-x)*t,y+(e.y-y)*t)then clear=false;break end end
  if clear then angle=math.atan(e.x-x,-(e.y-y))end
 end
 return A.update(guard,dt,'street',current,angle)
end
return A
