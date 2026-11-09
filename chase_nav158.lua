-- Offline clearance graph, one reusable BFS field; never searches house interiors.
local M=require('metric_rooms')
local native=require('native150')
local N={radius=.48}
local boxes=M.boxes.frente
local floors=M.plan.rooms.frente.floor
local offsets={{1,0},{.70710678,.70710678},{0,1},{-.70710678,.70710678},{-1,0},{-.70710678,-.70710678},{0,-1},{.70710678,-.70710678}}
function N.inArea(room,x,y)return room=='frente'and x>=0 and x<=18.2 and y>=0 and y<=8.6 end
local function floorAt(x,y)
 for i=1,#floors do local b=floors[i];if x>=b[1]and x<=b[2]and y>=b[3]and y<=b[4]then return true end end
 return false
end
function N.canStand(x,y)
 local r=N.radius
 if x<r or x>18.2-r or y<r or y>8.6-r then return false end
 for i=1,#offsets do local p=offsets[i];if not floorAt(x+p[1]*r,y+p[2]*r)then return false end end
 for i=1,#boxes do
  local b=boxes[i]
  if x>b[1]-r and x<b[2]+r and y>b[3]-r and y<b[4]+r then
  if native.enabled then
   if native.blocked(x,y,r,b)then return false end
  else
   local nx,ny=math.max(b[1],math.min(b[2],x)),math.max(b[3],math.min(b[4],y))
   if(x-nx)^2+(y-ny)^2<r*r then return false end
  end
  end
 end
 return true
end
local G=require('chase_graph158')
local distance,queue={},{}
for i=1,#G.links do distance[i]=-1;queue[i]=0 end
local goal,remaining,tail=nil,0,0
local waypointNode
local cachedCol,cachedRow,cachedTarget
local dx={1,1,0,-1,-1,-1,0,1};local dy={0,1,1,1,0,-1,-1,-1}
local function graph()if not G then G=require('chase_graph158')end;return G end
local function point(id)
 local g=graph();local n=id-1
 return g.x+(n%g.width)*g.step,g.y+math.floor(n/g.width)*g.step
end
local function nearest(x,y)
 local g=graph();local best,bestDistance=nil,math.huge
 local cx,cy=math.floor((x-g.x)/g.step+.5),math.floor((y-g.y)/g.step+.5)
 for row=math.max(0,cy-2),math.min(g.height-1,cy+2)do for col=math.max(0,cx-2),math.min(g.width-1,cx+2)do
  local i=row*g.width+col+1
  if g.links:byte(i)~=0 then local a,b=point(i);local d=(a-x)^2+(b-y)^2;if d<bestDistance then best,bestDistance=i,d end end
 end end
 if not best then for i=1,#g.links do if g.links:byte(i)~=0 then local a,b=point(i);local d=(a-x)^2+(b-y)^2;if d<bestDistance then best,bestDistance=i,d end end end end
 return best
end
local function rebuild(id)
 local g=graph()
 for i=1,#g.links do distance[i]=-1 end
 local head=1;tail=1;queue[1]=id;distance[id]=0
 while head<=tail do
  local node=queue[head];head=head+1;local mask=g.links:byte(node)
  for i=1,8 do if mask&(1<<(i-1))~=0 then
   local nextId=node+dx[i]+dy[i]*g.width
   if distance[nextId]<0 then distance[nextId]=distance[node]+1;tail=tail+1;queue[tail]=nextId end
  end end
 end
 goal=id;remaining=.6;N.rebuilds=(N.rebuilds or 0)+1
end
function N.waypoint(x,y,tx,ty,dt)
 local g=graph();remaining=math.max(0,remaining-dt)
 local col=math.floor((tx-g.x)/g.step+.5);local row=math.floor((ty-g.y)/g.step+.5)
 local target
 if col==cachedCol and row==cachedRow then target=cachedTarget else
 target=col>=0 and col<g.width and row>=0 and row<g.height and row*g.width+col+1 or nil
 if not target or g.links:byte(target)==0 then target=nearest(tx,ty)end
 cachedCol,cachedRow,cachedTarget=col,row,target
 end
 if not target then return end
 if not goal or(target~=goal and remaining==0)then rebuild(target)end
 if waypointNode then local px,py=point(waypointNode);if(px-x)^2+(py-y)^2>.08^2 then return px,py end end
 local node=waypointNode or nearest(x,y);if not node or distance[node]<0 then return end
 local best=node;local score=distance[node];local mask=g.links:byte(node)
 for i=1,8 do if mask&(1<<(i-1))~=0 then
  local nextId=node+dx[i]+dy[i]*g.width
  if distance[nextId]>=0 and distance[nextId]<score then best,score=nextId,distance[nextId]end
 end end
 waypointNode=best;return point(best)
end
function N.clear()goal=nil;remaining=0;waypointNode=nil;cachedCol,cachedRow,cachedTarget=nil,nil,nil end
return N
