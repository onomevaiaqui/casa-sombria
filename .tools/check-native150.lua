local M=require('metric_rooms');local old=dofile('.tools/reference-metric148.lua');local N=require('native150')
local function inclusive(c,r)
 local x=math.max(r.x,math.min(r.x+r.w,c.x));local y=math.max(r.y,math.min(r.y+r.h,c.y))
 return(c.x-x)^2+(c.y-y)^2<=c.r*c.r
end
assert(not N.bind({circ_rect_overlap=function()return false end}),'invalid native API accepted')
assert(N.bind({circ_rect_overlap=inclusive}),'native API rejected')
local count=0
for room,size in pairs(M.sizes)do
 for i=-4,math.ceil(size[1]*20)+4 do for j=-4,math.ceil(size[2]*20)+4 do
  local x,y=M.project(room,i/20,j/20,0)
  assert(M.walkable(room,x,y)==old.walkable(room,x,y),'collision changed in '..room);count=count+1
 end end
end
-- Exact edge and tangent cases keep the old strict-overlap rule.
local b={0,1,0,1};N.prepare({{b}})
for _,p in ipairs({{-.25,.5},{1.25,.5},{.5,-.25},{.5,1.25},{0,0},{.5,.5}})do
 local x,y=p[1],p[2];local nx,ny=math.max(0,math.min(1,x)),math.max(0,math.min(1,y))
 assert(N.blocked(x,y,.25,b)==((x-nx)^2+(y-ny)^2<.25^2))
end
N.bind(nil)
local sin,cos=math.sin,math.cos;local trig=0
math.sin=function(x)trig=trig+1;return sin(x)end;math.cos=function(x)trig=trig+1;return cos(x)end
for room,p in pairs(M.plan.spawns)do local x,y=M.project(room,p[1],p[2],0);M.walkable(room,x,y)end
math.sin,math.cos=sin,cos;assert(trig==0,'floor offsets still recomputed')
print('PASS '..count..' native-adapter collision comparisons, strict tangencies, API fallback and zero runtime floor trigonometry')
