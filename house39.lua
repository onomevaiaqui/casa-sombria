local D=require('house39_data')
local M={cameras=D.cameras,palette=D.palette,doors=D.doors,boxes=D.boxes,bits=0}
local depth,key,baseDepth,baseKey
local doorBits,doorSegments=nil,{}
local prefixShot,prefixBits,prefixName
local viewX,viewY,viewPrevious,viewResult,viewBits
local heights={0,1.8}
local function room(x,y)
 if y<3.55 then return x<4 and 'sala'or 'cozinha'end
 if x<2.5 then return 'solteiro'end
 if y<4.7 then return 'corredor'end
 return x<4.8 and 'banheiro'or 'casal'
end
local function open(k)return math.floor(M.bits/2^(k-1))%2==1 end
local function segment(x,y,a,b,c,d)
 local dx,dy=c-a,d-b;local t=math.max(0,math.min(1,((x-a)*dx+(y-b)*dy)/(dx*dx+dy*dy)))
 return (x-a-t*dx)^2+(y-b-t*dy)^2
end
function M.walkable(x,y)
 if x<=.19 or x>=7.91 or y<=.19 or y>=7.91 then return false end
 for _,b in ipairs(D.boxes)do if x>b[1]-.18 and y>b[2]-.18 and x<b[3]+.18 and y<b[4]+.18 then return false end end
 if doorBits~=M.bits then
  for k,d in ipairs(D.doors)do
   local a=open(k)and d.turn*math.pi/180 or 0;local sn,cs=math.sin(a),math.cos(a)
   local dx,dy=d.axis[1]*cs-d.axis[2]*sn,d.axis[1]*sn+d.axis[2]*cs
   local e=doorSegments[k]or {};doorSegments[k]=e;e[1],e[2],e[3],e[4]=d.hinge[1],d.hinge[2],d.hinge[1]+dx,d.hinge[2]+dy
  end
  doorBits=M.bits
 end
 for _,d in ipairs(doorSegments)do
  if segment(x,y,d[1],d[2],d[3],d[4])<.205^2 then return false end
 end
 return true
end
local function sees(c,x,y)
 local gx,gy=math.floor(x/.15+.5),math.floor(y/.15+.5)
 if gx<0 or gy<0 or gx>=55 or gy>=55 then return false end
 local n=gy*55+gx;return math.floor((c.vis:byte(math.floor(n/8)+1)or 0)/2^(n%8))%2==1
end
function M.clearance(c,x,y)
 local edge=1e6
 for _,z in ipairs(heights)do
  local m=c.m;local w=m[4][1]*x+m[4][2]*y+m[4][3]*z+m[4][4]
  if w<.15 then return -1e6 end
  local sx=((m[1][1]*x+m[1][2]*y+m[1][3]*z+m[1][4])/w+1)*240
  local sy=(1-(m[2][1]*x+m[2][2]*y+m[2][3]*z+m[2][4])/w)*135
  edge=math.min(edge,sx-5,475-sx,sy-14,266-sy)
 end
 return edge
end
function M.selectCamera(x,y,previous)
 if x==viewX and y==viewY and previous==viewPrevious and M.bits==viewBits then return viewResult end
 local rn=room(x,y);local best,score=previous or 1,-1e9
 for i,c in ipairs(D.cameras)do
  if sees(c,x,y)then
   local v=M.clearance(c,x,y)+(c.room==rn and 1000 or 0)+(i==previous and 12 or 0)
   if v>score then best,score=i,v end
  end
 end
 viewX,viewY,viewPrevious,viewResult,viewBits=x,y,previous,best,M.bits
 return best
end
function M.prefix(shot)
 if shot==prefixShot and M.bits==prefixBits then return prefixName end
 local c=D.cameras[shot];local st=0
 for k=0,2 do local n=2^k;if math.floor(c.mask/n)%2==1 and math.floor(M.bits/n)%2==1 then st=st+n end end
 prefixShot,prefixBits,prefixName=shot,M.bits,'h39_'..c.name..'s'..string.format('%d',st)
 return prefixName
