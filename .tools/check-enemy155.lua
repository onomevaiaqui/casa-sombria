LEFT,RIGHT,UP,DOWN=0,1,2,3
package.preload.sprites=function()return dofile('.tools/sprites168.lua')end
package.preload.palette=function()return dofile('.tools/palette142.lua')end
local writes=0
local keys={}
ui={cls=function()end,btn=function(i)return keys[i]or false end,stat=function()return 60 end,
 palset=function()writes=writes+1 end,print=function()end,rectfill=function()end,rect=function()end,line=function()end,spr=function()end,trisfill=function()end}
dofile('game.lua')
local function get(key)for i=1,100 do local n,v=debug.getupvalue(update,i);if n==key then return v,i end end;error(key)end
local _,index=get('titleOpen');debug.setupvalue(update,index,false);get('inventory').equipped='crowbar'
local function set(k,v)local _,i=get(k);debug.setupvalue(update,i,v)end
local M=require('metric_rooms');local E=require('enemy153');set('currentRoom','frente');local sx,sy=M.project('frente',8.6,3.8,0);set('x',sx);set('y',sy)
for i=1,30 do update()end
collectgarbage('collect');local low=collectgarbage('count');local peak=low
for i=1,10000 do
 keys={[15]=true,[12]=(i%45==1)};update()
 peak=math.max(peak,collectgarbage('count'))
end
collectgarbage('collect');local after=collectgarbage('count')
assert(after<low+128,'combat retains memory: '..(after-low))
assert(peak<4096,'Lua heap exceeds stress budget: '..peak)
print(string.format('PASS 10000 combat updates, GC active: peak %.1f KB, retained growth %.1f KB',peak,after-low))

local E=require('enemy153');local D=require('enemy_data155');assert(E.drawn>0,'enemy not visible outside')
local walkable=get('walkable');local radius=E.radius+.25
for i=0,359 do
 local a=i*math.pi/180
 for _,delta in ipairs({-.01,.01})do
  local gx,gy=E.x+math.cos(a)*(radius+delta),E.y+math.sin(a)*(radius+delta)
  local x,y=M.project('frente',gx,gy,0)
  assert(E.walkable('frente',gx,gy)==(delta>0),'radial boundary')
  if delta<0 then assert(not walkable(x,y),'player callback bypasses enemy')end
 end
end
assert(E.walkable('sala',E.x,E.y),'collision leaks into another room')
E.enabled=false;assert(E.walkable('frente',E.x,E.y));E.enabled=true
local P=require('perspective');local stop=radius+.5
for angle=0,7 do
 local a=angle*math.pi/4;local gx,gy=E.x+math.cos(a)*stop,E.y+math.sin(a)*stop
 local x,y=M.project('frente',gx,gy,0);local tx,ty=M.project('frente',E.x,E.y,0)
 local dx,dy=tx-x,ty-y;local n=math.sqrt(dx*dx+dy*dy)
 for i=1,60 do
  x,y=P.move('frente',x,y,dx/n,dy/n,1/15,true,walkable,true)
  local px,py=M.ground('frente',x,y)
  assert((px-E.x)^2+(py-E.y)^2>=radius^2-1e-8,'run tunnels into enemy')
 end
end
assert(math.abs(E.scale*1.8-1.65)<1e-9)
print('PASS 720 collision boundary probes, 8 running approaches, room isolation and 1.65 m scale')

local D=require('enemy_data155');assert(#D.triangles==802*7 and D.vertices==438)
for _,clip in pairs(D.clips)do assert(#clip.data==clip.count*D.vertices*3)end
local slots={};E.palette({palset=function(i,c)assert(not slots[i]);slots[i]=c;assert(i>=205 and i<=223 and(i<216 or i>218))end})
local px,py=E.x,E.y-1;local facing=M.facing(E.room,E.x-px,E.y-py)
assert(not E.tryHit('sala',px,py,facing,true));assert(not E.tryHit(E.room,px,py,facing+math.pi,true));assert(not E.tryHit(E.room,E.x,E.y-3,facing,true))
assert(E.hp==2)
E.tick(.01,E.room,px,py);assert(E.attackTime~=nil,'enemy does not attack nearby player')
assert(E.tryHit(E.room,px,py,facing,true));assert(E.hp==1 and E.state=='alive')
assert(E.tryHit(E.room,px,py,facing,true));assert(E.hp==0 and E.state=='dying'and E.attackTime==nil)
assert(not E.tryHit(E.room,px,py,facing,true),'dead target takes damage')
E.tick(10,E.room,px,py);assert(E.state=='dead'and E.time==D.clips.death.duration)
assert(E.walkable(E.room,E.x,E.y),'corpse still blocks path')
local t=E.time;E.tick(10,E.room,px,py);assert(E.time==t,'death animation loops')
E.toggle();E.toggle();assert(E.hp==2 and E.state=='alive')
-- Exercise actual R+Y input, impact timing and once-per-swing latch.
set('facing',facing);local x,y=M.project(E.room,px,py,0);set('x',x);set('y',y);set('currentRoom',E.room)
keys={};update();keys={[15]=true,[12]=true};update();keys={[15]=true}
for i=1,50 do update()end
assert(E.hp==1,'one player swing must deal exactly one hit')
for i=1,100 do update()end
assert(E.hp==1,'held guard repeats damage')
keys={[15]=true,[12]=true};update();keys={[15]=true}
for i=1,160 do update()end
assert(E.hp==0 and E.state=='dying'or E.state=='dead','second swing must start death')
print('PASS 16 palette slots, 3 clips, attack proximity, reach/facing checks, actual two swings, non-looping death and respawn')
