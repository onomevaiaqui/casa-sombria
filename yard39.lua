local cameraModuleCache=type(package)=='table'and package.loaded or nil
local D=require('yard39_data')
local installNames346=require('asset_names346')
local Y={cameras=D.cameras,opened=false,hits=0}
local depth,key
local function decode(raw)return require('cinema356').unpack(raw)end

function Y.walkable(x,y)
 if x>5.5 and x<19.93 and y> -1.212 and y<11.277 then return false end
 if x>6.6 and x<17.65 and y> -3.05 and y< -1.3 then return true end
 for _,r in ipairs(D.solidBlocks or {})do if x>r[1]and x<r[2]and y>r[3]and y<r[4]then return false end end
 if x>17.65 and x<18.3 and y<-3.3 and y>-15.8 then return false end
 if math.abs(y+15.8)<.23 and x>5.5 and x<24.7 and(x<16.55 or x>17.45)then return false end
 if y<=-15.8 then
  local near=false
  for i=1,#D.trail-1 do local a,b=D.trail[i],D.trail[i+1]
   if y>=math.min(a[2],b[2])-.52 and y<=math.max(a[2],b[2])+.52 then
    local dx,dy=b[1]-a[1],b[2]-a[2];local t=math.max(0,math.min(1,((x-a[1])*dx+(y-a[2])*dy)/(dx*dx+dy*dy)))
    if(x-a[1]-t*dx)^2+(y-a[2]-t*dy)^2<.52^2 then near=true;break end
   end
  end
  local free=x>7.3 and x<22.7 and y>-48.8 and y<-37.1
  if not(near or free)then return false end

  for _,r in ipairs(D.plazaBlocks or {})do if x>r[1]and x<r[2]and y>r[3]and y<r[4]then return false end end
 else
  local original=(x>5.95 and x<7.85 and y>.70 and y<8)or(x>7.7 and x<8.12 and math.abs(y-5)<.3)or(x>6.4 and x<7.4 and y>-3.6 and y<.92)or(x>6.4 and x<16.25 and y>-.85 and y<.7)or(x>8.5 and x<16.25 and y>-3.1 and y<.55)
  local extra=(x>16.25 and x<17.65 and y>-3.1 and y<.1)or(x>16.4 and x<17.65 and y>-15.55 and y<-13.1)
  for _,r in ipairs(D.rects)do if x>r[1]and x<r[2]and y>r[3]and y<r[4]then extra=true;break end end
  if not(original or extra)then return false end
  if not Y.opened and y>-3.62 and y<-3.08 and x>6.25 and x<7.55 then return false end
 end
 for _,p in ipairs(D.obstacles or {})do if(x-p[1])^2+(y-p[2])^2<p[3]^2 then return false end end
 return true
end

local function sees(c,x,y)
 local g=c.grid or D.grid;local gx,gy=math.floor((x-g.x0)/g.step+.5),math.floor((y-g.y0)/g.step+.5)
 if gx<0 or gy<0 or gx>=g.w or gy>=g.h then return false end
 local n=gy*g.w+gx;return math.floor((c.vis:byte(math.floor(n/8)+1)or 0)/2^(n%8))%2==1
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
 local best,score=nil,-1e9
 for i,c in ipairs(D.cameras)do if c.name~='quintal'and c.name~='fundos'and sees(c,x,y)and Y.clearance(c,x,y)>=0 then
  local preferred=(y>=-3.6 and i<=4)or(y<-3.6 and y>-5 and x<16.5 and(i==5 or i==6))or(x>16.4 and y<-3.6 and y>-14 and(i==7 or i==8))or(y<=-14 and y>-18.5 and i==9)or(y<=-16 and y>-38.6 and c.name:sub(1,5)=='mata_')or(y<=-37.1 and c.name:sub(1,6)=='praca_')
  local v=Y.clearance(c,x,y)+(preferred and 1000 or 0)+(i==previous and 14 or 0)
  if y<=-15.8 and c.pos then v=v-2*((c.pos[1]-x)^2+(c.pos[2]-y)^2)end
  if v>score then best,score=i,v end
 end end
 if best then return best end
 for i,c in ipairs(D.cameras)do if c.name~='quintal'and c.name~='fundos'then local v=Y.clearance(c,x,y);if v>score then best,score=i,v end end end
 return best or 1
