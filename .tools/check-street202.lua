LEFT,RIGHT,UP,DOWN=0,1,2,3;BTN_Z,BTN_F,BTN_G,BTN_E=4,12,13,15
local refs=dofile('.tools/sprites196.lua');local palette=dofile('.tools/palette142.lua');package.preload.sprites=function()return refs end;package.preload.palette=function()return palette end
local keys={};local fps=60;local hash=0;local function draw(...)for _,v in ipairs({...})do hash=(hash*33+v)%2147483647 end end
ui={btn=function(i)return keys[i]or false end,stat=function(i)if i==7 then return fps end end,cls=function()end,palset=function()end,print=function()end,rectfill=function()end,rect=function()end,line=function()end,trisfill=draw,spr=function()return true end}
dofile('game.lua');local function get(fn,key)for i=1,150 do local n,v=debug.getupvalue(fn,i);if n==key then return v end end;error(key)end
local current=get(update,'ensureStreet')();local actor=get(current.setup,'actor')
local reference=assert(loadfile('.tools/street202-reference.lua'))()
local function buffers()local v,p={},{};for i=1,408 do v[i]={0,0,0}end;for i=1,#actor.triangles/7 do p[i]={}end;return{vertices=v,faces={},pool=p}end
current.setup(actor,refs,buffers(),palette);reference.setup(actor,refs,buffers(),palette)
local count=0
for ix=-150,150 do for iy=-330,280 do local x,y=ix/20,iy/10;assert(current.walkable(x,y)==reference.walkable(x,y),'collision changed');count=count+1 end end
print('PASS '..count..' walkable positions identical')
for _,start in ipairs({{0,18},{0,4},{0,-3},{-3.8,3.3}})do
 current.reset(start[1],start[2],0);reference.reset(start[1],start[2],0)
 for i=1,240 do
  keys={};if i%100<70 then keys[UP]=true end;if i%80<30 then keys[LEFT]=true end;if i%70<35 then keys[BTN_F]=true end
  hash=0;reference.update(false);local expected=hash;hash=0;current.update(false);assert(hash==expected,'render pixels differ at '..i)
  local a,b,c,d=current.position();local e,f,g,h=reference.position();assert(a==e and b==f and c==g and d==h,'movement changed')
 end
end
print('PASS 960 frames: identical sorted triangle coordinates/colors and motion at 60 FPS')
for _,rate in ipairs({5,7,15,30,60})do
 fps=rate;keys={[UP]=true};current.reset(0,7,0)
 for i=1,rate do current.update(false,1/rate)end
 local _,y=current.position();assert(math.abs(y-(7-1.7009575856))<1e-8,'walk slowed at '..rate)
 keys={[UP]=true,[BTN_F]=true};current.reset(0,7,0)
 for i=1,rate do current.update(false,1/rate)end
 _,y=current.position();assert(math.abs(y-(7-4.1070557323))<1e-8,'run slowed at '..rate)
end
fps=60;keys={};ui.trisfill=function()end
local function bench(m,move)
 m.reset(0,7,0);local t=os.clock();for i=1,1000 do keys=move and{[LEFT]=true}or{};m.update(false)end;return os.clock()-t
end
local oldIdle,newIdle=bench(reference,false),bench(current,false);local oldTurn,newTurn=bench(reference,true),bench(current,true)
print(string.format('DESKTOP Lua update 1000 frames: idle %.4f -> %.4fs; turning %.4f -> %.4fs (not console FPS)',oldIdle,newIdle,oldTurn,newTurn))
collectgarbage('collect');local baseline=collectgarbage('count');for i=1,10000 do keys={[LEFT]=i%100<50,[UP]=i%80<30};current.update(false)end;collectgarbage('collect');assert(collectgarbage('count')-baseline<10)
print('PASS real-second walk/run distance at 5/7/15/30/60 FPS; 10000 frames bounded retained memory')
