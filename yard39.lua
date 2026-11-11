local D=require('yard39_data')
local Y={cameras=D.cameras,opened=false,hits=0}
local depth,key
local function decode(raw)
 local t={};for i=1,#raw,2 do local n,v=raw:byte(i,i+1);t[#t+1]=string.rep(string.char(v),n)end;return table.concat(t)
end
function Y.walkable(x,y)
 local front=x>5.95 and x<7.85 and y>.70 and y<9.30
 local doorstep=x>7.7 and x<8.12 and math.abs(y-5)<.30
 local neck=x>6.4 and x<7.4 and y>-.85 and y<.92
 local side=x>6.4 and x<16.25 and y>-.85 and y<.04
 local garden=x>8.5 and x<16.25 and y>-3.10 and y<.55
 if not(front or doorstep or neck or side or garden)then return false end
 if not Y.opened and y<.52 and y>-.05 and x>6.25 and x<7.55 then return false end
 -- Open door leaf and concrete lips remain solid; never close the path through the middle.
 if x>7.18 and x<8.12 and math.abs(y-4.575)<.18 then return false end
 for _,p in ipairs(D.obstacles or {})do if(x-p[1])^2+(y-p[2])^2<p[3]^2 then return false end end
 return true
end
local function sees(c,x,y)
 local gx,gy=math.floor((x-5)/.2+.5),math.floor((y+4)/.2+.5)
 if gx<0 or gy<0 or gx>=70 or gy>=70 then return false end
 local n=gy*70+gx;return math.floor((c.vis:byte(math.floor(n/8)+1)or 0)/2^(n%8))%2==1
end
function Y.clearance(c,x,y)
 local edge=1e6;local m=c.m
 for k=0,1 do local z=k*1.8;local w=m[4][1]*x+m[4][2]*y+m[4][3]*z+m[4][4]
  if w<.15 then return -1e6 end
  local sx=((m[1][1]*x+m[1][2]*y+m[1][3]*z+m[1][4])/w+1)*240
  local sy=(1-(m[2][1]*x+m[2][2]*y+m[2][3]*z+m[2][4])/w)*135
  edge=math.min(edge,sx-5,475-sx,sy-14,266-sy)
 end
 return edge
end
function Y.selectCamera(x,y,previous)
 local preferred=y<-.55 or x>8.3
 local best,score=nil,-1e9
 for i,c in ipairs(D.cameras)do if sees(c,x,y)then
  local v=Y.clearance(c,x,y)+((preferred and i>=3 or not preferred and i<=2)and 1000 or 0)+(i==previous and 12 or 0)
  if v>score then best,score=i,v end
 end end
 if best then return best end
 for i,c in ipairs(D.cameras)do local v=Y.clearance(c,x,y);if v>score then best,score=i,v end end
 return best or 1
end
function Y.prefix(shot)return 'yard39_'..D.cameras[shot].name..(Y.opened and '1'or '0')end
function Y.prepare(shot)
 local name=Y.prefix(shot);if key==name then return end
 local module='y39d_'..D.cameras[shot].name..(Y.opened and '1'or '0')
 depth=nil;depth=decode((require(module)));key=name;assert(#depth==8160,'Profundidade quintal incompleta')
 if type(package)=='table'and package.loaded then package.loaded[module]=nil end
end
function Y.triangleVisible(a,b,c)
 local ix,iy=math.floor((a[1]+b[1]+c[1])/12),math.floor((a[2]+b[2]+c[2])/3*68/270)
 if ix<0 or ix>=120 or iy<0 or iy>=68 then return false end
 return (a[3]+b[3]+c[3])/3<=(depth:byte(iy*120+ix+1)or 255)/10+.14
end
function Y.nearBoards(x,y)return (x-6.9)^2+(y-.25)^2<1.25^2 end
function Y.hit(x,y,angle,equipped,inv)
 if Y.opened or not Y.nearBoards(x,y)then return end
 if equipped~='crowbar'then return 'Preciso do machadinho para quebrar as tabuas.'end
 local dx,dy=6.9-x,.25-y;local length=math.sqrt(dx*dx+dy*dy)
 if length>.05 and (math.sin(angle)*dx-math.cos(angle)*dy)/length<.60 then return end
 Y.hits=Y.hits+1;if inv then inv.collected.yard39_hits=Y.hits end
 if Y.hits>=3 then Y.opened=true;key=nil;if inv then inv.collected.yard39_open=true end;return 'As tabuas cederam. Agora posso passar.'end
 return 'A madeira esta cedendo...'
end
function Y.enter(inv)Y.opened=inv and inv.collected.yard39_open or false;Y.hits=Y.opened and 3 or(inv and inv.collected.yard39_hits or 0);key=nil end
function Y.atDoor(x,y)return x>7.78 and math.abs(y-5)<.30 end
function Y.release()depth,key=nil,nil end
return Y