end
local houseSelect321=Y.selectCamera
local shots321={};for i,c in ipairs(D.cameras)do shots321[c.name]=i end
local function usable321(i,x,y)return i and sees(D.cameras[i],x,y)and Y.clearance(D.cameras[i],x,y)>=8 end
function Y.selectCamera(x,y,previous)
 if y>-15.8 then return houseSelect321(x,y,previous)end
 local old=previous and D.cameras[previous];local name=old and old.name or ''
 local inside=(x-11.86)^2+(y+43.3)^2<2.1^2
 if name=='gazebo_interior'then inside=(x-11.86)^2+(y+43.3)^2<3.0^2 end
 if inside and usable321(shots321.gazebo_interior,x,y)then return shots321.gazebo_interior end
 local preferred
 if y<-38 then
  preferred=y<-44 and shots321.praca_geral_sul or shots321.praca_geral_norte
  if name=='praca_geral_norte'and y>-45 then preferred=previous elseif name=='praca_geral_sul'and y<-43 then preferred=previous end
 else
  preferred=y>-23 and shots321.mata_entrada_alta or(y>-31 and shots321.mata_meio_alta or shots321.mata_final_alta)
 end
 if usable321(previous,x,y)and name~='gazebo_interior' then
  if y>=-38 and name:sub(1,5)=='mata_'then return previous end
  if y<-37.2 and name:sub(1,6)=='praca_'and (previous==preferred or Y.clearance(D.cameras[previous],x,y)>=24)then return previous end
 end
 if usable321(preferred,x,y)then return preferred end
 local best,score
 for _,n in ipairs({'mata_entrada_alta','mata_meio_alta','mata_final_alta','praca_geral_norte','praca_geral_sul','praca_geral_oeste','gazebo_interior'})do
  local i=shots321[n]
  if usable321(i,x,y)then local v=Y.clearance(D.cameras[i],x,y);if not score or v>score then best,score=i,v end end
 end
 return best or preferred or previous or 1
end

function Y.zone(x,y)
 if x> -30 and x< -17 and y> -82 and y< -73 then return 'BAR - PROTOTIPO'end
 if y<-37.1 then return 'PRACA DO BAIRRO' end
 if y<-16.4 then return 'MATA - trilha para a praca' end
 if y<-14 then return 'CASA 41 - grade rompida' end
 if x>16.4 and y<-3.6 then return 'CASA 41 - fundos' end
 if y<-3.6 then return 'CASA 41 - lateral' end
 return 'JARDIM 39'
