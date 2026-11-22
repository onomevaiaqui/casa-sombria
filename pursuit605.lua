-- Interior pursuit with reusable room grids and physical door portals.
local M=require('metric_rooms');local D=require('doors131');local N={}
local inside={sala=true,cozinha=true,corredor=true,quarto=true,banheiro=true,garagem=true}
N.inside=inside
function N.clear(room,x,y)
 local sz=M.sizes[room];if not sz then return false end;local r=.24
 if x<r or y<r or x>sz[1]-r or y>sz[2]-r then return false end
 for _,b in ipairs(M.boxes[room]or{})do local nx,ny=math.max(b[1],math.min(b[2],x)),math.max(b[3],math.min(b[4],y));if(x-nx)^2+(y-ny)^2<r*r then return false end end
 return D.walkable(room,x,y)
end
local function segment(room,x,y,tx,ty)
 local steps=math.ceil(math.sqrt((tx-x)^2+(ty-y)^2)/.10)
 for i=1,steps do if not N.clear(room,x+(tx-x)*i/steps,y+(ty-y)*i/steps)then return false end end
 return true
end
-- One navigation working set: replace it on room/door changes.
local step=.18
local grid,queue,distance={},{},{}
local cachedRoom,cachedMask,cachedGoal,cachedW,cachedH
N.lineClear=segment
N.searches=0
function N.release()
 grid,queue,distance={},{},{};cachedRoom=nil;cachedGoal=nil
end
function N.waypoint(room,x,y,tx,ty)
 if segment(room,x,y,tx,ty)then return tx,ty,false end
 local sz=M.sizes[room];local w,h=math.floor((sz[1]-.48)/step)+1,math.floor((sz[2]-.48)/step)+1
 local function xy(id)local n=id-1;return .24+(n%w)*step,.24+math.floor(n/w)*step end
 local mask=D.stateMask({1,2,4,8,16,32,256})
 if cachedRoom~=room or cachedMask~=mask then
  cachedRoom,cachedMask,cachedGoal,cachedW,cachedH=room,mask,nil,w,h
  for i=1,w*h do local a,b=xy(i);grid[i]=N.clear(room,a,b)end
 end
 local function nearest(a,b)
  local c,r=math.floor((a-.24)/step+.5),math.floor((b-.24)/step+.5)
  local id=r*w+c+1
  if c>=0 and c<w and r>=0 and r<h and grid[id]then return id end
  local best,dist=nil,1e9
  for i=1,w*h do if grid[i]then local xx,yy=xy(i);local d=(xx-a)^2+(yy-b)^2;if d<dist then best,dist=i,d end end end
  return best
 end
 local start,goal=nearest(x,y),nearest(tx,ty);if not start or not goal then return x,y,true end
 -- Reverse BFS is shared by every update until the destination cell changes.
 if cachedGoal~=goal then
  cachedGoal=goal;N.searches=N.searches+1
  for i=1,w*h do distance[i]=false end
  queue[1]=goal;distance[goal]=0;local head,tail=1,1
  while head<=tail do
   local id=queue[head];head=head+1;local col=(id-1)%w;local row=math.floor((id-1)/w);local d=distance[id]+1
   local n=id+1;if col+1<w and grid[n]and distance[n]==false then distance[n]=d;tail=tail+1;queue[tail]=n end
   n=id-1;if col>0 and grid[n]and distance[n]==false then distance[n]=d;tail=tail+1;queue[tail]=n end
   n=id+w;if row+1<h and grid[n]and distance[n]==false then distance[n]=d;tail=tail+1;queue[tail]=n end
   n=id-w;if row>0 and grid[n]and distance[n]==false then distance[n]=d;tail=tail+1;queue[tail]=n end
  end
 end
 if distance[start]==false then return x,y,true end
 local id=start;local bestX,bestY=xy(start)
 -- Follow the descending field, smoothing only along collision-free segments.
 for i=1,w*h do
  if id==goal then break end
  local col=(id-1)%w;local row=math.floor((id-1)/w);local d=distance[id];local nextId
  if col+1<w and distance[id+1]and distance[id+1]<d then nextId=id+1
  elseif col>0 and distance[id-1]and distance[id-1]<d then nextId=id-1
  elseif row+1<h and distance[id+w]and distance[id+w]<d then nextId=id+w
  elseif row>0 and distance[id-w]and distance[id-w]<d then nextId=id-w end
  if not nextId then break end
  local a,b=xy(nextId);if not segment(room,x,y,a,b)then break end
  bestX,bestY=a,b;id=nextId
 end
 return bestX,bestY,true
