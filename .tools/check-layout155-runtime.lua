LEFT,RIGHT,UP,DOWN=0,1,2,3
local keys={}
local sprites={};for room in pairs(require('layout140').rooms)do local views=require('camera_data155')[room]; for _,c in ipairs(views)do for _,v in pairs(c.states)do for i=0,2 do sprites[v.prefix..'_'..i]=true end end end end
for _,name in ipairs({'sala75','cozinha76','corredor100','banheiro100','quarto100','garagem100','quintal100','frente100','titulo103'})do
 for i=0,2 do sprites[name..'_'..i]=name..i end
end
package.preload.sprites=function()return sprites end
package.preload.palette=function()return {0,1}end
ui={cls=function()end,btn=function(i)return keys[i] or false end,palset=function()end,
 print=function()end,rectfill=function()end,rect=function()end,line=function()end,trisfill=function()end,spr=function()end}
dofile('game.lua')

local function find(fn,key)for i=1,100 do local name,v=debug.getupvalue(fn,i);if name==key then return v,i end end;error(key)end
local function set(k,v)local _,i=find(update,k);debug.setupvalue(update,i,v)end
local M=require('metric_rooms');local D=require('doors131');local C=require('cameras155');local L=require('layout140');local master={0};for _,p in ipairs(M.bank)do master[#master+1]=p[1]end;C.setup(sprites,master)
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
dialogue:close();inv.bag[#inv.bag+1]='shed_key';keys={};update();keys={[4]=true};update();assert(D.isOpen('casinha'),'B did not unlock shed with key')
dialogue:close();set('currentRoom','ferramentas');local sx,sy=M.project('ferramentas',1.5,1.95,0);set('x',sx);set('y',sy);set('crossing',false);set('transitionCarry',nil)
keys={};update();keys={[4]=true};update();assert(inv:has('crowbar')and inv.collected.crowbar,'B did not collect the first weapon inside shed')
print('PASS real B padlock rejection, key unlock, new room drawing and crowbar collection')