end
local function marketState350()local f=Y.marketInventory and Y.marketInventory.collected or{};return(f.market_service_open and 1 or 0)+(f.market_front_open and 2 or 0)end
function Y.prefix(shot)local c=D.cameras[shot];if c.stylePrefix then return c.stylePrefix..((c.styleVariants and Y.opened)and '1'or '0')end;if c.marketCamera then return c.marketPrefix..marketState350()end;return 'yard39_'..c.name..(Y.opened and '1'or '0')end
function Y.prepare(shot)
 local name=Y.prefix(shot);if key==name then return end
 local module='y39d_'..D.cameras[shot].name..(Y.opened and '1'or '0')
 if D.cameras[shot].marketCamera then module=D.cameras[shot].marketDepth..marketState350()end
 if D.cameras[shot].styleDepth then local c=D.cameras[shot];module=c.styleDepth..((c.styleVariants and Y.opened)and '1'or '0')end
 module=installNames346[module]or module
 depth=nil;require('cinema356').pressure();depth=decode((require(module)));key=name;assert(#depth==8160,'Profundidade quintal incompleta')
 if type(package)=='table'and package.loaded then package.loaded[module]=nil end
end
function Y.triangleVisible(a,b,c)
 local ix,iy=math.floor((a[1]+b[1]+c[1])/12),math.floor((a[2]+b[2]+c[2])/3*68/270)
 if ix<0 or ix>=120 or iy<0 or iy>=68 then return false end
 local sample=depth:byte(iy*120+ix+1)or 255
 -- 255 is the far/no-hit sentinel, not an opaque plane at 25.5 m.
 return sample==255 or (a[3]+b[3]+c[3])/3<=sample/10+.14
end
function Y.nearBoards(x,y)return (x-6.9)^2+(y+3.35)^2<1.25^2 end
function Y.hit(x,y,angle,equipped,inv)
 if Y.opened or not Y.nearBoards(x,y)then return end
 if equipped~='crowbar'then return 'Preciso do machadinho para quebrar as tabuas.'end
 local dx,dy=6.9-x,-3.35-y;local length=math.sqrt(dx*dx+dy*dy)
 if length>.05 and (math.sin(angle)*dx-math.cos(angle)*dy)/length<.60 then return end
 Y.hits=Y.hits+1;if inv then inv.collected.yard39_hits=Y.hits end
 if Y.hits>=3 then Y.opened=true;key=nil;if inv then inv.collected.yard39_open=true end;return 'As tabuas cederam. Agora posso passar.'end
 return 'A madeira esta cedendo...'
end
function Y.enter(inv)Y.opened=inv and inv.collected.yard39_open or false;Y.hits=Y.opened and 3 or(inv and inv.collected.yard39_hits or 0);key=nil end
function Y.atDoor(x,y)return x>7.78 and math.abs(y-5)<.30 end
function Y.release()depth,key=nil,nil end
local baseWalk328=Y.walkable
local function onLoop328(x,y)
 if x<12.3 or x>24.0 or y< -49.7 or y> -42.3 then return false end
 for i=1,#D.parkLoop-1,3 do local a,b=D.parkLoop[i],D.parkLoop[math.min(i+3,#D.parkLoop)];local dx,dy=b[1]-a[1],b[2]-a[2];local t=math.max(0,math.min(1,((x-a[1])*dx+(y-a[2])*dy)/(dx*dx+dy*dy)))
 if(x-a[1]-t*dx)^2+(y-a[2]-t*dy)^2<.58^2 then return true end end
 return false
end
function Y.walkable(x,y)
 if onLoop328(x,y)then
  for _,r in ipairs(D.solidBlocks)do if x>r[1]and x<r[2]and y>r[3]and y<r[4]then return false end end
  for _,r in ipairs(D.plazaBlocks)do if x>r[1]and x<r[2]and y>r[3]and y<r[4]then return false end end
  for _,p in ipairs(D.obstacles)do if(x-p[1])^2+(y-p[2])^2<p[3]^2 then return false end end
  return true
 end
 return baseWalk328(x,y)
end
local baseCamera328=Y.selectCamera
local lookup328={};for i,c in ipairs(D.cameras)do lookup328[c.name]=i end
local trailBands328={{'mata_entrada_alta',-23,-15.8},{'mata_meio_alta',-30,-23},{'mata_final_alta',-38.1,-30}}
local offsets328={{0,0},{-.2,0},{.2,0},{0,-.2},{0,.2}}
local function usable328(i,x,y,enter)
 local c=i and D.cameras[i];if not c or Y.clearance(c,x,y)<(enter and 16 or 8)then return false end
 if not sees(c,x,y)then return false end
 local n=0;for _,p in ipairs(offsets328)do if sees(c,x+p[1],y+p[2])then n=n+1 end end
 return n>=(enter and 5 or 1)
end
function Y.selectCamera(x,y,previous)
 if y> -15.8 or x<7.3 then return baseCamera328(x,y,previous)end
 local old=previous and D.cameras[previous];local oldname=old and old.name or ''
 local dx,dy=x-11.86,y+43.3;local interior=dx*dx+dy*dy<1.85^2 or(math.abs(dx)<.65 and dy>0 and dy<2.5)
 if oldname=='gazebo_interior'and dx*dx+dy*dy<2.8^2 then interior=true end
 if interior and usable328(lookup328.gazebo_interior,x,y,false)then return lookup328.gazebo_interior end
 if oldname=='praca_reserva_geral'and y> -39.4 and usable328(previous,x,y,false)then return previous end
 local preferred
 if y> -38.1 then
  if old then for _,b in ipairs(trailBands328)do if oldname==b[1]and y>b[2]-.9 and y<b[3]+.9 and usable328(previous,x,y,false)then return previous end end end
  for _,b in ipairs(trailBands328)do if y>=b[2]and y<b[3]then preferred=lookup328[b[1]] end end
 else
  preferred=lookup328[y< -45.3 and 'praca_geral_sul'or(x<11 and 'praca_geral_oeste'or'praca_geral_norte')]
  if oldname=='praca_geral_sul'and y< -44.3 and usable328(previous,x,y,false)then return previous end
  if oldname=='praca_geral_oeste'and x<12 and y> -46.3 and usable328(previous,x,y,false)then return previous end
  if oldname=='praca_geral_norte'and x>10 and y> -46.3 and usable328(previous,x,y,false)then return previous end
 end
 if usable328(preferred,x,y,true)then return preferred end
 if not(y< -35.5 and y> -38.1 and oldname=='mata_meio_alta')and oldname~='gazebo_interior'and(oldname:sub(1,5)=='mata_'or oldname:sub(1,6)=='praca_')and usable328(previous,x,y,false)then return previous end
 local names=y> -38.1 and {'mata_entrada_alta','mata_meio_alta','mata_final_alta','mata_reserva_entrada','mata_reserva_meio','mata_reserva_final','praca_geral_norte','praca_reserva_geral'}or{'praca_geral_norte','praca_geral_sul','praca_geral_oeste','praca_reserva_geral','mata_reserva_final'}
 if y< -35.5 and y> -38.1 and usable328(lookup328.praca_reserva_geral,x,y,false)then return lookup328.praca_reserva_geral end
 if y< -35.5 and y> -38.1 then names={'mata_final_alta','praca_geral_norte','praca_reserva_geral','mata_reserva_final'}end
 local best,score
 for _,name in ipairs(names)do local i=lookup328[name];local c=i and D.cameras[i];if c and sees(c,x,y)then local v=Y.clearance(c,x,y);if v>5 and(not score or v>score)then best,score=i,v end end end
 return best or preferred or previous or baseCamera328(x,y,previous)
end
local function safehole325(x,y)
 local inside=false;local poly=D.sinkhole
 for i,a in ipairs(poly)do local b=poly[i%#poly+1];local dx,dy=b[1]-a[1],b[2]-a[2];local t=math.max(0,math.min(1,((x-a[1])*dx+(y-a[2])*dy)/(dx*dx+dy*dy)))
 if(x-a[1]-t*dx)^2+(y-a[2]-t*dy)^2<.30^2 then return false end
 if (a[2]>y)~=(b[2]>y) and x<(b[1]-a[1])*(y-a[2])/(b[2]-a[2])+a[1]then inside=not inside end end
 return not inside
end
local function corridor323(x,y,route,r)
 for i=1,#route-1 do local a,b=route[i],route[i+1];local dx,dy=b[1]-a[1],b[2]-a[2];local t=math.max(0,math.min(1,((x-a[1])*dx+(y-a[2])*dy)/(dx*dx+dy*dy)));if(x-a[1]-t*dx)^2+(y-a[2]-t*dy)^2<r*r then return true end end
 return false
end
local oldWalk323=Y.walkable
function Y.walkable(x,y)
 if x<7.4 and y< -5.5 and y> -18 and not safehole325(x,y)then return false end
 local street=y< -5.5 and y> -73 and ((y> -17.6 and math.abs(x)<5.2)or corridor323(x,y,D.acacias,5.25))and safehole325(x,y)
 if street or corridor323(x,y,D.accessA,.96)or corridor323(x,y,D.accessB,.96)then
  for _,p in ipairs(D.obstacles or {})do if(x-p[1])^2+(y-p[2])^2<p[3]^2 then return false end end
  return true
 end
 return oldWalk323(x,y)
end
local oldSelect323=Y.selectCamera
local lookup323={};for i,c in ipairs(D.cameras)do lookup323[c.name]=i end
local bands326={{'acacias_norte',-19.5,0},{'acacias_transicao',-26,-19.5},{'acacias_meio',-36,-26},{'acacias_acesso',-47,-36},{'acacias_casas',-60,-47},{'acacias_sul',-67,-60},{'acacias_esquina',-74,-67}}
local offsets326={{0,0},{-.35,0},{.35,0},{0,-.35},{0,.35},{-.25,-.25},{.25,.25},{-.25,.25},{.25,-.25}}
local function usable326(c,x,y,enter)
 if not c or Y.clearance(c,x,y)<(enter and 16 or 9)then return false end
 local count=0
 for _,p in ipairs(offsets326)do if sees(c,x+p[1],y+p[2])then count=count+1 end end
 return count>=(enter and 8 or 1)
end
function Y.selectCamera(x,y,previous)
 local branch=x>19 and corridor323(x,y,D.accessB,1.2)
 if not((x<7.4 and y< -5.5)or branch)then return oldSelect323(x,y,previous)end
 local old=previous and D.cameras[previous]
 if not branch then
  -- Separate entrance and exit limits prevent a cut reversing at the same corner.
  if old then for _,b in ipairs(bands326)do if old.name==b[1]and y>b[2]-1.25 and y<b[3]+1.25 and usable326(old,x,y,false)then return previous end end end
  for _,b in ipairs(bands326)do local i=lookup323[b[1]];local c=i and D.cameras[i];if y>=b[2]and y<b[3]and usable326(c,x,y,true)then return i end end
 end
 if old and(old.name:sub(1,8)=='acacias_'or old.name=='cedros_acesso')and usable326(old,x,y,false)then return previous end
 local names=branch and {'cedros_acesso','praca_geral_norte','praca_geral_sul'}or{'acacias_norte','acacias_transicao','acacias_meio','acacias_acesso','acacias_casas','acacias_sul','acacias_esquina','acacias_reserva_norte','acacias_reserva_acesso','praca_geral_norte'}
 local best,score
 for _,name in ipairs(names)do local i=lookup323[name];local c=i and D.cameras[i];if c and sees(c,x,y)then local v=Y.clearance(c,x,y);if v>=5 and(not score or v>score)then best,score=i,v end end end
 return best or previous or lookup323.acacias_norte
end
local oldZone323=Y.zone
function Y.zone(x,y)
 if x<6 and y< -5.5 then return y< -67 and 'RUA DAS ACACIAS - esquina'or'RUA DAS ACACIAS'end
 if x>22.5 then return 'ACESSO B - RUA DOS CEDROS'end
 return oldZone323(x,y)
end
function Y.noticeAt(x,y)
 if x< -4 and math.abs(y+42)<2 then return 'O portao da casa 33 esta trancado.'end
 if x< -4 and math.abs(y+62)<2 then return 'O portao da casa 31 esta trancado.'end
 if y< -70 or x>29 then return 'Entulho bloqueia a passagem.'end
end
local walkBefore329=Y.walkable
local cars329={}
for _,c in ipairs(D.streetCars or {})do cars329[#cars329+1]={c[1],c[2],c[3],c[4],math.cos(c[5]),math.sin(c[5])}end
function Y.walkable(x,y)
 if y< -16 and y> -73 and x> -8 and x<8 then
  for _,c in ipairs(cars329)do local dx,dy=x-c[1],y-c[2];if math.abs(dx*c[5]+dy*c[6])<c[3]and math.abs(-dx*c[6]+dy*c[5])<c[4]then return false end end
 end
 if x>5.3 and x<25.4 and y< -15.4 and y> -50.4 then
  for _,r in ipairs(D.parkFence or {})do local dx,dy=r[3]-r[1],r[4]-r[2];local t=math.max(0,math.min(1,((x-r[1])*dx+(y-r[2])*dy)/(dx*dx+dy*dy)))
   if(x-r[1]-t*dx)^2+(y-r[2]-t*dy)^2<.21^2 then return false end
  end
 end
 return walkBefore329(x,y)
end
local before331=Y.walkable
function Y.walkable(x,y)
 if x< -5.3 and x> -6.0 and y< -12 and y> -72 then
  for _,r in ipairs(D.frontClosures or {})do local dx,dy=r[3]-r[1],r[4]-r[2];local t=math.max(0,math.min(1,((x-r[1])*dx+(y-r[2])*dy)/(dx*dx+dy*dy)))
   if(x-r[1]-t*dx)^2+(y-r[2]-t*dy)^2<.23^2 then return false end
  end
 end
 local b=D.brokenAccess
 if b and x>b[1]and x<b[2]and y>b[3]and y<b[4]then return true end
 if x> -8.8 and x< -7.7 and y> -62.5 and y< -54.8 then return true end
 local a=D.house31Access
 if a and x>a[1]and x<a[2]and y>a[3]and y<a[4]then return true end
 return before331(x,y)
end
local noticeBefore331=Y.noticeAt
function Y.noticeAt(x,y)
 if math.abs(y+62)<2 and x< -4 then
  if x< -8.0 and math.abs(y+62)<.8 then return 'Nao ha resposta.'end
  return nil
 end
 return noticeBefore331(x,y)
end
local clearings339={{13,-53},{13,-62.5},{14,-70}}
local walkBefore335=Y.walkable
local function corridor335(x,y)
 local route=D.parkSouthRoute
 for i=1,#route-3,3 do local a,b=route[i],route[i+3];local dx,dy=b[1]-a[1],b[2]-a[2];local t=math.max(0,math.min(1,((x-a[1])*dx+(y-a[2])*dy)/(dx*dx+dy*dy)))
 if(x-a[1]-t*dx)^2+(y-a[2]-t*dy)^2<1.95^2 then return true end end
 return false
end
function Y.walkable(x,y)
 if x>5.95 and x<24.75 and y< -48.6 then
  if y<= -73.12 then return false end
  local free=corridor335(x,y)or(y> -50.2 and x>7.3 and x<22.7)
  if not free then for _,p in ipairs(clearings339)do if(x-p[1])^2+(y-p[2])^2<9 then free=true;break end end end
  if not free then return false end
  for _,p in ipairs(D.obstacles)do if(x-p[1])^2+(y-p[2])^2<p[3]^2 then return false end end
  for i=math.max(1,#D.parkFence-3),#D.parkFence do local r=D.parkFence[i];local dx,dy=r[3]-r[1],r[4]-r[2];local t=math.max(0,math.min(1,((x-r[1])*dx+(y-r[2])*dy)/(dx*dx+dy*dy)));if(x-r[1]-t*dx)^2+(y-r[2]-t*dy)^2<.21^2 then return false end end
  return true
 end
 return walkBefore335(x,y)
end
local selectBefore335=Y.selectCamera
local shots335={};for i,c in ipairs(D.cameras)do shots335[c.name]=i end
local bands335={{'parque_sul_inicio',-56,-48.6},{'mata_sul_meio',-64,-56},{'mata_sul_final',-70,-64},{'parque_avenida',-73.2,-70}}
local function usable335(i,x,y,margin)return i and sees(D.cameras[i],x,y)and Y.clearance(D.cameras[i],x,y)>margin end
function Y.selectCamera(x,y,previous)
 if x<6 or x>25 or y> -48.6 then return selectBefore335(x,y,previous)end
 local old=previous and D.cameras[previous]
 local names=y> -56 and {'parque_sul_inicio','mata_sul_contra1','parque_sul_reserva1'}or(y> -64 and {'mata_sul_meio','mata_sul_contra2','parque_sul_reserva2'}or{'mata_sul_final','mata_sul_contra3','parque_sul_reserva3','parque_avenida'})
 if y> -52 then names[#names+1]='praca_geral_norte';names[#names+1]='praca_geral_sul';names[#names+1]='praca_reserva_geral'end
 local allowed={};for _,n in ipairs(names)do allowed[n]=true end
 if old then for _,b in ipairs(bands335)do if old.name==b[1]and y>b[2]-1 and y<b[3]+1 and usable335(previous,x,y,5)then return previous end end end
 if old and(old.name:sub(1,10)=='parque_sul'or old.name:sub(1,8)=='mata_sul'or old.name=='parque_avenida')and usable335(previous,x,y,5)then return previous end
 local preferred
 for _,b in ipairs(bands335)do if y>b[2]and y<=b[3]then preferred=shots335[b[1]]end end
 if usable335(preferred,x,y,10)then return preferred end
 if old and allowed[old.name]and usable335(previous,x,y,4)then return previous end
 local best,score
 for _,name in ipairs(names)do local i=shots335[name]
 if usable335(i,x,y,2)then local v=Y.clearance(D.cameras[i],x,y)+(i==preferred and 100 or 0);if not score or v>score then best,score=i,v end end end
 if not best then for name,i in pairs(shots335)do if(name:sub(1,10)=='parque_sul'or name:sub(1,8)=='mata_sul'or name=='parque_avenida')and usable335(i,x,y,2)then local v=Y.clearance(D.cameras[i],x,y);if not score or v>score then best,score=i,v end end end end
 return best or previous or preferred or 1
end
local zoneBefore335=Y.zone
function Y.zone(x,y)
 if x>6 and x<25 and y< -48.6 then return y< -69 and 'PARQUE - ACESSO A AVENIDA'or 'MATA DO PARQUE'end
 return zoneBefore335(x,y)
end

local function center337(x)
 local r=D.avenueRoute
 for i=1,#r-1 do local a,b=r[i],r[i+1];if x>=a[1]and x<=b[1]then return a[2]+(x-a[1])/(b[1]-a[1])*(b[2]-a[2])end end
 return x<r[1][1]and r[1][2]or r[#r][2]
end
local function safe337(x,y)
 local inside=false;local p=D.avenueHole
 for i,a in ipairs(p)do local b=p[i%#p+1];local dx,dy=b[1]-a[1],b[2]-a[2];local t=math.max(0,math.min(1,((x-a[1])*dx+(y-a[2])*dy)/(dx*dx+dy*dy)))
  if(x-a[1]-t*dx)^2+(y-a[2]-t*dy)^2<.34^2 then return false end
  if(a[2]>y)~=(b[2]>y)and x<(b[1]-a[1])*(y-a[2])/(b[2]-a[2])+a[1]then inside=not inside end
 end
 return not inside
end
local walkBefore337=Y.walkable
function Y.walkable(x,y)
 if y< -72.6 and x> -40 and x<19 then
  if not safe337(x,y)then return false end
  if x>5.7 and x<25 and y> -73.6 and not(x>12.7 and x<15.3)then return false end
  local free=(x> -37.1 and x<17.2 and math.abs(y-center337(x))<6.12)or(math.abs(x)<3.55 and y> -79.5)or(x>12.7 and x<15.3 and y> -75.5)or(x> -31 and x< -19 and y> -86 and y< -84)or(x> -17 and x< -6 and y> -86 and y< -84)
  if not free then return false end
  for _,b in ipairs(D.avenueBoxes)do if x>b[1]-.17 and x<b[2]+.17 and y>b[3]-.17 and y<b[4]+.17 then return false end end
  return true
 end
 return walkBefore337(x,y)
end
local cameraBefore337=Y.selectCamera
local shots337={};for i,c in ipairs(D.cameras)do if c.name:sub(1,8)=='avenida_'then shots337[c.name]=i end end
local function usable337(i,x,y,margin)return i and sees(D.cameras[i],x,y)and Y.clearance(D.cameras[i],x,y)>margin end
function Y.selectCamera(x,y,previous)
 if y> -72.65 or x< -40 or x>19 then return cameraBefore337(x,y,previous)end
 local name=x< -19 and 'avenida_mercado'or(x< -4 and 'avenida_farmacia'or(x<3 and 'avenida_juncao'or(x>11 and 'avenida_buraco_leste'or'avenida_buraco_oeste')))
 local old=previous and D.cameras[previous]
 if old and old.name==name and usable337(previous,x,y,6)then return previous end
 if y> -76 and x>11 then name='avenida_parque'end
 local preferred=shots337[name];if usable337(preferred,x,y,12)then return preferred end
 local best,score
 for _,i in pairs(shots337)do if usable337(i,x,y,2)then local v=Y.clearance(D.cameras[i],x,y);if not score or v>score then best,score=i,v end end end
 return best or previous or preferred or 1
end
local zoneBefore337=Y.zone
function Y.zone(x,y)
 if y< -72.6 and x<19 then return x< -19 and 'AVENIDA PRINCIPAL - CASA 31'or(x< -4 and 'AVENIDA PRINCIPAL - FARMACIA'or'AVENIDA PRINCIPAL - CASA 22')end
 return zoneBefore337(x,y)
end
local noticeBefore337=Y.noticeAt
function Y.noticeAt(x,y)
 if y< -72.6 then
  if x< -20 and x> -30 and y< -84 then return 'O mercadinho esta fechado.'end
  if x< -6 and x> -17 and y< -84 then return 'A persiana da farmacia esta abaixada.'end
  if x>2 and x<12 then return 'A rua cedeu. Nao consigo chegar aquela casa.'end
  if x< -35 or x>16 then return 'O entulho bloqueia a continuacao da avenida.'end
  return nil
 end
 return noticeBefore337(x,y)
end
-- Doorway views remain stable while approaching the facade; facing does not switch cameras.
local cameraBefore340=Y.selectCamera
local entrances340={}
for i,c in ipairs(D.cameras)do if c.name=='avenida_porta_mercado'then entrances340.market=i elseif c.name=='avenida_porta_farmacia'then entrances340.pharmacy=i end end
function Y.selectCamera(x,y,previous)
 local old=previous and D.cameras[previous];local oldname=old and old.name or ''
 local market=x> -29 and x< -21 and y< -80.7
 local pharmacy=x> -15.8 and x< -7 and y< -80.7
 if oldname=='avenida_porta_mercado'and x> -29.6 and x< -20.4 and y< -79.8 then market=true end
 if oldname=='avenida_porta_farmacia'and x> -16.4 and x< -6.4 and y< -79.8 then pharmacy=true end
 local preferred=market and entrances340.market or(pharmacy and entrances340.pharmacy)
 if preferred and sees(D.cameras[preferred],x,y)and Y.clearance(D.cameras[preferred],x,y)>5 then return preferred end
 if oldname=='avenida_porta_mercado'or oldname=='avenida_porta_farmacia'or oldname=='avenida_acesso_comercio'then previous=nil end
 return cameraBefore340(x,y,previous)
end

local oldCamera350=Y.selectCamera
local marketShots350={};for i,c in ipairs(D.cameras)do if c.marketCamera then marketShots350[c.name]=i end end
function Y.selectCamera(x,y,previous)
 local name=(x> -22.0 and x< -18.8 and y< -80.7 and y> -86.0)and 'mkt_servico'or((x> -28.5 and x< -22.0 and y< -80.6 and y> -86)and 'mkt_fachada')
 local i=name and marketShots350[name]
 if i and sees(D.cameras[i],x,y)and Y.clearance(D.cameras[i],x,y)>5 then return i end
 if previous and D.cameras[previous].marketCamera then previous=nil end
 return oldCamera350(x,y,previous)
end

-- Exact memoization: stationary camera queries do not rescan every view.
local choose339=Y.selectCamera
local mx339,my339,mp339,mr339,mo339,mh339
function Y.selectCamera(x,y,p)
 if x==mx339 and y==my339 and Y.opened==mo339 and Y.hits==mh339 and p==mp339 then return mr339 end
 local r=choose339(x,y,p);mx339,my339,mp339,mr339,mo339,mh339=x,y,p,r,Y.opened,Y.hits;return r
end

-- Close frontage view for the redesigned Casa33, with a small hold band.
local selectBeforeFacades352=Y.selectCamera
function Y.selectCamera(x,y,previous)
 local active=previous==56;local pad=active and .35 or 0
 if x< -2.6+pad and x> -5.45 and y> -46-pad and y< -38+pad and sees(D.cameras[56],x,y)and Y.clearance(D.cameras[56],x,y)>5 then return 56 end
 if active then previous=nil end
 return selectBeforeFacades352(x,y,previous)
end
local N=require('district_data355')
local beforeWalk355=Y.walkable
local function near355(x,y,pts,r)
 for i=1,#pts-1 do local a,b=pts[i],pts[i+1];local dx,dy=b[1]-a[1],b[2]-a[2];local t=math.max(0,math.min(1,((x-a[1])*dx+(y-a[2])*dy)/(dx*dx+dy*dy)));if(x-a[1]-t*dx)^2+(y-a[2]-t*dy)^2<r*r then return true end end
 return false
end
local function district355(x,y)
 return(x>26.5 and y< -5.2)or(x>24.1 and near355(x,y,N.bridge,1.1))or(x>17.1 and y< -73.0)
end
function Y.walkable(x,y)
 if not district355(x,y)then return beforeWalk355(x,y)end
 local c=N.circle;local g=N.gas
 local free=near355(x,y,N.cedros,5.04)or near355(x,y,N.avenue,6.05)or near355(x,y,N.bridge,1.02)or((x-c[1])^2+(y-c[2])^2<c[3]^2)or(x>g[1]and x<g[2]and y>g[3]and y<g[4])
 for _,r in ipairs(N.forecourts or{})do if x>r[1]and x<r[2]and y>r[3]and y<r[4]then free=true;break end end
 if not free or x>61 or y> -5.2 then return false end
 for _,b in ipairs(N.blocks)do if x>b[1]-.17 and x<b[2]+.17 and y>b[3]-.17 and y<b[4]+.17 then return false end end
 return true
end
local beforeCamera355=Y.selectCamera
local shots355={};for i,c in ipairs(D.cameras)do if c.district355 then shots355[#shots355+1]=i end end
function Y.selectCamera(x,y,previous)
 if not district355(x,y)then if previous and D.cameras[previous].district355 then previous=nil end;return beforeCamera355(x,y,previous)end
 local best,score;local old=previous and D.cameras[previous]
 if old and old.district355 and not old.reserve355 and sees(old,x,y)and Y.clearance(old,x,y)>17 then return previous end
 for _,i in ipairs(shots355)do local c=D.cameras[i];if sees(c,x,y)then local edge=Y.clearance(c,x,y);if edge>5 then local p=c.pos;local dist=(p[1]-x)^2+(p[2]-y)^2;local v=edge-dist*.18+(c.reserve355 and -500 or 300)+(i==previous and 24 or 0);if not score or v>score then best,score=i,v end end end end
 if best then return best end
 return beforeCamera355(x,y,nil)
end
local beforeZone355=Y.zone
function Y.zone(x,y)
 if not district355(x,y)then return beforeZone355(x,y)end
 if y< -84 and x>30 and x<46 then return 'POSTO DE GASOLINA - PROTOTIPO'end
 if y< -72 then return 'AVENIDA PRINCIPAL - LESTE'end
 if y< -60 and x>38 then return 'POSTO DE SAUDE - FACHADA'end
 return y> -18 and 'RUA DOS CEDROS - RETORNO'or'RUA DOS CEDROS'
end
local beforeNotice355=Y.noticeAt
function Y.noticeAt(x,y)
 if not district355(x,y)then return beforeNotice355(x,y)end
 if x>59 then return 'O entulho bloqueia a continuacao da avenida.'end
 if x>38 and y< -62 and y> -68 then return 'O posto de saude esta fechado. Preciso encontrar outra entrada.'end
 if y< -85 then return 'A porta esta trancada. Interior ainda em preparacao.'end
 if x<29.4 or x>38.2 then return 'O portao esta trancado.'end
 return nil
end
-- Cache exact stationary queries without changing cuts while moving.
local select355=Y.selectCamera
local qx355,qy355,qp355,qo355,qr355
function Y.selectCamera(x,y,p)
 if x==qx355 and y==qy355 and p==qp355 and Y.opened==qo355 then return qr355 end
 local r=select355(x,y,p);qx355,qy355,qp355,qo355,qr355=x,y,p,Y.opened,r;return r
end

local cinema=require('cinema356')
local cameraZones374=require('camera_zones374')
function Y.selectCamera(x,y,previous)
 local shot=cameraZones374.select(D.cameras,cinema,x,y,previous)
 -- No unrelated global camera is eligible after entering this exterior scene.
 return shot or previous or 1
end
Y.cameraZones=cameraZones374

local previousWalk364=Y.walkable
function Y.walkable(x,y)
 -- Exchanged lots: market frontage at former Casa31; Casa31 faces the avenue.
 if x> -19 and x< -5.4 and y> -66.5 and y< -52.4 then
  if math.abs(x+5.65)<.25 and math.abs(y+55.8)>.65 then return false end
  return x> -9.0 and x< -5.4 and y> -65.8 and y< -52.8
 end
 if x> -31.2 and x< -18.8 and y> -96 and y< -84.2 then
  return y> -84.95 or(x< -27.32 and x> -29.35 and y> -94.7)
 end
 return previousWalk364(x,y)
end
local previousNotice364=Y.noticeAt
function Y.noticeAt(x,y)
 if (x+27.8)^2+(y+86.65)^2<1.2 then return 'A parede cedeu. Posso entrar por aqui.'end
 return previousNotice364(x,y)
end
local previousZone364=Y.zone
function Y.zone(x,y)
 if x< -5.4 and x> -19 and y< -52.4 and y> -66.5 then return 'MERCADINHO - RUA DAS ACACIAS'end
 if x< -18.8 and y< -84.2 then return 'CASA 31 - SOBRADO'end
 return previousZone364(x,y)
end

return Y
