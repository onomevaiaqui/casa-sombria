LEFT,RIGHT,UP,DOWN=0,1,2,3
local keys={}
local sprites={};for _,views in pairs(require('camera_data155'))do for _,c in ipairs(views)do for _,v in pairs(c.states)do for i=0,2 do sprites[v.prefix..'_'..i]=true end end end end
for _,name in ipairs({'sala75','cozinha76','corredor100','banheiro100','quarto100','garagem100','quintal100','frente100','titulo103'})do
 for i=0,2 do sprites[name..'_'..i]=name..i end
end
package.preload.sprites=function()return sprites end
package.preload.palette=function()return {0,1}end
ui={cls=function()end,btn=function(i)return keys[i] or false end,palset=function()end,
 print=function()end,rectfill=function()end,rect=function()end,line=function()end,trisfill=function()end,spr=function()end}
dofile('game.lua')

local function find(fn,key)for i=1,100 do local name,v=debug.getupvalue(fn,i);if name==key then return v,i end end;error(key)end
local function set(k,v)local _,i=find(update,k);debug.setupvalue(update,i,v)end
local M=require('metric_rooms');local D=require('doors131');local C=require('cameras155');local L=require('layout140');local master={0};for _,p in ipairs(M.bank)do master[#master+1]=p[1]end;C.setup(sprites,master)

local passage=find(update,'checkPassage');local bad={}
for _,route in ipairs({{'frente','quintal'},{'quintal','frente'}})do
 local from,to=route[1],route[2];local e;for _,v in ipairs(L.exits[from])do if v.to==to then e=v end end
 for j=0,20 do
  D.reset();D.open('jardim_quintal');local gx=e.world[1]+(e.world[2]-e.world[1])*j/20;local gy=(e.world[3]+e.world[4])/2
  local sx,sy=M.project(from,gx,gy,0);set('currentRoom',from);set('x',sx);set('y',sy);set('crossing',false);set('transitionCarry',nil);set('titleOpen',false)
  local xx,yy=M.project(from,gx,gy+e.transfer.awayY*.1,0);passage(xx-sx,yy-sy,0,e.transfer.awayY)
  local tx,ty=find(update,'x'),find(update,'y');local wx,wy=M.ground(to,tx,ty)
  if not M.walkable(to,tx,ty)or not D.walkable(to,wx,wy)then bad[#bad+1]={from=from,x=gx,destinationX=wx,destinationY=wy}end
 end
end
for _,p in ipairs(bad)do print('BLOCKED ARRIVAL',p.from,p.x,p.destinationX,p.destinationY)end
assert(#bad==0,'transfer still puts the player inside an obstacle')
print('PASS 42 lateral gate crossings, both directions; no blocked arrivals')

local P=require('passage156');local calls=0
local blocked={ground=function()return 4.55,.65 end,project=function(_,x,y)return x,y end,walkable=function()calls=calls+1;return false end}
assert(P.arrival(blocked,D,'quintal',4.55,.65,{axis=2,low=4.55,high=5.05})==nil)
assert(calls<=258,'unbounded safe-arrival search')
print('PASS completely obstructed destination rejected with bounded search')
local count=0
for from,exits in pairs(L.exits)do for _,e in ipairs(exits)do for j=0,20 do
 D.reset();for _,door in ipairs(D.list)do D.open(door.id)end
 local w=e.world;local gx,gy=(w[1]+w[2])/2,(w[3]+w[4])/2
 if e.transfer.axis==1 then gy=w[3]+(w[4]-w[3])*j/20 else gx=w[1]+(w[2]-w[1])*j/20 end
 local sx,sy=M.project(from,gx,gy,0)
 if M.walkable(from,sx,sy)and D.walkable(from,gx,gy)then
  set('currentRoom',from);set('x',sx);set('y',sy);set('crossing',false);set('transitionCarry',nil)
  local tx,ty=M.project(from,gx+e.transfer.awayX*.1,gy+e.transfer.awayY*.1,0);passage(tx-sx,ty-sy,1,0)
  if find(update,'currentRoom')==e.to then
   local ax,ay=find(update,'x'),find(update,'y');local wx,wy=M.ground(e.to,ax,ay)
   assert(M.walkable(e.to,ax,ay)and D.walkable(e.to,wx,wy),'unsafe destination '..from..' -> '..e.to)
  end
  count=count+1
 end
end end end
print('PASS '..count..' doorway edge/centre samples across all rooms')
