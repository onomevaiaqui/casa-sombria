LEFT,RIGHT,UP,DOWN=0,1,2,3
package.preload.sprites=function()return dofile('.tools/sprites168.lua')end
package.preload.palette=function()return dofile('.tools/palette142.lua')end
local hash,calls=0,0
ui={cls=function()end,btn=function()return false end,stat=function()return 60 end,palset=function()end,print=function()end,rectfill=function()end,rect=function()end,line=function()end,spr=function()end,
 trisfill=function(a,b,c,d,e,f,k)
  calls=calls+1
  for _,v in ipairs({a,b,c,d,e,f,k})do hash=(hash*31+v)%2147483647 end
 end}
dofile('game.lua')
local E=require('enemy153');local L=require('survival158');local C=require('cameras168');local D=require('enemy_data155')
C.select('frente',9.7,3.2)
local rows={}
for _,name in ipairs({'idle','attack','run','death'})do
 for shot=1,#C.data.frente do for angle=0,3 do for sample=0,7 do
  E.reset();C.room='frente';C.shot=shot;E.angle=angle*math.pi/2
  E.time=D.clips[name].duration*sample/7
  if name=='death'then E.hp=0;E.state='dying'elseif name=='attack'then E.attackTime=E.time elseif name=='run'then E.moving=true;E.runTime=E.time end
  hash,calls=0,0;E.draw('frente');rows[#rows+1]=string.format('%s:%d:%d:%d %d %d',name,shot,angle,sample,hash,calls)
 end end end
end
local file=assert(io.open(arg[1]or'../../outputs/profile159-before-signatures.txt','w'));file:write(table.concat(rows,'\n'));file:close()
ui.trisfill=function()end
for _,name in ipairs({'idle','attack','run'})do
 E.reset();C.room='frente';C.shot=1;local clip=D.clips[name]
 for i=1,30 do E.draw('frente')end
 collectgarbage('collect');local start=os.clock();local maximum=0
 for i=1,1500 do
  E.time=(i/60)%clip.duration;E.angle=i/500
  E.attackTime=name=='attack'and E.time or nil;E.moving=name=='run';E.runTime=E.time
  local t=os.clock();E.draw('frente');maximum=math.max(maximum,os.clock()-t)
 end
 print(string.format('DRAW %s: %.3f ms/update, max %.3f ms (desktop only)',name,(os.clock()-start)*1000/1500,maximum*1000))
end
L.damage=function()return false end;E.reset();L.reset();local sum,maximum=0,0
for i=1,6000 do
 local x,y=9+2*math.sin(i/160),3+1.5*math.cos(i/190)
 local t=os.clock();E.tick(1/60,'frente',x,y);local elapsed=os.clock()-t
 sum=sum+elapsed;maximum=math.max(maximum,elapsed)
end
print(string.format('AI: %.4f ms/update, max %.3f ms (desktop only)',sum*1000/6000,maximum*1000))
