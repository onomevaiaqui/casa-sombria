LEFT,RIGHT,UP,DOWN=0,1,2,3
local refs=dofile('.tools/sprites168.lua')
package.preload.sprites=function()return refs end
package.preload.palette=function()return dofile('.tools/palette142.lua')end
ui={cls=function()end,btn=function()return false end,stat=function()return 60 end,
 palset=function(i,v)assert(i>=0 and i<=255 and v>=0 and v<=32767)end,
 print=function()end,rectfill=function()end,rect=function()end,line=function()end,trisfill=function()end,spr=function()end}
collectgarbage('collect');local base=collectgarbage('count');collectgarbage('stop')
dofile('game.lua');assert(require('cameras168').enabled,'native bitmap/palette bootstrap failed');local boot=collectgarbage('count')-base;collectgarbage('restart');collectgarbage('collect')
print(string.format('BOOT transient %.1f KB; retained %.1f KB',boot,collectgarbage('count')-base))
local function get(key)for i=1,100 do local n,v=debug.getupvalue(update,i);if n==key then return v,i end end;error(key)end
local function set(key,v)local _,i=get(key);debug.setupvalue(update,i,v)end
local M=require('metric_rooms');local L=require('layout140');set('titleOpen',false)
local peak,retained=0,0
for room,p in pairs(L.spawns)do
 local x,y=M.project(room,p[1],p[2],0);set('currentRoom',room);set('x',x);set('y',y);set('crossing',false);set('transitionCarry',nil)
 collectgarbage('collect');collectgarbage('stop');update();local temporary=collectgarbage('count')-base
 collectgarbage('restart');collectgarbage('collect');local steady=collectgarbage('count')-base
 peak=math.max(peak,temporary);retained=math.max(retained,steady)
 print(string.format('%s transient %.1f KB; retained %.1f KB',room,temporary,steady))
end
assert(peak<8192,'unexpected large runtime memory regression')
print(string.format('PASS desktop Lua gameplay max observed transient %.1f KB; retained %.1f KB (not hardware totals)',peak,retained))
