LEFT,RIGHT,UP,DOWN=0,1,2,3
package.preload.sprites=function()return dofile('.tools/sprites168.lua')end
package.preload.palette=function()return dofile('.tools/palette142.lua')end
ui={cls=function()end,btn=function()return false end,stat=function()return 60 end,palset=function()end,print=function()end,rectfill=function()end,rect=function()end,line=function()end,trisfill=function()end,spr=function()end}
dofile('game.lua')
local function set(k,v)for i=1,100 do if debug.getupvalue(update,i)==k then debug.setupvalue(update,i,v);return end end;error(k)end
local L=require('survival158');local E=require('enemy153');local M=require('metric_rooms')
assert(L.hitClip.count==9 and #L.hitClip.data==9*408*3 and #L.hitClip.sockets==9)
set('titleOpen',false);set('currentRoom','frente');E.enabled=false
L.damage();assert(L.hitTime==0 and L.hp==3);update();assert(L.hitTime>0 and L.hitTime<.1)
for i=1,60 do update()end;assert(L.hitTime==nil)
L.damage();L.damage();L.damage();assert(L.dead and not L.hitTime);update()
L.reset();E.reset();E.cooldown=0
E.tick(1/60,'frente',E.x,E.y-1.1);assert(not E.attackTime,'starts too far')
E.tick(1/60,'frente',E.x,E.y-.9);assert(E.attackTime)
E.attackTime=E.attackImpact-.01;E.attackHit=false;E.angle=0
E.tick(.02,'frente',E.x,E.y-1.08);assert(L.hp==4,'air hit')
E.attackTime=E.attackImpact-.01;E.attackHit=false
E.tick(.02,'frente',E.x,E.y-.9);assert(L.hp==3 and L.hitTime==0)
print('PASS cropped hit, sockets, reaction recovery, death priority, close attack and distant miss')
