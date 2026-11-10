-- Render cameras for the shared house geometry. Logical movement stays metric.
local data=require('camera_data168')
local doors=require('doors131')
local memory=require('memory168')
local C={data=data,enabled=false,active=true,room=nil,shot=nil}
local sprites,map
local paletteState,paletteMaster,finalPalette
local occlusionState,occlusionFunction
data.beforeChange=function()
 occlusionState,occlusionFunction,paletteState,paletteMaster,finalPalette=nil,nil,nil,nil,nil
 memory.release()
end
function C.setup(refs,palette)
 sprites=refs;map={};C.enabled=false
 for i,color in ipairs(palette)do map[color]=i-1 end
 for _,prefix in pairs(data.firstprefix)do for i=0,2 do assert(refs[prefix..'_'..i],'Missing scene bitmap '..prefix)end end
 C.enabled=true
end
local function project(c,x,y,z)
 local m=c.m;local w=m[4][1]*x+m[4][2]*y+m[4][3]*z+m[4][4]
 local px=m[1][1]*x+m[1][2]*y+m[1][3]*z+m[1][4]
 local py=m[2][1]*x+m[2][2]*y+m[2][3]*z+m[2][4]
 local v=c.view;local depth=-(v[3][1]*x+v[3][2]*y+v[3][3]*z+v[3][4])
 return(px/w+1)*240,(1-py/w)*135,depth
end
function C.projector(room)
 local c=data[room]and data[room][C.room==room and C.shot or 1]
 return function(x,y,z)if c then return project(c,x,y,z)end end
end

-- Combine rigid actor/world/camera transforms once, not for each vertex.
function C.actorProjector(room,gx,gy,sine,cosine,factor,rx,ry,dx,dy)
 local c=data[room]and data[room][C.room==room and C.shot or 1];if not c then return end
 local xx,xy=(rx*cosine-dx*sine)*factor,(ry*cosine-dy*sine)*factor
 local zx,zy=(rx*sine+dx*cosine)*factor,(ry*sine+dy*cosine)*factor
 local function row(v)return v[1]*xx+v[2]*xy,v[3]*factor,v[1]*zx+v[2]*zy,v[1]*gx+v[2]*gy+v[4]end
 local a,b,d,e=row(c.m[1]);local f,g,h,i=row(c.m[2]);local j,k,l,m=row(c.m[4]);local n,o,p,q=row(c.view[3])
 return function(x,y,z,out)
  local w=j*x+k*y+l*z+m
  local sx=((a*x+b*y+d*z+e)/w+1)*240
  local sy=(1-(f*x+g*y+h*z+i)/w)*135
  out=out or {};out[1],out[2],out[3]=math.floor(sx+.5),math.floor(sy+.5),-(n*x+o*y+p*z+q)
  return out
 end
end
local function ground(c,x,y)
 local m=c.m;local u,v=x/240-1,1-y/135
 local a,b=m[1][1]-u*m[4][1],m[1][2]-u*m[4][2]
 local d,e=m[2][1]-v*m[4][1],m[2][2]-v*m[4][2]
 local f,g=u*m[4][4]-m[1][4],v*m[4][4]-m[2][4]
 local det=a*e-b*d;return(f*e-b*g)/det,(a*g-f*d)/det
end
local function current(room)return data[room]and data[room][C.room==room and C.shot or 1]end
local function eachColor(st,set)
 local bank=st.bankPacked
 for p=1,#bank,4 do local a,b,c,d=bank:byte(p,p+3);set(a+b*256,c+d*256)end
end
local function state(c)
 local mask=doors.stateMask(c.doorBits)
 return assert(c.states[mask],'Missing room door state '..mask)
end
function C.initial(room)
 local prefix=data.firstprefix[room];if not prefix or not sprites then return end
 return{sprites[prefix..'_0'],sprites[prefix..'_1'],sprites[prefix..'_2']}
end
local function isVisible(c,index)
 if c.visibilityHex then
  local cell=index-1;local offset=(cell//8)*2+1
  local a,b=c.visibilityHex:byte(offset,offset+1)
  if not a or not b then return false end
  local hi=a>=97 and a-87 or a-48;local lo=b>=97 and b-87 or b-48
  return (((hi*16+lo)>>(cell%8))&1)==1
 end
 return c.visibility:byte(index)==49
end
C.isVisible=isVisible
local function clearance(c,x,y)
 local col=math.max(0,math.min(c.visibilityWidth-1,math.floor(x/c.visibilityStep+.5)))
 local row=math.max(0,math.min(c.visibilityHeight-1,math.floor((y-(c.visibilityY0 or 0))/c.visibilityStep+.5)))
 if not isVisible(c,row*c.visibilityWidth+col+1)then return -1e6 end
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
 -- The shed doorway has a deliberate approach shot: keep the roof and clerestory in frame.
 if room=='quintal'and x>=.75 and x<=3.2 and y>=4.4 and y<=6.3 and views[7]and clearance(views[7],x,y)>=8 then C.shot=7;return true end
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
local backgroundRefs={}
function C.background(room)
 local c=current(room);if not c or not sprites then return end
 local s=state(c);backgroundRefs[1],backgroundRefs[2],backgroundRefs[3]=sprites[s.prefix..'_0'],sprites[s.prefix..'_1'],sprites[s.prefix..'_2'];return backgroundRefs
end
function C.palette(room,set)
 local c=current(room);if c then eachColor(state(c),function(key,value)local i=map[key];if i then set(i,value)end end) end
end
function C.nativePalette(room,master,set)
 local c=current(room);if not c then return end;local st=state(c)
 if paletteState~=st or paletteMaster~=master then
  local colors={};for i,v in ipairs(master)do colors[i-1]=v end
  require('metric_rooms').applyPalette(master,function(i,v)colors[i]=v end,room)
  eachColor(st,function(key,value)local i=map[key];if i then colors[i]=value end end)
  finalPalette=colors;paletteState,paletteMaster=st,master
 end
 for i=0,#master-1 do set(i,finalPalette[i])end
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
local function alwaysVisible()return true end
function C.occlusion(room)
 local view=current(room);if not view then return alwaysVisible end
 local s=state(view);if occlusionState==s then return occlusionFunction end
 local depth=memory.depth(s);local sx,sy=s.depthWidth/480,s.depthHeight/270
 local width,step=s.depthWidth,s.depthStep
 occlusionState=s
 occlusionFunction=function(a,b,c)
  local x,y=(a[1]+b[1]+c[1])/3,(a[2]+b[2]+c[2])/3
  if x<0 or x>=480 or y<0 or y>=270 then return false end
  local z=depth:byte(math.floor(y*sy)*width+math.floor(x*sx)+1)*step
  return(a[3]+b[3]+c[3])/3<=z+.14
 end
 return occlusionFunction
end
function C.triangle(room,a,b,c)return C.occlusion(room)(a,b,c)end
function C.release()
 occlusionState,occlusionFunction,paletteState,paletteMaster,finalPalette=nil,nil,nil,nil,nil
 C.room,C.shot=nil,nil;data.release()
end
return C
