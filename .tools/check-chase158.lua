LEFT,RIGHT,UP,DOWN=0,1,2,3
package.preload.sprites=function()return dofile('.tools/sprites168.lua')end
package.preload.palette=function()return dofile('.tools/palette142.lua')end
local keys={}
ui={cls=function()end,btn=function(i)return keys[i]or false end,stat=function()return 60 end,palset=function()end,print=function()end,rectfill=function()end,rect=function()end,line=function()end,trisfill=function()end,spr=function()end}
dofile('game.lua')
local function get(k)for i=1,100 do local n,v=debug.getupvalue(update,i);if n==k then return v,i end end;error(k)end
local function set(k,v)local _,i=get(k);debug.setupvalue(update,i,v)end
local E=require('enemy153');local L=require('survival158');local N=require('chase_nav158');local M=require('metric_rooms');local C=require('cameras168')
local D=require('enemy_data155');assert(D.clips.run.count==11 and L.clip.count==30)
assert(#L.clip.data==30*408*3)
L.reset();E.reset();assert(L.hp==4 and E.hp==5)
local hits=0
for i=1,3000 do
 E.tick(1/30,'frente',10,3)
 assert(N.canStand(E.x,E.y),'NPC intersects static obstacle')
 assert(N.inArea('frente',E.x,E.y),'NPC leaves front area')
 if L.dead then break end
end
assert((E.x-10)^2+(E.y-3)^2<1.4^2,'NPC cannot chase across front garden')
assert(L.hp==0 and L.dead,'four enemy attacks must kill player')
E.tick(10,'frente',10,3);assert(L.hp==0,'damage below zero')
L.tick(20);assert(L.time==L.clip.duration,'player death must clamp at final frame')
assert(L.input(false,false)==nil);assert(L.input(false,true)=='retry')
for _,room in ipairs({'sala','garagem','quintal','area','cozinha'})do
 L.reset();E.reset();E.x,E.y=10,3
 for i=1,500 do E.tick(1/30,room,6.5,4.4);assert(L.hp==4);assert(E.attackTime==nil);assert(N.canStand(E.x,E.y))end
 assert((E.x-6.45)^2+(E.y-4.45)^2<.4^2,'NPC does not return home after player leaves')
end
assert(not N.inArea('frente',9,-1));assert(not N.canStand(4.8,8.5),'rear gate not excluded')
-- Going around the central tree requires an actual route, not straight-line chasing.
L.reset();E.reset();E.x,E.y=6.3,5.2
for i=1,400 do E.tick(1/60,'frente',8.5,5.2);assert(N.canStand(E.x,E.y),'tree collision')end
assert((E.x-8.5)^2+(E.y-5.2)^2<1.5^2,'NPC stuck at tree')
-- One hit at the attack animation's impact, with dodging and room escape.
L.reset();E.reset();local px,py=E.x,E.y-1;E.cooldown=0
E.tick(.01,'frente',px,py);assert(E.attackTime~=nil)
local impact=E.attackImpact/E.attackRate+1e-6
E.tick(impact,'frente',px,py);assert(L.hp==3)
E.tick(.1,'frente',px,py);assert(L.hp==3,'one attack deals multiple damage')
L.reset();E.reset();E.cooldown=0;E.tick(.01,'frente',px,py);E.tick(impact,'frente',px,py-4);assert(L.hp==4,'dodged attack still hits')
E.reset();E.cooldown=0;E.tick(.01,'frente',px,py);E.tick(impact,'garagem',px,py);assert(L.hp==4,'attack crosses room boundary')
-- Five valid player hits, not four, and no hits after death starts.
L.reset();E.reset();local angle=M.facing('frente',0,1)
for i=1,5 do assert(E.tryHit('frente',E.x,E.y-1,angle,true));assert(E.hp==5-i)end
assert(E.state=='dying');assert(not E.tryHit('frente',E.x,E.y-1,angle,true))
E.tick(10,'frente',px,py);assert(E.state=='dead'and E.walkable('frente',E.x,E.y))
-- Exercise the player's actual death-rendering path with the equipped weapon.
set('titleOpen',false);set('currentRoom','frente');local x,y=M.project('frente',9.7,3.2,0);set('x',x);set('y',y);get('inventory').equipped='crowbar'
L.reset();E.reset();for i=1,4 do assert(L.damage())end
local originalX,originalY=get('x'),get('y');keys={[2]=true,[12]=true}
for i=1,400 do update()end
assert(get('x')==originalX and get('y')==originalY,'dead player can move')
assert(L.time==L.clip.duration and L.dead)
keys={};update();keys={[4]=true};update();assert(L.hp==4 and not L.dead and E.hp==5,'retry does not reset survival state')
print('PASS chase/obstacles/front territory, safe rooms and return, 4 player HP, dodge/one-impact attacks, 5 enemy HP, player death/input lock/retry')
