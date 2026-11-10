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
 set('currentRoom','frente');local x,y=M.project('frente',9.7,-.08,0);set('x',x);set('y',y);set('streetCooldown',0);set('crossing',false);set('transitionCarry',nil);update();assert(get('streetMode'),'house to street');return get('street')
end
local S=exitHouse();assert(package.loaded.actor_data==nil,'duplicate actor animation data loaded')
-- Inventory remains usable outside the house.
keys={[BTN_G]=true};update();assert(get('inventory').visible);keys={};update();keys={[BTN_G]=true};update();assert(not get('inventory').visible);keys={}
-- Match sandbox: package is unavailable on hardware.
package=nil
for i=1,60 do update()end
collectgarbage('collect');local first=collectgarbage('count');local peak=first;local retained
for pass=1,20 do
 S.reset(0,18,0)
 for i=1,500 do
  keys={};if i%200<100 then keys[UP]=true;keys[BTN_F]=true else keys[DOWN]=true end
  if i%40<16 then keys[LEFT]=true end
  update();if i%20==0 then peak=math.max(peak,collectgarbage('count'))end
 end
 keys={};S.reset(-4.6,3.3,0);set('streetCooldown',0);update();assert(not get('streetMode'),'street to house')
 S=exitHouse();collectgarbage('collect');local now=collectgarbage('count')
 if pass==1 then retained=now else assert(now<retained+64,'retained memory growth across portals')end
end
assert(draws>0,'3D actor not drawn')
print(string.format('PASS 10000 street frames + 20 portal round trips; peak %.1f KiB; retained %.1f KiB; growth %.1f KiB',peak,collectgarbage('count'),collectgarbage('count')-retained))
print('PASS normal title, new game, shared actor, exterior inventory, native sprites and package=nil')