end
local function nextRoom(from,to)
 local q,prev={from},{[from]=false};local head=1
 while head<=#q do local r=q[head];head=head+1
  for _,e in ipairs(M.plan.exits[r]or{})do if inside[e.to]and prev[e.to]==nil and e.to~=from then prev[e.to]=r;q[#q+1]=e.to end end
 end
 if prev[to]==nil then return end;local n=to;while prev[n]and prev[n]~=from do n=prev[n]end;return n
end
local function approach(room,other,e)
 local door=D.forPassage(room,other);local p=door and door.ends[room]
 if p then local x,y=p.x,p.y;local size=M.sizes[room];return math.max(.32,math.min(size[1]-.32,x)),math.max(.32,math.min(size[2]-.32,y)),door end
 local sz=M.sizes[room];return math.max(.32,math.min(sz[1]-.32,(e.world[1]+e.world[2])/2)),math.max(.32,math.min(sz[2]-.32,(e.world[3]+e.world[4])/2))
end
function N.advancePortal(W,dt,duration)
 local p=W.portal;if not p then return end
 p.progress=math.min(1,p.progress+W.tuning.speed*dt/p.length)
 local wx,wy=p.x+(p.tx-p.x)*p.progress,p.y+(p.ty-p.y)*p.progress
 local coordinate=p.axis==1 and wx or wy
 local crossed=(coordinate-p.boundary)*p.sign>=0
 W.room=crossed and p.to or p.from
 local off=M.plan.rooms[W.room].offset;W.x,W.y=wx-off[1],wy-off[2]
 W.moving=true;W.runTime=(W.runTime+W.tuning.speed*dt/1.55)%duration;W.blend=1
 if p.progress>=1 then W.portal=nil;W.cooldown=.20 end
end
function N.follow(W,target,dt,duration)
 local next=nextRoom(W.room,target);if not next then W.moving=false;return end
 local exit;for _,e in ipairs(M.plan.exits[W.room]or{})do if e.to==next then exit=e;break end end;if not exit then return end
 local tx,ty,door=approach(W.room,next,exit)
 if (W.x-tx)^2+(W.y-ty)^2<.16^2 then
  if door and not D.isOpen(door.id)then D.open(door.id)end
  local reverse;for _,e in ipairs(M.plan.exits[next]or{})do if e.to==W.room then reverse=e;break end end
  if reverse then
   local nx,ny=approach(next,W.room,reverse);local a,b=M.plan.rooms[W.room].offset,M.plan.rooms[next].offset
   local axis=exit.world[6];local sign=exit.world[5];local boundary=a[axis]+(sign>0 and M.sizes[W.room][axis]or 0)
   local wx,wy=W.x+a[1],W.y+a[2];local ex,ey=nx+b[1],ny+b[2]
   W.portal={from=W.room,to=next,x=wx,y=wy,tx=ex,ty=ey,length=math.max(.01,math.sqrt((ex-wx)^2+(ey-wy)^2)),progress=0,axis=axis,sign=sign,boundary=boundary}
   W.attackTime=nil;N.advancePortal(W,dt,duration)
  end
  return
 end
 local mx,my=N.waypoint(W.room,W.x,W.y,tx,ty);local dx,dy=mx-W.x,my-W.y;local dist=math.sqrt(dx*dx+dy*dy)
 if dist<.001 then W.moving=false;return end
 local desired=math.atan(dx,-dy);local delta=math.atan(math.sin(desired-W.angle),math.cos(desired-W.angle));W.angle=W.angle+math.max(-2.8*dt,math.min(2.8*dt,delta));W.moving=true
 if math.abs(delta)>.5 then W.runTime=(W.runTime+dt*.4)%duration;return end
 local step=math.min(dist,W.tuning.speed*dt);local nx,ny=W.x+dx/dist*step,W.y+dy/dist*step
 if N.clear(W.room,nx,ny)then W.x,W.y=nx,ny;W.runTime=(W.runTime+step/1.55)%duration end
end
return N
