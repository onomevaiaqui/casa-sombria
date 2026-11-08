-- Render cameras for the shared house geometry. Logical movement stays metric.
local data=require('camera_data153')
local doors=require('doors131')
local C={data=data,enabled=false,active=true,room=nil,shot=nil}
local sprites,map
function C.setup(refs,palette)
 sprites=refs;map={};C.enabled=false
 for i,color in ipairs(palette)do map[color]=i-1 end
 for _,views in pairs(data)do for _,c in ipairs(views)do for _,state in pairs(c.states)do
  for i=0,2 do assert(refs[state.prefix..'_'..i],'Missing scene bitmap '..state.prefix)end
  C.enabled=true
 end end end
end
local function project(c,x,y,z)
 local q={x,y,z,1};local p={}
 for i=1,4 do p[i]=0;for k=1,4 do p[i]=p[i]+c.m[i][k]*q[k]end end
 local v=c.view;local depth=-(v[3][1]*x+v[3][2]*y+v[3][3]*z+v[3][4])
 return(p[1]/p[4]+1)*240,(1-p[2]/p[4])*135,depth
end
local function ground(c,x,y)
 local m=c.m;local u,v=x/240-1,1-y/135
 local a,b=m[1][1]-u*m[4][1],m[1][2]-u*m[4][2]
 local d,e=m[2][1]-v*m[4][1],m[2][2]-v*m[4][2]
 local f,g=u*m[4][4]-m[1][4],v*m[4][4]-m[2][4]
 local det=a*e-b*d;return(f*e-b*g)/det,(a*g-f*d)/det
end
local function current(room)return data[room]and data[room][C.room==room and C.shot or 1]end
local function state(c)
 local mask=doors.stateMask(c.doorBits)
 return assert(c.states[mask],'Missing room door state '..mask)
end
function C.initial(room)
 local c=data[room]and data[room][1];if not c or not sprites then return end
 local s=state(c);return{sprites[s.prefix..'_0'],sprites[s.prefix..'_1'],sprites[s.prefix..'_2']}
end
local function clearance(c,x,y)
 local col=math.max(0,math.min(c.visibilityWidth-1,math.floor(x/c.visibilityStep+.5)))
 local row=math.max(0,math.min(c.visibilityHeight-1,math.floor((y-(c.visibilityY0 or 0))/c.visibilityStep+.5)))
 if c.visibility[row*c.visibilityWidth+col+1]~=1 then return -1e6 end
 local edge=1e6
 for _,xx in ipairs({x-.2,x+.2})do for _,yy in ipairs({y-.2,y+.2})do for _,z in ipairs({0,1.85})do
  local a,b,depth=project(c,xx,yy,z);if depth<.15 then return-1e6 end
  edge=math.min(edge,a-5,475-a,b-21,265-b)
 end end end
 return edge
end
function C.select(room,x,y)
 local views=data[room];if not views then return end
 if C.room~=room then C.shot=nil end;C.room=room
 local score=C.shot and clearance(views[C.shot],x,y)or-1e6
 if score<5 then
  local best,bs=C.shot,score
  for i,c in ipairs(views)do local s=clearance(c,x,y)
   if not C.shot and s>=8 then best,bs=i,s;break end
   if s>bs then best,bs=i,s end
  end
  if not C.shot or bs>score+3 or score<0 then C.shot=best or 1 end
 end
 return true
end
function C.project(room,x,y,z)local c=current(room);if c then return project(c,x,y,z)end end
function C.background(room)
 local c=current(room);if not c or not sprites then return end
 local s=state(c);return{sprites[s.prefix..'_0'],sprites[s.prefix..'_1'],sprites[s.prefix..'_2']}
end
function C.palette(room,set)
 local c=current(room);if c then for _,p in ipairs(state(c).bank)do local i=map[p[1]];if i then set(i,p[2])end end end
end
local lastRoom,lastDx,lastDy,ux,uy
function C.direction(room,gx,gy,dx,dy)
 if dx==0 and dy==0 then lastRoom=nil;return end
 if room~=lastRoom or dx~=lastDx or dy~=lastDy then
  lastRoom,lastDx,lastDy=room,dx,dy;ux,uy=nil,nil;local c=current(room)
  if c then local sx,sy=project(c,gx,gy,0);local x,y=ground(c,sx+dx,sy+dy)
   local n=math.sqrt((x-gx)^2+(y-gy)^2);ux,uy=(x-gx)/n,(y-gy)/n
  end
 end
 return ux,uy
end
function C.captureDirection(room,gx,gy,dx,dy,wx,wy)
 local a,b=C.direction(room,gx,gy,dx,dy)
 if a then return a,b end
 local n=math.sqrt(wx*wx+wy*wy);return wx/n,wy/n
end
function C.triangle(room,a,b,c)
 local view=current(room);if not view then return true end
 local x,y=(a[1]+b[1]+c[1])/3,(a[2]+b[2]+c[2])/3
 if x<0 or x>=480 or y<0 or y>=270 then return false end
 local s=state(view);local col,row=math.floor(x*s.depthWidth/480),math.floor(y*s.depthHeight/270)
 local z=s.depth:byte(row*s.depthWidth+col+1)*s.depthStep
 return(a[3]+b[3]+c[3])/3<=z+.14
end
return C
