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

-- Source FBX winding must be retained; swapping b/c renders the back of the mesh.
local function up(f,k)for i=1,100 do local n,v=debug.getupvalue(f,i);if n==k then return v end end;error(k)end
local triangles=up(E.draw,'triangles')
for i=1,#D.triangles,7 do
 local a,b,c,d,e,f=D.triangles:byte(i,i+5);local j=(i-1)/7*4+1
 assert(triangles[j]==a+b*256+1 and triangles[j+1]==c+d*256+1 and triangles[j+2]==e+f*256+1,'source face winding reversed')
end
L.reset();E.reset();E.cooldown=0
local px,py=E.x,E.y-1
E.tick(1/60,'frente',px,py);assert(E.attackTime~=nil)
local elapsed=0
while L.hp==4 and elapsed<1 do E.tick(1/60,'frente',px,py);elapsed=elapsed+1/60 end
assert(L.hp==3 and elapsed<=.56,'attack remains slow')
local since=0
while L.hp==3 and since<2 do E.tick(1/60,'frente',px,py);since=since+1/60 end
assert(L.hp==2 and since<1.6,'attack recovery too long')
assert(L.clip.sourceFirst==76 and L.clip.sourceLast==148 and L.clip.duration==2.4,'death retains idle lead-in')
-- Lethal enemy impact and death pose must happen in the very same update.
L.reset();E.reset();for i=1,3 do L.damage()end
set('titleOpen',false);set('currentRoom','frente');px,py=E.x,E.y-1
local sx,sy=M.project('frente',px,py,0);set('x',sx);set('y',sy)
E.attackTime=E.attackImpact-1/60*E.attackRate*.5;E.attackHit=false;E.angle=0
update();assert(L.dead and L.hp==0 and L.time==0,'lethal hit delayed')
local courier=get('courier');local cache=up(courier,'courierCache')
assert(cache.clip==L.clip and cache.position==0,'death not rendered on lethal frame')
assert(require('combat164').stable(),'death still blends with live pose')
print(string.format('PASS front face winding, impact %.3f s, next impact %.3f s, trimmed death and same-update death pose',elapsed,since))
