LEFT,RIGHT,UP,DOWN=0,1,2,3
package.preload.sprites=function()return dofile('.tools/sprites168.lua')end
package.preload.palette=function()return dofile('.tools/palette142.lua')end
local keys={}
ui={cls=function()end,btn=function(i)return keys[i]or false end,stat=function()return 60 end,palset=function()end,print=function()end,rectfill=function()end,rect=function()end,line=function()end,trisfill=function()end,spr=function()end}
dofile('game.lua')
local function get(k)for i=1,100 do local n,v=debug.getupvalue(update,i);if n==k then return v,i end end;error(k)end
local function set(k,v)local _,i=get(k);debug.setupvalue(update,i,v)end
local M=require('metric_rooms');local S=require('steering157');local P=require('perspective');local C=require('cameras168')
set('titleOpen',false);set('currentRoom','frente');local x,y=M.project('frente',9.7,3.2,0);set('x',x);set('y',y);update()
local dirs={{1,0},{-1,0},{0,1},{0,-1},{1,1},{1,-1},{-1,1},{-1,-1}}
for _,d in ipairs(dirs)do
 keys={};update();local target=S.target('frente',x,y,d[1],d[2]);set('facing',target+math.pi)
 keys={[15]=true};if d[1]==1 then keys[1]=true elseif d[1]==-1 then keys[0]=true end;if d[2]==1 then keys[3]=true elseif d[2]==-1 then keys[2]=true end
 for i=1,20 do update()end
 assert(math.abs(get('x')-x)<1e-8 and math.abs(get('y')-y)<1e-8,'guard translates player')
 assert(math.cos(get('facing')-target)>.99999,'guard cannot face digital direction')
end
keys={};update();set('facing',.75);keys={[15]=true,[12]=true,[0]=true};update();keys={[15]=true,[0]=true}
for i=1,15 do update();assert(math.abs(get('facing')-.75)<1e-8,'steering twists active strike')end
keys={};update();local original=get('walkable');set('walkable',function()return false end);set('facing',0);keys={[0]=true}
for i=1,20 do update()end
assert(math.abs(get('x')-x)<1e-8 and math.abs(get('y')-y)<1e-8,'blocked movement translated player')
local target=S.target('frente',x,y,-1,0);assert(math.cos(get('facing')-target)>.99999,'blocked movement cannot turn');set('walkable',original)
assert(S.turn(math.pi-.01,-math.pi+.01,1/60,16)>math.pi-.01,'long rotation across wrap')
for _,run in ipairs({false,true})do for _,d in ipairs(dirs)do
 C.direction('frente',0,0,0,0)
 local xx,yy,dist=P.move('frente',x,y,d[1],d[2],.1,run,function()return true end)
 assert(math.abs(dist-(run and 4.1070557323 or 1.7009575856)*.1)<1e-7,'diagonal changes speed')
end end
print('PASS eight stationary guard directions, strike orientation lock, blocked turning, shortest rotation and unchanged walk/run speed in eight directions')
