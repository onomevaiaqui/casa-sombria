-- Reproduce the physical console's missing package global with a real require.
local refs=dofile('.tools/sprites168.lua');local palette=dofile('.tools/palette142.lua')
package.preload.sprites=function()return refs end
package.preload.palette=function()return palette end
local cache=package.loaded
package=nil
LEFT,RIGHT,UP,DOWN=0,1,2,3
ui={cls=function()end,btn=function()return false end,stat=function()return 60 end,
 palset=function()end,print=function()end,rectfill=function()end,rect=function()end,
 line=function()end,trisfill=function()end,spr=function()end}
dofile('game.lua');assert(require('cameras168').enabled)
local function get(key)for i=1,100 do local n,v=debug.getupvalue(update,i);if n==key then return v,i end end;error(key)end
local function set(key,v)local _,i=get(key);debug.setupvalue(update,i,v)end
set('titleOpen',false)
local M=require('metric_rooms');local layout=require('layout140');local count=0
for room,p in pairs(layout.spawns)do
 local x,y=M.project(room,p[1],p[2],0);set('currentRoom',room);set('x',x);set('y',y);set('crossing',false);set('transitionCarry',nil)
 update();assert(require('camera_data168')[room]);count=count+1
end
assert(package==nil);print('PASS native sandbox package=nil: game bootstrap, start and '..count..' rooms render without package access')
