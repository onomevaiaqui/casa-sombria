LEFT,RIGHT,UP,DOWN=0,1,2,3
package.preload.sprites=function()return dofile('.tools/sprites168.lua')end
package.preload.palette=function()return dofile('.tools/palette142.lua')end
local keys={}
ui={cls=function()end,btn=function(i)return keys[i]or false end,stat=function()return 60 end,palset=function()end,print=function()end,rectfill=function()end,rect=function()end,line=function()end,trisfill=function()end,spr=function()end}
dofile('game.lua')
local function get(k)for i=1,100 do local n,v=debug.getupvalue(update,i);if n==k then return v,i end end;error(k)end
local function set(k,v)local _,i=get(k);debug.setupvalue(update,i,v)end
local P=require('progression167');local D=require('doors131');local E=require('enemy153');local M=require('metric_rooms');local L=require('layout140')
local function place(room,x,y)set('titleOpen',false);set('currentRoom',room);local sx,sy=M.project(room,x,y,0);set('x',sx);set('y',sy);set('crossing',false);keys={};update()end
local function confirm()keys={[BTN_Z or 4]=true};update();keys={}end
D.reset();E.reset();assert(P.message('entrada','sala',E,D):find('me defender'))
place('sala',3.3,.65);confirm();assert(not D.isOpen('entrada'),'front door unlocked while enemy alive')
get('dialogue').active=false
place('corredor',1.2,.6);confirm();assert(not D.isOpen('garagem'),'corridor opened one-way garage door')
assert(P.message('garagem','corredor',E,D)=='Parece estar trancada pelo outro lado.')
get('dialogue').active=false
assert(D.blocked('garagem','frente')and D.blocked('frente','garagem'))
local ext=D.nearby('frente',14.4,5.2);assert(ext and ext.id=='garagem_externa')
assert(P.message('garagem_externa','frente',E,D))
-- Interior door can only be unlatched from the garage side.
place('garagem',1.2,5.1);confirm();assert(D.isOpen('garagem'))
get('dialogue').active=false
-- Three hatchet hits defeat the enemy; owning a weapon alone does not release the entrance.
get('inventory').equipped='crowbar';assert(P.blockedPassage('sala','area',E))
E.reset();local px,py=E.x,E.y+1;local facing=M.facing('frente',E.x-px,E.y-py)
for i=1,3 do assert(E.tryHit('frente',px,py,facing,true));assert(P.defeated(E)==(i==3))end
assert(not P.message('entrada','sala',E,D)and not P.blockedPassage('sala','area',E))
D.reset();place('sala',3.3,.65);confirm();assert(D.isOpen('entrada'),'defeated enemy did not release front door')
-- No exterior item is invented/spawned. Future puzzle explicitly releases shutter.
D.reset();P.releaseGarage(D);assert(not D.blocked('frente','garagem')and not D.blocked('garagem','frente'))
D.reset();assert(D.blocked('frente','garagem'),'new game retained garage release')
D.open('cozinha_quintal');D.open('jardim_quintal');assert(not D.blocked('cozinha','quintal')and not D.blocked('quintal','frente'),'combat approach softlocked')
print('PASS front door until 3 hatchet hits, garage inner latch by garage side, outer shutter locked both ways, exterior release/reset and backyard combat route')
