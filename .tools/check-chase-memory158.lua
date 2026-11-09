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

local E=require('enemy153');local L=require('survival158');local M=require('metric_rooms')
local function set(k,v)local _,i=get(k);debug.setupvalue(update,i,v)end
set('currentRoom','frente');local sx,sy=M.project('frente',9.7,3.2,0);set('x',sx);set('y',sy)
for i=1,30 do update()end
collectgarbage('collect');local low=collectgarbage('count');local peak=low
for i=1,10000 do
 if i%800==0 then L.reset();E.reset();set('currentRoom','frente');set('x',sx);set('y',sy)end
 if i%1200==1 then for n=1,4 do L.damage()end end
 local phase=i%240
 if phase<90 then keys={[2]=true,[12]=true,[1]=true}
 elseif phase<150 then keys={[3]=true,[0]=true}
 else keys={[15]=true,[12]=i%45==1}end
 update();peak=math.max(peak,collectgarbage('count'))
end
collectgarbage('collect');local after=collectgarbage('count')
assert(after<low+192,'chase retains memory: '..(after-low));assert(peak<4096,'Lua stress heap over 4 MiB: '..peak)
print(string.format('PASS 10000 chase/combat/player-death updates: peak %.1f KiB, retained growth %.1f KiB',peak,after-low))
