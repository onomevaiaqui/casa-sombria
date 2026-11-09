LEFT,RIGHT,UP,DOWN=0,1,2,3
package.preload.sprites=function()return dofile('.tools/sprites168.lua')end
package.preload.palette=function()return dofile('.tools/palette142.lua')end
local keys,labels={},{}
ui={cls=function()end,btn=function(i)return keys[i]or false end,stat=function()return 60 end,palset=function()end,print=function(s)labels[#labels+1]=s end,rectfill=function()end,rect=function()end,line=function()end,trisfill=function()end,spr=function()end}
dofile('game.lua')
local function get(f,k)for i=1,100 do local n,v=debug.getupvalue(f,i);if n==k then return v,i end end;error(k)end
local function set(f,k,v)local _,i=get(f,k);debug.setupvalue(f,i,v)end
local M=require('metric_rooms');local G=require('combat164');local L=require('survival158')
set(update,'titleOpen',false);set(update,'currentRoom','frente');local x,y=M.project('frente',10,2,0);set(update,'x',x);set(update,'y',y);set(update,'facing',M.facing('frente',0,-1));update()
local gx,gy=M.ground('frente',get(update,'x'),get(update,'y'))
keys={[2]=true};update()
local nx,ny=M.ground('frente',get(update,'x'),get(update,'y'))
assert(math.abs(math.sqrt((nx-gx)^2+(ny-gy)^2)-1.7009575856/60)<1e-8,'walking not immediate or speed changed')
assert(get(update,'walking')and not G.stable(),'walk crossfade missing')
for i=1,3 do update()end;assert(G.stable(),'walk startup still exceeds four 60 Hz frames')
gx,gy=M.ground('frente',get(update,'x'),get(update,'y'));keys={[2]=true,[12]=true};update()
nx,ny=M.ground('frente',get(update,'x'),get(update,'y'))
assert(math.abs(math.sqrt((nx-gx)^2+(ny-gy)^2)-4.1070557323/60)<1e-8,'running not immediate or speed changed')
for i=1,4 do update()end;assert(G.stable(),'walk/run crossfade exceeds five 60 Hz frames')
x,y=get(update,'x'),get(update,'y');keys={};update()
assert(get(update,'x')==x and get(update,'y')==y,'movement coasts after release')
for i=1,4 do update()end;assert(G.stable(),'stop crossfade exceeds five 60 Hz frames')
local title=get(update,'drawTitle');set(update,'titleOpen',true);labels={};update()
assert(not table.concat(labels,'|'):match('B CONFIRM'),'confirm/back hint remains on title')
set(title,'settingsOpen',true);set(title,'controlsOpen',false);labels={};update()
assert(not table.concat(labels,'|'):match('B CONFIRM'),'confirm/back hint remains outside control map')
set(title,'controlsOpen',true);labels={};update()
assert(table.concat(labels,'|'):match('B CONFIRMA  A VOLTA'),'control map lacks confirm/back hint')
assert(table.concat(labels,'|'):match('CIMA/BAIXO: AVANCA/RECUA'),'control map is not classic layout')
print('PASS immediate full-speed walk/run, immediate stop, 60/80 ms locomotion crossfades and title/settings hint placement')
