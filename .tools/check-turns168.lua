LEFT,RIGHT,UP,DOWN=0,1,2,3
package.preload.sprites=function()return dofile('.tools/sprites168.lua')end
package.preload.palette=function()return dofile('.tools/palette142.lua')end
local keys={}
ui={cls=function()end,btn=function(i)return keys[i]or false end,stat=function()return 60 end,palset=function()end,print=function()end,rectfill=function()end,rect=function()end,line=function()end,trisfill=function()end,spr=function()end}
dofile('game.lua')
local function up(fn,k)for i=1,100 do local n,v=debug.getupvalue(fn,i);if n==k then return v,i end end;error(k)end
local function get(k)return up(update,k)end
local function set(k,v)local _,i=get(k);debug.setupvalue(update,i,v)end
local M=require('metric_rooms');local T=require('turn168');local D=require('turn_data168');local E=require('enemy153');E.enabled=false
set('titleOpen',false);set('currentRoom','sala');local x,y=M.project('sala',3.15,1.15,0);set('x',x);set('y',y)
local courier=get('courier');local function cache()return up(courier,'courierCache')end
for _,clip in ipairs({D.left,D.right})do assert(#clip.data==clip.count*408*3 and #clip.sockets==clip.count);assert(clip.progress[1]==0 and clip.progress[clip.count]==1)end
local total=#D.left.data+#D.right.data;assert(total==41616)
for _,dir in ipairs({-1,1})do
 keys={[dir<0 and LEFT or RIGHT]=true};local before=get('facing');update()
 assert(T.direction==dir and cache().clip==(dir<0 and D.left or D.right),'turn clip not called')
 assert(get('x')==x and get('y')==y,'turn displaced actor')
 local delta=math.atan(math.sin(get('facing')-before),math.cos(get('facing')-before));assert(math.abs(delta-dir*3.2/60)<1e-8,'turn speed changed')
 local expected=get('facing');for i=1,240 do update();expected=(expected+dir*3.2/60)%(2*math.pi)end
 assert(math.abs(math.atan(math.sin(get('facing')-expected),math.cos(get('facing')-expected)))<1e-8)
 assert(T.position>=0 and T.position<=cache().clip.count-1)
 keys={};update();assert(T.direction==0,'turn remains active after release')
end
keys={[UP]=true,[RIGHT]=true};update();assert(get('walking')and T.direction==0,'turn overrides walking')
keys={[UP]=true,[RIGHT]=true,[12]=true};update();assert(get('running')and T.direction==0,'turn overrides running')
keys={[15]=true,[RIGHT]=true};update();assert(get('aiming')and T.direction==0,'turn overrides guard')
keys={};update();get('inventory').equipped='crowbar';keys={[LEFT]=true};update();assert(cache().clip==D.left)
require('survival158').damage();update();assert(T.direction==0 and cache().clip==require('survival158').hitClip,'turn overrides hit')
print('PASS exact source mesh, L/R clips render, unchanged 3.2 rad/s steering, zero displacement, wrap/release and walk/run/guard/hit priorities; 41616 pose bytes')
