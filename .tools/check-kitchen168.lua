LEFT,RIGHT,UP,DOWN=0,1,2,3
local keys={}
local sprites=dofile('.tools/sprites168.lua')
for _,name in ipairs({'sala75','cozinha76','corredor100','banheiro100','quarto100','garagem100','quintal100','frente100','titulo103'})do
 for i=0,2 do sprites[name..'_'..i]=name..i end
end
for i=0,2 do sprites['lock158_'..i]=true end
package.preload.sprites=function()return sprites end
package.preload.palette=function()return {0,1}end
ui={cls=function()end,btn=function(i)return keys[i] or false end,palset=function()end,
 print=function()end,rectfill=function()end,rect=function()end,line=function()end,trisfill=function()end,spr=function()end}
dofile('game.lua')

local function find(fn,key)for i=1,100 do local name,v=debug.getupvalue(fn,i);if name==key then return v,i end end;error(key)end
local function set(k,v)local _,i=find(update,k);debug.setupvalue(update,i,v)end
local M=require('metric_rooms');local D=require('doors131');local C=require('cameras168');local L=require('layout140');local master={0};for _,p in ipairs(M.bank)do master[#master+1]=p[1]end;C.setup(sprites,master)
local passage=find(update,'checkPassage');local count=0
for room,exits in pairs(L.exits)do for _,e in ipairs(exits)do
 D.reset();for _,door in ipairs(D.list)do D.open(door.id)end
 local w=e.world;local gx,gy=(w[1]+w[2])/2,(w[3]+w[4])/2;local sx,sy=M.project(room,gx,gy,0)
 set('titleOpen',false);set('currentRoom',room);set('x',sx);set('y',sy);set('crossing',false);set('transitionCarry',nil)
 local t=e.transfer;local xx,yy=M.project(room,gx+t.awayX*.1,gy+t.awayY*.1,0)
 passage(xx-sx,yy-sy,1,0)
 assert(find(update,'currentRoom')==e.to,room..' transition failed '..e.to)
 count=count+1
end end
D.reset();set('currentRoom','corredor');local sx,sy=M.project('corredor',.65,1,0);set('x',sx);set('y',sy);set('titleOpen',false)
keys={};update();keys={[4]=true};update();assert(D.isOpen('corredor'),'B did not open corridor door')
keys={};update()
print('PASS real game loop: '..count..' transitions and corridor B action')


D.reset();set('currentRoom','frente');local sx,sy=M.project('frente',4.8,8.0,0);set('x',sx);set('y',sy);set('titleOpen',false)
keys={};update();keys={[4]=true};update();assert(D.isOpen('jardim_quintal'),'B did not open garden gate');keys={};update()
print('PASS actual B action opens garden gate')

D.reset();local e
for _,v in ipairs(L.exits.frente)do if v.to=='quintal'then e=v end end
local w=e.world;local gx,gy=(w[1]+w[2])/2,(w[3]+w[4])/2;local sx,sy=M.project('frente',gx,gy,0)
set('currentRoom','frente');set('x',sx);set('y',sy);set('crossing',false);set('transitionCarry',nil)
local xx,yy=M.project('frente',gx,gy+.1,0);passage(xx-sx,yy-sy,1,0)
assert(find(update,'currentRoom')=='frente','closed gate allowed passage')
assert(find(update,'roomNotice')=='B: ABRIR PORTAO','wrong closed gate notice')
print('PASS closed gate prevents passage and reports its action')

local inv=find(update,'inventory');local dialogue=find(update,'dialogue');inv:reset();D.reset();dialogue:close()
set('currentRoom','quintal');local sx,sy=M.project('quintal',1.8,5.85,0);set('x',sx);set('y',sy);set('crossing',false);set('transitionCarry',nil)
keys={};update();keys={[4]=true};update();assert(not D.isOpen('casinha'),'B bypassed the padlock without key')
local lock=find(update,'codeLock');assert(lock.active,'B did not open lock UI')
keys={};update();keys={[4]=true};update();assert(lock.active and not D.isOpen('casinha'),'wrong code accepted')
local function tap(k)keys={};update();keys={[k]=true};update()end
local oldx=find(update,'x');tap(2);tap(2);tap(1);tap(1);tap(2);tap(1);tap(3)
assert(table.concat(lock.digits)=='2019',table.concat(lock.digits));assert(find(update,'x')==oldx,'player moved during puzzle')
tap(4);assert(D.isOpen('casinha')and not lock.active,'correct code failed')
dialogue:close();set('currentRoom','ferramentas');local sx,sy=M.project('ferramentas',1.30,1.72,0);set('x',sx);set('y',sy);set('crossing',false);set('transitionCarry',nil)
keys={};update();keys={[4]=true};update();assert(inv:has('crowbar')and inv.collected.crowbar,'B did not collect crowbar')
inv.equipped='crowbar';keys={};update()
print('PASS real puzzle input, frozen player, 2019 unlock, crowbar pickup/equip/render')

local function get(fn,key)for i=1,100 do local n,v=debug.getupvalue(fn,i);if n==key then return v end end;error(key)end
local G=require('combat164');local W=require('crowbar160');local clips={punch={},guard={}}
assert(G.attack(clips,nil)==clips.punch and G.attack(clips,'phone')==clips.punch)
assert(G.attack(clips,'crowbar')==G.swing and G.attack(clips,'bat')==G.swing)
assert(G.swing.count==29 and #G.swing.data==29*408*3)
local referenceDistance
for _,name in ipairs({'idle','walk','run','punch','guard','baseball','swing'})do
 for step=0,(name=='swing'and 580 or 10)do
  local socket=G.socket(name,step/10);local points={}
  W.held(function(x,y,z)points[#points+1]={x,y,z};return{x,y,z+10}end,socket,{})
  local a,b=points[1],points[80];local distance=math.sqrt((a[1]-b[1])^2+(a[2]-b[2])^2+(a[3]-b[3])^2)
  referenceDistance=referenceDistance or distance;assert(math.abs(distance-referenceDistance)<.00001,'weapon stretched')
  local nearest=1e9;for _,p in ipairs(points)do nearest=math.min(nearest,math.sqrt((p[1]-socket[1])^2+(p[2]-socket[2])^2+(p[3]-socket[3])^2))end
  assert(nearest<.05,'grip detached from palm: '..nearest)
 end
end
local keys={};ui.btn=function(i)return keys[i]or false end
local inv=get(update,'inventory');inv.visible=false;get(update,'dialogue'):close()
local seen;local original=G.attack;G.attack=function(c,id)local result=original(c,id);seen=result;return result end
for _,id in ipairs({'crowbar','bat','phone'})do
 keys={};update();inv.equipped=id;keys={[15]=true};update();keys={[15]=true,[12]=true};update()
 assert(get(update,'strike')==1);assert((seen==G.swing)==(id~='phone'),'wrong attack rendered')
 for i=1,180 do update()end
 assert(get(update,'strike')==0,'held Y repeated attack or recovery never ended')
end
G.attack=original
print('PASS source bat-only clip, unarmed punch, armed swing, stable palm attachment and rigid weapon, recovery, no held-Y repeats')

local clips={idle={},guard={}};assert(G.guard(clips,'crowbar')==G.ready and G.ready.count==1)
local function vertex(clip,frame,index,k)local n=frame*408*3+index*3+k;return clip.low[k]+clip.data:byte(n)/255*clip.span[k]end
for i=0,407 do for k=1,3 do
 local v=vertex(G.ready,0,i,k)
 assert(math.abs(v-vertex(G.swing,0,i,k))<.008,'attack does not start in ready pose')
 assert(math.abs(v-vertex(G.swing,28,i,k))<.008,'attack does not return directly to ready pose')
end end
keys={};update();inv.equipped='crowbar';keys={[15]=true};update();keys={[15]=true,[12]=true};update();keys={[15]=true}
while get(update,'strike')<G.swing.count-7 do update()end
keys={[15]=true,[12]=true};update();keys={[15]=true};local chained=false
for i=1,15 do local previous=get(update,'strike');update();if get(update,'strike')<previous and get(update,'strike')>0 then chained=true;break end end
assert(chained,'late Y press was lost')
keys={};update();assert(get(update,'strike')==0,'release R did not cancel')
print('PASS prepared guard, 0.64s strike, direct recovery to guard, late-input chain, no auto-repeat')
local layout=require('layout140');assert(#layout.rooms.cozinha.boxes==10)
for _,b in ipairs(layout.rooms.cozinha.boxes)do assert(not M.walkable('cozinha',(b[1]+b[2])/2,(b[3]+b[4])/2),'new furniture has no collision')end
print('PASS 10 kitchen furniture collision boxes, including 3 chairs')