end
function M.prepare(shot)
 local name=M.prefix(shot);if name==key then return end
 local function expand(raw,base)
  local parts,chunk={},{};local cursor=1
  for i=1,#raw,2 do
   local n,v=raw:byte(i,i+1)
   if not base then chunk[#chunk+1]=string.rep(string.char(v),n)
   elseif v==0 then chunk[#chunk+1]=base:sub(cursor,cursor+n-1)
   else local changed={};for j=cursor,cursor+n-1 do changed[#changed+1]=string.char(base:byte(j)~v)end;chunk[#chunk+1]=table.concat(changed)end
   cursor=cursor+n
   if #chunk==128 then parts[#parts+1]=table.concat(chunk);chunk={}end
  end
  if #chunk>0 then parts[#parts+1]=table.concat(chunk)end
  return table.concat(parts)
 end
 local bk='h39b_'..D.cameras[shot].name
 if baseKey~=bk then baseDepth=expand((require(bk)));baseKey=bk;if type(package)=='table'and package.loaded then package.loaded[bk]=nil end end
 local module='h39d_'..name:sub(5);local raw=require(module)
 depth=#raw==0 and baseDepth or expand(raw,baseDepth);assert(#depth==8160,'Profundidade Casa39 incompleta');key=name
 if type(package)=='table'and package.loaded then package.loaded[module]=nil end
end
local function visible(x,y,z)
 local ix,iy=math.floor(x/4),math.floor(y*68/270)
 if ix<0 or ix>=120 or iy<0 or iy>=68 then return false end
 return z<=(depth:byte(iy*120+ix+1)or 255)/10+.14
end
function M.triangleVisible(a,b,c)
 return visible((a[1]+b[1]+c[1])/3,(a[2]+b[2]+c[2])/3,(a[3]+b[3]+c[3])/3)
end
function M.setDoor(k,value)
 local bit=2^(k-1);if open(k)~=value then M.bits=M.bits+(value and bit or -bit)end
 doorBits=nil;key=nil;prefixShot=nil;viewBits=nil
end
function M.planDoor(x,y)
 local best,dist=nil,1.1^2
 for k,d in ipairs(D.doors)do local q=(x-d.center[1])^2+(y-d.center[2])^2;if q<dist then best,dist=k,q end end
 if not best then return nil end
 local d=D.doors[best];local tx,ty=d.axis[1],d.axis[2];local len=math.sqrt(tx*tx+ty*ty);tx,ty=tx/len,ty/len
 local nx,ny=-ty,tx;local side=(x-d.center[1])*nx+(y-d.center[2])*ny>=0 and 1 or -1;nx,ny=nx*side,ny*side
 local was=open(best)
 local function clear(px,py)
  local here=(px-d.center[1])^2+(py-d.center[2])^2
  for k,other in ipairs(D.doors)do if k~=best and(px-other.center[1])^2+(py-other.center[2])^2<here+.02 then return false end end
  for i=0,8 do
   local a=d.turn*math.pi/180*i/8;local sn,cs=math.sin(a),math.cos(a)
   local ex=d.hinge[1]+d.axis[1]*cs-d.axis[2]*sn;local ey=d.hinge[2]+d.axis[1]*sn+d.axis[2]*cs
   if segment(px,py,d.hinge[1],d.hinge[2],ex,ey)<.23^2 then return false end
  end
  M.setDoor(best,false);local a=M.walkable(px,py);M.setDoor(best,true);local b=M.walkable(px,py);M.setDoor(best,was);return a and b
 end
 local dock,target
 for _,distance in ipairs({.78,.94,.62})do for _,offset in ipairs({0,.18,-.18,.32,-.32,.45,-.45})do
  local px,py=d.center[1]+nx*distance+tx*offset,d.center[2]+ny*distance+ty*offset
  if not dock and clear(px,py)then dock={px,py}end
  px,py=d.center[1]-nx*distance+tx*offset,d.center[2]-ny*distance+ty*offset
  if not target and clear(px,py)then target={px,py}end
 end end
 if not dock or not target then return nil end
 return {index=best,center=d.center,dock=dock,target=target,kind=side>0 and 'open_in'or 'open_out'}
end
function M.action(x,y)
 if (x-7.85)^2+(y-2.4)^2<.95^2 then return 'exit'end
 if x<.95 and math.abs(y-.9)<.65 then return 'front'end
 local best,dist=nil,1.1^2
 for k,d in ipairs(D.doors)do local q=(x-d.center[1])^2+(y-d.center[2])^2;if q<dist then best,dist=k,q end end
 if not best then return 'Nao ha nada para examinar aqui.'end
 local bit=2^(best-1);M.bits=M.bits+(open(best)and -bit or bit)
 -- A leaf cannot close through the player or swing onto their position.
 if not M.walkable(x,y)then M.bits=M.bits+(open(best)and -bit or bit);key=nil;return 'B: ABRIR PORTA'end
 key=nil;return open(best)and 'Porta aberta.'or 'Porta fechada.'
end
function M.release()depth,key,baseDepth,baseKey=nil,nil,nil,nil end
function M.room(x,y)return room(x,y)end
return M
