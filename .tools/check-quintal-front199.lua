LEFT,RIGHT,UP,DOWN=0,1,2,3;BTN_Z,BTN_F,BTN_G,BTN_E=4,12,13,15
local refs=dofile('.tools/sprites196.lua');package.preload.sprites=function()return refs end;package.preload.palette=function()return dofile('.tools/palette142.lua')end
ui={btn=function()return false end,stat=function(i)if i==7 then return 60 elseif i==0 then return 1024 end end,cls=function()end,palset=function()end,print=function()end,rectfill=function()end,rect=function()end,line=function()end,trisfill=function()end,spr=function()return true end}
dofile('game.lua')
local function get(key)for i=1,160 do local n,v=debug.getupvalue(update,i);if n==key then return v,i end end;error(key)end
local function set(key,v)local _,i=get(key);debug.setupvalue(update,i,v)end
local M=require('metric_rooms');local L=require('layout140');local D=require('doors131');local life=require('survival158');local passage=get('checkPassage')
package=nil;set('titleOpen',false)
-- Reproduce the route in the console video before testing the side gate.
for _,room in ipairs({'sala','cozinha','quintal'})do local p=L.spawns[room];set('currentRoom',room);local x,y=M.project(room,p[1],p[2],0);set('x',x);set('y',y);life.reset();update()end
local peak,first,final=0,nil,nil
for pass=1,50 do
 for _,room in ipairs({'quintal','frente'})do
  life.reset();D.open('jardim_quintal');set('streetMode',false);set('pendingStreet',nil);set('currentRoom',room);set('crossing',false);set('transitionCarry',nil)
  local e;for _,v in ipairs(L.exits[room])do if(room=='quintal'and v.to=='frente')or(room=='frente'and v.to=='quintal')then e=v;break end end;assert(e)
  local w=e.world;local gx,gy=(w[1]+w[2])/2,(w[3]+w[4])/2;local sx,sy=M.project(room,gx,gy,0);set('x',sx);set('y',sy)
  local xx,yy=M.project(room,gx+e.transfer.awayX*.1,gy+e.transfer.awayY*.1,0);passage(xx-sx,yy-sy,1,0);assert(get('currentRoom')==e.to)
  collectgarbage('collect');collectgarbage('stop');update();peak=math.max(peak,collectgarbage('count'));collectgarbage('restart');collectgarbage('collect')
 end
 final=collectgarbage('count');if not first then first=final else assert(final<first+64,'retained gate-transition memory growth')end
end
local T=require('frame_time');assert(T.luaBytes>100*1024,'HUD trusted bogus 1KiB firmware stat instead of Lua heap')
print(string.format('PASS 100 backyard/front gate passages, package=nil; peak %.1f KiB; retained growth %.1f KiB; actual Lua heap HUD',peak,final-first))
