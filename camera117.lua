-- Fixed camera zones: world coordinates and collision geometry remain those of 11.2.
local data=require('camera_data117')
local C={room=nil,active=false}
local sprites,master,map
function C.setup(refs,palette)
 sprites,master=refs,palette;map={}
 C.enabled=not not refs.camera117_sala_0
 for i,color in ipairs(palette)do map[color]=i-1 end
end
local function project(c,x,y,z)
 local m=c.m;local q={x,y,z,1};local p={}
 for i=1,4 do p[i]=0;for k=1,4 do p[i]=p[i]+m[i][k]*q[k]end end
 local v=c.view;local depth=-(v[3][1]*x+v[3][2]*y+v[3][3]*z+v[3][4])
 return (p[1]/p[4]+1)*240,(1-p[2]/p[4])*135,depth
end
local function ground(c,x,y)
 local m=c.m;local u,v=x/240-1,1-y/135
 local a,b=m[1][1]-u*m[4][1],m[1][2]-u*m[4][2]
 local d,e=m[2][1]-v*m[4][1],m[2][2]-v*m[4][2]
 local f,g=u*m[4][4]-m[1][4],v*m[4][4]-m[2][4]
 local det=a*e-b*d;return(f*e-b*g)/det,(a*g-f*d)/det
end
function C.project(room,x,y,z)
 if C.active and C.room==room then return project(data[room],x,y,z)end
end
local function visible(c,x,y,margin)
 -- Test the whole body envelope rather than only the actor's centre/feet.
 for _,xx in ipairs({x-.35,x+.35})do
  for _,yy in ipairs({y-.35,y+.35})do
   for _,z in ipairs({0,1.85})do
    local sx,sy,depth=project(c,xx,yy,z)
    if depth<.3 or sx<margin or sx>480-margin or sy<18+margin or sy>270-margin then return false end
   end
  end
 end
 return true
end
function C.select(room,x,y)
 local c=data[room];local same=C.room==room
 if not same then C.active=false end
 C.room=room
 local available=sprites and sprites['camera117_'..room..'_0']
 if not c or not available then C.active=false;return false end
 -- Different entry/exit thresholds prevent rapid back-and-forth cuts.
 local threshold=c.size[2]*(C.active and .43 or .58)
 if y<threshold or not visible(c,x,y,C.active and 2 or 12)then C.active=false
 elseif y>threshold then C.active=true end
 return C.active
end
function C.background(room)
 if not C.active or C.room~=room then return end
 local result={};for i=0,2 do result[#result+1]=sprites['camera117_'..room..'_'..i]end
 return result
end
function C.palette(room,set)
 if C.active and C.room==room then
  for _,pair in ipairs(data[room].bank)do local i=map[pair[1]];if i then set(i,pair[2])end end
 end
end
local lastRoom,lastDx,lastDy,ux,uy
function C.direction(room,gx,gy,dx,dy)
 if dx==0 and dy==0 then lastRoom=nil;return end
 -- Retain world direction across a camera cut until the player changes/releases input.
 if room~=lastRoom or dx~=lastDx or dy~=lastDy then
  lastRoom,lastDx,lastDy=room,dx,dy
  ux,uy=nil,nil
  if C.active and C.room==room then
   local sx,sy=project(data[room],gx,gy,0)
   local tx,ty=ground(data[room],sx+dx,sy+dy)
   local n=math.sqrt((tx-gx)^2+(ty-gy)^2);ux,uy=(tx-gx)/n,(ty-gy)/n
  end
 end
 return ux,uy
end
function C.captureDirection(room,gx,gy,dx,dy,worldX,worldY)
 local ax,ay=C.direction(room,gx,gy,dx,dy)
 if ax then return ax,ay end
 -- Also latch baseline movement so entering the close shot never reverses it.
 if lastRoom==room and not ux then
  local n=math.sqrt(worldX^2+worldY^2);ux,uy=worldX/n,worldY/n
 end
 return ux,uy
end
function C.triangle(room,a,b,c)
 if not C.active or C.room~=room then return true end
 local sx,sy=(a[1]+b[1]+c[1])/3,(a[2]+b[2]+c[2])/3
 if sx<0 or sx>=480 or sy<0 or sy>=270 then return false end
 local col,row=math.floor(sx/4),math.min(67,math.floor(sy*68/270))
 local z=data[room].depth[row*120+col+1]*.05
 return(a[3]+b[3]+c[3])/3<=z+.14
end
C.data=data
return C
