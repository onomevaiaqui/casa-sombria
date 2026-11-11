LEFT,RIGHT,UP,DOWN=0,1,2,3
BTN_Z,BTN_F,BTN_G,BTN_E=4,12,13,15
local refs=dofile('.tools/sprites196.lua');package.preload.sprites=function()return refs end;package.preload.palette=function()return dofile('.tools/palette142.lua')end
local keys={};local draws=0
ui={btn=function(i)return keys[i]or false end,stat=function(i)if i==0 then return collectgarbage('count')*1024 elseif i==7 then return 60 end end,cls=function()end,palset=function(i,v)assert(i>=0 and i<256 and v>=0 and v<=32767)end,print=function()end,rectfill=function()end,rect=function()end,line=function()end,trisfill=function()draws=draws+1 end,spr=function(ref)assert(ref,'missing native sprite');return true end}
dofile('game.lua')
local function get(key)for i=1,150 do local n,v=debug.getupvalue(update,i);if n==key then return v,i end end;error(key)end
local function set(key,v)local _,i=get(key);debug.setupvalue(update,i,v)end
assert(get('titleOpen')==true,'release must open normal title')
update();keys={[BTN_Z]=true};update();keys={};update();assert(not get('titleOpen'),'new game failed')
local M=require('metric_rooms');local function exitHouse()
 set('currentRoom','frente');local x,y=M.project('frente',9.7,-.08,0);set('x',x);set('y',y);set('streetCooldown',0);set('crossing',false);set('transitionCarry',nil);update();assert(get('streetMode'),'house to street');for i=1,3 do update()end;assert(not get('pendingStreet'),'staged loading incomplete');return get('street')
end

local S=exitHouse();S.enter39();local H=require('house39')
assert(H.walkable(7.55,2.4),'entry blocked')
package=nil
local peak=0;local retained
for pass=1,25 do
 S.enter39()
 for i=1,160 do keys={[UP]=true};if i%50<20 then keys[LEFT]=true end;update();peak=math.max(peak,collectgarbage('count')) end
 keys={};S.leave39();update();collectgarbage('collect')
 if pass==1 then retained=collectgarbage('count')end
end
assert(collectgarbage('count')<retained+64,'House39 transition leak')
local misses,total=0,0
H.bits=7
for gy=2,52 do for gx=2,52 do local x,y=gx*.15,gy*.15
 if H.walkable(x,y)then total=total+1;local c=H.selectCamera(x,y,nil);if H.clearance(H.cameras[c],x,y)<-.5 then misses=misses+1 end end
end end
assert(misses==0,'clipped grid points: '..misses)
for shot,c in ipairs(H.cameras)do for st=0,7 do H.bits=st;H.prepare(shot);assert(H.prefix(shot))end end
H.bits=0
assert(not H.walkable(2.5,4.125),'closed bedroom leaf must collide')
assert(H.action(2.95,4.125)=='Porta aberta.');assert(H.walkable(2.5,4.125),'opened bedroom entry blocked')
assert(H.action(3.65,4.25)=='Porta aberta.');assert(H.walkable(3.65,4.7),'bath entry blocked')
assert(H.action(5.5,4.25)=='Porta aberta.');assert(H.walkable(5.5,4.7),'main bedroom entry blocked')
assert(not H.walkable(3,3.55),'no corridor/living opening')
assert(H.walkable(4,1.8),'living/kitchen opening blocked')
collectgarbage('collect');local warm=collectgarbage('count');local high=warm
for pass=1,3 do for shot,c in ipairs(H.cameras)do for st=0,7 do H.bits=st;H.prepare(shot);high=math.max(high,collectgarbage('count'))end end;collectgarbage('collect')end
assert(collectgarbage('count')<warm+16,'depth state cache growth')
print(string.format('PASS warm state stress: peak %.1f KiB, retained %.1f KiB, growth %.1f KiB',high,collectgarbage('count'),collectgarbage('count')-warm))
print(string.format('PASS House39: %d visible walkable samples, 4000 frames, 25 portal round trips; peak %.1f KiB, retained growth %.1f KiB',total,peak,collectgarbage('count')-retained))
