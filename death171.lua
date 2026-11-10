-- Palette-only fade: no image, framebuffer copy, alpha layer or per-pixel loop.
local D={proxy={}}
local output,factor
local function dim(index,color)
 local r=color%32;local g=math.floor(color/32)%32;local b=math.floor(color/1024)%32
 output(index,math.floor(r*factor+.5)+math.floor(g*factor+.5)*32+math.floor(b*factor+.5)*1024)
end
D.proxy.palset=dim
function D.palette(ui,life)
 output=ui.palset
 local t=math.min(1,math.max(0,life.time/life.clip.duration))
 t=t*t*(3-2*t);factor=1-.82*t
 return dim
end
function D.draw(ui,life)
 -- Remove diagnostic/health labels, without covering the falling actor.
 ui.palset(240,0);ui.rectfill(0,0,479,38,240)
 local t=math.min(1,math.max(0,(life.time-.20)/1.0))
 if t>0 then
  local level=math.floor(28*t+.5)
  ui.palset(241,level+math.floor(5*t)*32+math.floor(4*t)*1024)
  local text='VOCE MORREU';local left=math.floor((480-(#text*10-4))/2)
  for i=1,#text do ui.print(text:sub(i,i),left+(i-1)*10,120,241)end
 end
 if life.time>=life.clip.duration then
  ui.print('B: TENTAR NOVAMENTE',186,226,241)
  ui.print('A: MENU INICIAL',198,242,241)
 end
end
return D
