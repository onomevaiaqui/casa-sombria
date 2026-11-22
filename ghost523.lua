local G={time=0,yaw=0}
local D,H
local hangingSlots540={205,206,207,208,209,210,211,212,213,214,215,219,220,221,222,223}
local blendPixel525
local function signed(a,b)local n=a+b*256;return(n>32767 and n-65536 or n)/1000 end
local ghostMask={}
local minX,minY,maxX,maxY
local buffers={{points={},faces={},pool={}},{points={},faces={},pool={}},{points={},faces={},pool={}}}
local function edge(p,q,y)
 if(p[2]<=y and q[2]>y)or(q[2]<=y and p[2]>y)then return p[1]+(q[1]-p[1])*(y-p[2])/(q[2]-p[2])end
end
local function raster(ui,a,b,c,col,ghost)
 if not ghost then ui.trisfill(a[1],a[2],b[1],b[2],c[1],c[2],col);return end
 local y0=math.max(15,math.ceil(math.min(a[2],b[2],c[2])));local y1=math.min(269,math.floor(math.max(a[2],b[2],c[2])))
 for y=y0,y1 do
  local lo,hi=1e9,-1e9
  local x=edge(a,b,y);if x then lo=math.min(lo,x);hi=math.max(hi,x)end
  x=edge(b,c,y);if x then lo=math.min(lo,x);hi=math.max(hi,x)end
  x=edge(c,a,y);if x then lo=math.min(lo,x);hi=math.max(hi,x)end
  lo=math.max(0,math.ceil(lo));hi=math.min(479,math.floor(hi))
  if lo<=hi then
   minX,minY,maxX,maxY=math.min(minX,lo),math.min(minY,y),math.max(maxX,hi),math.max(maxY,y)
   local base=y*480;for px=lo,hi do ghostMask[base+px]=col end
  end
 end
end
local function farther(a,b)return a[4]>b[4]end
function G.prepare(metric,room,x,y,dt)
 if room~='quintal'then return false end
 D=D or require('ghost523_data');G.time=G.time+math.max(0,dt or 1/60)
 local gx,gy=metric.ground(room,x,y);local dx,dy=gx-1.4585,gy-7.676;local a=math.atan(dy,dx)-math.pi/2-math.rad(35)-math.pi
 while a>math.pi do a=a-2*math.pi end;while a< -math.pi do a=a+2*math.pi end
 a=math.max(-1.15,math.min(1.15,a));G.yaw=G.yaw+(a-G.yaw)*math.min(1,(dt or 1/60)*3)
 local project=require('cameras168').projector(room);local _,_,pd=project(gx,gy,.9);local _,_,gd=project(1.4585,7.676,.9);return gd<pd
end
function G.draw(ui,metric,room)
 if room~='quintal'or not D then return end
 blendPixel525=require('cameras168').ghostBlend(room)
 local angle=math.sin(G.time*1.55)*.18;local ca,sa=math.cos(angle),math.sin(angle);local cy,sy=math.cos(math.rad(35)),math.sin(math.rad(35));local hy,hx=math.sin(G.yaw),math.cos(G.yaw)
 local camera=require('cameras168');local project=camera.projector(room);local visible=camera.occlusion(room);local meshIndex=0
 local function mesh(raw,faces,ghost,hanging)
  meshIndex=meshIndex+1;local buffer=buffers[meshIndex]
  if ghost then for k in pairs(ghostMask)do ghostMask[k]=nil end;minX,minY,maxX,maxY=480,270,-1,-1 end
  local pts=buffer.points;local pointCount=0
  for i=1,#raw,7 do
   local a,b,c,d,e,f,h=raw:byte(i,i+6);local x,y,z=signed(a,b),signed(c,d),signed(e,f)
   if ghost and not hanging and h==1 then local xx,yy=x-D.head[1],y-D.head[2];x=D.head[1]+xx*hx-yy*hy;y=D.head[2]+xx*hy+yy*hx end
   if ghost and not hanging then x=-x;y=-y end
   local yy,zz=y*ca-(z-2.02)*sa,y*sa+(z-2.02)*ca+2.02
   local wx,wy=1.4585+x*cy-yy*sy,7.676+x*sy+yy*cy
   if hanging then local swing=math.sin(G.time*1.15)*.035;local cs,ss=math.cos(swing),math.sin(swing);wx=H.x+x*cs-(z-2.20)*ss;wy=H.y+y;zz=2.20+x*ss+(z-2.20)*cs end
   local sx,ss,depth=project(wx,wy,zz);pointCount=pointCount+1;local pt=pts[pointCount];if not pt then pt={};pts[pointCount]=pt end;pt[1],pt[2],pt[3]=sx,ss,depth
  end
  local fs=buffer.faces;for i=#fs,1,-1 do fs[i]=nil end;local count=0
  for i=1,#faces,7 do local a,b,c,d,e,f,k=faces:byte(i,i+6);local p,q,r=pts[a+b*256],pts[c+d*256],pts[e+f*256];if p[3]>.1 and q[3]>.1 and r[3]>.1 and visible(p,q,r)then count=count+1;local f=buffer.pool[count];if not f then f={};buffer.pool[count]=f end;f[1],f[2],f[3],f[4],f[5]=p,q,r,p[3]+q[3]+r[3],k;fs[count]=f end end
  table.sort(fs,farther)
  for _,f in ipairs(fs)do raster(ui,f[1],f[2],f[3],hanging and hangingSlots540[f[5]+1]or(ghost and(f[5]==1 and 241 or 240)or 240),ghost)end
  if ghost then
   -- Keep the original alpha and edge treatment; merge only equal final pixels.
   for y=minY,maxY do
    local runStart,runInk;local base=y*480
    for x=minX,maxX+1 do
     local pixel=base+x;local col=x<=maxX and ghostMask[pixel];local ink
     if col then
      local n=(ghostMask[pixel-1]and 1 or 0)+(ghostMask[pixel+1]and 1 or 0)+(ghostMask[pixel-480]and 1 or 0)+(ghostMask[pixel+480]and 1 or 0)
      local level=n<3 and 1 or(n<4 and 2 or 3)
      ink=blendPixel525 and blendPixel525(x,y,col==241 and 1 or 0,level)or col
     end
     if ink~=runInk then
      if runInk then ui.line(runStart,y,x-1,y,runInk)end
      runStart,runInk=x,ink
     end
    end
   end
  end
 end
 mesh(D.sv,D.sf,false);mesh(D.v,D.f,true)
 if require('cameras168').shot==8 then H=H or require('ghost531_data');for i,color in ipairs(H.palette)do ui.palset(hangingSlots540[i],require('lighting593').color(color,room,H.x,H.y))end;mesh(H.v,H.f,false,true)end
end
return G
