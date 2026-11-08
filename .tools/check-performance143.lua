local refs=dofile('.tools/sprites168.lua');local palette=dofile('.tools/palette142.lua')
local C=require('cameras168');local old=dofile('.tools/reference-cameras1421.lua');local M=require('metric_rooms');local L=require('layout140')
C.setup(refs,palette);old.setup(refs,palette)
local sampleCount=0
for room,p in pairs(L.spawns)do
 C.select(room,p[1],p[2]);old.select(room,p[1],p[2]);assert(C.shot==old.shot)
 local project=C.projector(room);local visible=C.occlusion(room)
 for i=0,999 do
  local x=(i%31)/31*L.rooms[room].size[1];local y=(i%29)/29*L.rooms[room].size[2];local z=(i%19)/10
  local a,b,c=project(x,y,z);local d,e,f=old.project(room,x,y,z)
  assert(math.abs(a-d)<1e-8 and math.abs(b-e)<1e-8 and math.abs(c-f)<1e-8,'projection changed')
  local v1,v2,v3={i%480,i%270,1+i%20},{(i*7)%480,(i*3)%270,1+i%20},{(i*13)%480,(i*5)%270,1+i%20}
  assert(visible(v1,v2,v3)==old.triangle(room,v1,v2,v3),'occlusion changed');sampleCount=sampleCount+1
 end
end
C.select('sala',3.1,1.6);old.select('sala',3.1,1.6)
local n=30000;local project=C.projector('sala');local visible=C.occlusion('sala');local a,b,c={200,150,3},{205,155,3},{210,140,3}
local start=os.clock();for i=1,n do old.project('sala',2,2,1);old.triangle('sala',a,b,c)end;local previous=os.clock()-start
start=os.clock();for i=1,n do project(2,2,1);visible(a,b,c)end;local current=os.clock()-start
print('PASS '..sampleCount..' projected points and occlusion samples unchanged')
print(string.format('Desktop CPU microbenchmark (%d projection+occlusion pairs): before %.4fs after %.4fs; %.1f%% reduction (not hardware FPS)',n,previous,current,100*(1-current/previous)))
local T=require('frame_time');local label
local ui={stat=function()return 24 end,rectfill=function()end,print=function(t)label=t end}
T.sample(ui);T.hud(ui);assert(label=='24 FPS F1')
print('PASS HUD actual ui.stat(7) FPS and frame counter')
local originalTime=os.time;local now=100
os.time=function()return now end;T.fps=nil;ui.stat=nil
for i=1,121 do now=100+math.floor((i-1)/60);T.sample(ui)end
T.hud(ui);os.time=originalTime
assert(label:match('^~60 FPS'),'wall-clock fallback missing')
print('PASS estimated wall-clock FPS fallback without changing gameplay timestep')
