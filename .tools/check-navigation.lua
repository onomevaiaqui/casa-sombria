LEFT,RIGHT,UP,DOWN=0,1,2,3
local keys={}
local sprites={}
for _,name in ipairs({'sala75','cozinha76','corredor100','banheiro100','quarto100','garagem100','quintal100','frente100','titulo103'})do
 for i=0,2 do sprites[name..'_'..i]=name..i end
end
package.preload.sprites=function()return sprites end
package.preload.palette=function()return {0,1}end
ui={cls=function()end,btn=function(i)return keys[i] or false end,palset=function()end,
 print=function()end,rectfill=function()end,rect=function()end,line=function()end,trisfill=function()end,spr=function()end}
dofile('game.lua')
keys={[4]=true};update();keys={};update()
local function find(fn,key)
 for i=1,100 do local name,v=debug.getupvalue(fn,i);if name==key then return v,i end end
 error(key)
end
local function set(k,v)local _,i=find(update,k);debug.setupvalue(update,i,v)end
local collision=find(update,'walkable')
local passage=find(update,'checkPassage')
local exits=find(passage,'exits')
local failures=0
local function check(ok,message)if not ok then print('FAIL '..message);failures=failures+1 end end
local order={'sala','cozinha','corredor','banheiro','quarto','garagem','quintal','frente'}
for _,room in ipairs(order)do
 set('currentRoom',room)
 for _,e in ipairs(exits[room])do
  local candidates={}
  for py=e.y1,e.y2,1 do for px=e.x1,e.x2,1 do
   if collision(px,py)then candidates[#candidates+1]={px,py}end
  end end
  check(#candidates>0,room..' -> '..e.to..' inaccessible trigger')
  set('currentRoom',e.to)
  check(collision(e.x,e.y),room..' -> '..e.to..' blocked spawn '..e.x..','..e.y)
  set('currentRoom',room)
 end
 -- Raster flood fill verifies that every exit belongs to the same floor component.
 local valid,queue,visited={},{},{}
 for y=130,236,2 do for x=18,462,2 do
  local id=y*500+x
  if collision(x,y)then valid[id]=true end
 end end
 local first=exits[room][1]
 for y=first.y1,first.y2 do for x=first.x1,first.x2 do
  if x%2==0 and y%2==0 and valid[y*500+x]then queue[1]=y*500+x;break end
 end;if queue[1]then break end end
 if queue[1]then
  visited[queue[1]]=true;local i=1
  while i<=#queue do
   local id=queue[i];i=i+1
   for _,delta in ipairs({-2,2,-1000,1000})do
    local next=id+delta
    if valid[next]and not visited[next]then visited[next]=true;queue[#queue+1]=next end
   end
  end
  for _,e in ipairs(exits[room])do
   local reached=false
   for y=e.y1,e.y2 do for x=e.x1,e.x2 do if visited[y*500+x]then reached=true end end end
   check(reached,room..' disconnected exit '..e.to)
  end
 else check(false,room..' flood fill seed unavailable')end
 print(room..' reachable floor nodes '..#queue)
end
assert(failures==0,failures..' navigation errors')
print('All 18 triggers, arrival spawns and connected room paths valid')
local checked=0
for _,room in ipairs(order)do for _,e in ipairs(exits[room])do
 set('currentRoom',room)
 local px,py
 for yy=e.y1,e.y2 do
  for xx=e.x1,e.x2 do if collision(xx,yy)then px,py=xx,yy;break end end
  if px then break end
 end
 assert(px)
 set('x',px);set('y',py);set('crossing',false);set('transitionCarry',nil)
 set('step',.7);set('walking',true);set('running',true)
 passage(e.dx,e.dy,e.dx,e.dy)
 assert(find(update,'currentRoom')==e.to,room..' transition failed')
 assert(math.abs(find(update,'step')-.7)<1e-9,'camera cut reset animation phase')
 assert(find(update,'walking') and find(update,'running'),'camera cut interrupted locomotion')
 assert(collision(find(update,'x'),find(update,'y')),'invalid arrival after cut')
 checked=checked+1
end end
print(checked..' actual camera transitions preserve animation phase and valid arrivals')

