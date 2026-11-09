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

local startAngle=M.facing('frente',0,-1);set('facing',startAngle)
local function center()
 keys={};update();set('currentRoom','frente');set('x',x);set('y',y);set('facing',startAngle);set('crossing',false)
end
center();keys={[2]=true};for i=1,15 do update()end
local fx,fy=M.ground('frente',get('x'),get('y'));assert(math.abs(fx-9.7)<1e-7 and math.abs(fy-(3.2-1.7009575856/4))<1e-6,'up is not forward at original speed')
assert(math.cos(get('facing')-startAngle)>.99999)
center();keys={[3]=true,[12]=true};for i=1,15 do update()end
local bx,by=M.ground('frente',get('x'),get('y'));assert(math.abs(bx-9.7)<1e-7 and math.abs(by-(3.2+1.7009575856/4))<1e-6,'down must backpedal at walk speed')
assert(math.cos(get('facing')-startAngle)>.99999,'backpedaling turns actor')
center();keys={[1]=true};for i=1,15 do update()end
assert(math.abs(get('x')-x)<1e-8 and math.abs(get('y')-y)<1e-8,'turning translates player')
assert(math.cos(get('facing')-(startAngle-S.turnRate/4))>.99999,'right rotation sign')
center();keys={[15]=true,[0]=true,[2]=true};for i=1,15 do update()end
assert(math.abs(get('x')-x)<1e-8 and math.abs(get('y')-y)<1e-8,'guard translates player')
assert(math.cos(get('facing')-(startAngle+S.aimTurnRate/4))>.99999,'guard cannot rotate')
keys={};update();set('facing',.75);keys={[15]=true,[12]=true,[0]=true};update();keys={[15]=true,[0]=true}
for i=1,15 do update();assert(math.abs(get('facing')-.75)<1e-8,'turns during active swing')end
center();keys={[2]=true,[12]=true};for i=1,15 do update()end
local rx,ry=M.ground('frente',get('x'),get('y'));assert(math.abs(ry-(3.2-4.1070557323/4))<1e-6,'forward running speed changed')
for room in pairs(M.sizes)do
 for i=0,15 do
  local a=i*math.pi/8;local wx,wy=S.forward(room,a)
  assert(math.abs(wx*wx+wy*wy-1)<1e-8)
  for other in pairs(M.sizes)do
   local b=M.facing(other,wx,wy);local ux,uy=S.forward(other,b)
   assert(wx*ux+wy*uy>.9999,'heading changes on room transfer')
  end
 end
end
-- The active render shot cannot alter tank world direction.
local wx,wy=S.forward('frente',.6);local shot=C.shot
for n=1,#C.data.frente do C.shot=n;local xx,yy=S.forward('frente',.6);assert(xx==wx and yy==wy)end;C.shot=shot
print('PASS classic up/down, reverse cadence, left/right pivots, guard rotation, strike lock, walk/run speeds and world heading across cameras/rooms')

for _,sign in ipairs({1,-1})do
 keys={};set('currentRoom','sala');set('crossing',false);set('transitionCarry',nil)
 local x,y=M.project('sala',2.4,4.7,0);set('x',x);set('y',y);set('facing',M.facing('sala',0,sign))
 local tx,ty=M.project('sala',2.4,4.8,0)
 get('checkPassage')(tx-x,ty-y,0,-sign)
 assert(get('currentRoom')=='cozinha','open passage did not transfer')
 local wx,wy=S.forward('cozinha',get('facing'));assert(wy*sign>.9999,'passage reverses world facing')
end
print('PASS actual sala/cozinha passage preserves facing both forward and backwards')
