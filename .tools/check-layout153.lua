package.path='./?.lua;'..package.path
local M=require('metric_rooms');local D=require('doors131');local L=require('layout140');local C=require('cameras153')
local refs={};local pal={0};for _,p in ipairs(M.bank)do pal[#pal+1]=p[1]end
local n=0
for room,views in pairs(C.data)do for _,v in ipairs(views)do for _,s in pairs(v.states)do assert(#s.depth==s.depthWidth*s.depthHeight);for i=0,2 do refs[s.prefix..'_'..i]=true end;n=n+1 end end end
C.setup(refs,pal)
for _,door in ipairs(D.list)do for room,p in pairs(door.ends)do assert(D.blocked(room,next(door.ends,room)or next(door.ends))~=nil)end;D.open(door.id)end
local count=0
for room,exits in pairs(L.exits)do for _,e in ipairs(exits)do
 local w=e.world;local x,y=(w[1]+w[2])/2,(w[3]+w[4])/2;local sx,sy=M.project(room,x,y,0)
 assert(M.walkable(room,sx,sy),room..' source blocked '..e.to)
 local t=e.transfer;x,y=x+t.offsetX,y+t.offsetY;if t.axis==1 then x=t.normal;y=math.max(t.low,math.min(t.high,y))else y=t.normal;x=math.max(t.low,math.min(t.high,x))end
 sx,sy=M.project(e.to,x,y,0);assert(M.walkable(e.to,sx,sy),room..' arrival blocked '..e.to..' '..x..','..y);assert(D.walkable(e.to,x,y))
 C.select(e.to,x,y);assert(C.background(e.to));count=count+1
end end
assert(count==20);assert(D.stateMask({32})==32);D.reset();assert(D.stateMask({32})==0);assert(D.blocked('sala','corredor'));assert(D.nearby('corredor',.65,1).id=='corredor')
print('PASS '..count..' directed passages, '..n..' bitmap/depth states, closed corridor Door4 opens from either side')

for _,p in ipairs({{'banheiro',1.2,.65},{'quarto',1.7,.65},{'frente',14.4,5.25}})do
 C.room=nil;C.shot=nil;C.select(p[1],p[2],p[3]);local c=C.data[p[1]][C.shot]
 local col,row=math.floor(p[2]/c.visibilityStep+.5),math.floor((p[3]-(c.visibilityY0 or 0))/c.visibilityStep+.5)
 assert(c.visibility[row*c.visibilityWidth+col+1]==1,'occluded arrival '..p[1])
 for _,z in ipairs({0,1.8})do local x,y=C.project(p[1],p[2],p[3],z);assert(x>5 and x<475 and y>21 and y<265,p[1]..' arrival cropped')end
 print('Visible entry camera',p[1],C.shot)
end
local S=require('subtitles');local d=S.new();local prints={}
local ui={print=function(text,x,y,color)if color==241 and text~='>'then assert(x==32,'subtitle not left aligned');prints[#prints+1]=text end end,line=function()end}
d:open({'Uma frase curta. Outra frase longa para verificar que todas as linhas comecem na mesma margem esquerda.'});d.revealed=d.total;d:draw(ui);d:close();d:notify('Porta aberta.');d:draw(ui);assert(#prints>=3)
print('PASS left-aligned dialogue, wrapped lines and notifications')



local function solid(room,x,y)
 local a,b=M.project(room,x,y,0);return not M.walkable(room,a,b)
end
assert(solid('frente',2,8.6),'garden divider missing')
assert(solid('frente',17.8,11.6),'corridor end closure missing')
assert(solid('quintal',6.4,9.4),'kitchen rear closure missing')
D.reset();assert(D.blocked('frente','quintal'));assert(D.nearby('frente',4.8,8.0).id=='jardim_quintal');assert(D.nearby('quintal',4.8,.6).id=='jardim_quintal')
D.open('jardim_quintal');assert(not D.blocked('frente','quintal'));assert(D.stateMask({64})==64)
assert(not D.walkable('quintal',4.3,.6),'open gate leaf has no collision')
assert(D.walkable('quintal',4.8,.6),'open gate blocks entrance')
print('PASS marked closures; gate action from both sides; shared open state and open leaf collision')
