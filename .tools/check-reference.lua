-- Replay the approved 11.2 controls and compare the projected character triangles.
local root,record=...
root=root or '.'
local names={'sala','cozinha','corredor','quarto','banheiro','garagem','quintal','frente'}
local spawns={{3.1,1.6},{2.2,1.4},{.9,1.2},{2.6,1.3},{1.25,1.4},{3.1,1.6},{3,1.8},{4,2.2}}
local function up(fn,key,value)
 for i=1,100 do local n,v=debug.getupvalue(fn,i);if n==key then if value~=nil then debug.setupvalue(fn,i,value)end;return v end end
 error('missing upvalue '..key)
end
local results={}
for _,fps in ipairs({5,30,60})do
 for index,room in ipairs(names)do
  for _,name in ipairs({'metric_rooms','perspective','navigation','inventory','frame_time','sprites','palette'})do package.loaded[name]=nil end
  package.path=root..'/?.lua;'..package.path
  LEFT,RIGHT,UP,DOWN=0,1,2,3
  local keys,hash={},1
  local function mix(v)hash=(hash*65599+v)%2147483647 end
  local sprites={}
  for _,prefix in ipairs({'sala75','cozinha76','corredor100','quarto100','banheiro100','garagem100','quintal100','frente100','titulo103'})do
   for i=0,2 do sprites[prefix..'_'..i]=prefix..i end
  end
  package.preload.sprites=function()return sprites end
  package.preload.palette=function()return {0,1}end
  ui={cls=function()end,btn=function(k)return keys[k]or false end,stat=function()return fps end,
   palset=function()end,print=function()end,rectfill=function()end,rect=function()end,line=function()end,spr=function()end,
   trisfill=function(...)for _,v in ipairs({...})do mix(v)end end}
  dofile(root..'/game.lua')
  local M=require('metric_rooms');local x,y=M.project(room,spawns[index][1],spawns[index][2],0)
  up(update,'titleOpen',false);up(update,'currentRoom',room);up(update,'x',x);up(update,'y',y)
  for frame=1,24 do
   keys={}
   if frame<=4 then keys[1]=true
   elseif frame<=8 then keys[0]=true;keys[12]=true
   elseif frame<=12 then keys[2]=true
   elseif frame<=16 then keys[15]=true;keys[12]=(frame==14)
   elseif frame==18 or frame==20 then keys[13]=true
   elseif frame>=22 then keys[3]=true;keys[12]=true end
   update()
  end
  results[#results+1]={room,fps,hash,up(update,'x'),up(update,'y'),up(update,'step')}
 end
end
if record=='record'then
 io.write('return {\n')
 for _,r in ipairs(results)do io.write(string.format('{%q,%d,%.0f,%.14g,%.14g,%.14g},\n',table.unpack(r)))end
 io.write('}\n')
else
 local expected=dofile(root..'/.tools/validated112-trace.lua')
 local garage=dofile(root..'/.tools/garage118/replay.lua')
 for _,row in ipairs(garage)do for i,old in ipairs(expected)do if old[1]=='garagem'and old[2]==row[2]then expected[i]=row end end end
 for i,row in ipairs(results)do
  for j,v in ipairs(row)do
   if j>=4 then assert(math.abs(v-expected[i][j])<1e-8,row[1]..' changed motion')
   else assert(v==expected[i][j],row[1]..' changed character projection or input')end
  end
 end
 print('Seven rooms preserve approved 11.2 replay; expanded garage matches 11.8 trace at 5/30/60 FPS')
end
