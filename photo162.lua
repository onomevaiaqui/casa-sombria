-- Environmental photo inspection; no 3D model or per-frame allocations.
local P={active=false,angle=0,tilt=0,found=false,previousB=true,previousA=true}
local texture
function P.near(room,x,y)return room=='quarto'and (x-3.5)^2+(y-3.0)^2<.58^2 end
function P.begin()P.active=true;P.angle=0;P.tilt=0;P.previousA=true;P.previousB=true;texture=require('photo_texture162');return true end
function P.reset()P.active=false;P.found=false;texture=nil end
function P.tick(dt,left,right,up,down,confirm,cancel)
 P.angle=(P.angle+((right and 1 or 0)-(left and 1 or 0))*dt*3.4)%(2*math.pi)
 P.tilt=math.max(-.65,math.min(.65,P.tilt+((down and 1 or 0)-(up and 1 or 0))*dt*1.8))
 if math.cos(P.angle)<-.72 then P.found=true end
 local close=(cancel and not P.previousA)or(confirm and not P.previousB)
 P.previousA,P.previousB=cancel,confirm
 if close then P.active=false;texture=nil;return true end
end
function P.draw(ui)
 ui.cls(240);ui.palset(240,0);ui.palset(241,32767)
 for i,c in ipairs(texture.palette)do ui.palset(i-1,c)end
 ui.print('FOTO DE FAMILIA',178,14,241)
 local co=math.cos(P.angle);local width=math.max(2,math.floor(192*math.abs(co)));local height=math.floor(144*math.cos(P.tilt));local x,y=math.floor(240-width/2),math.floor(126-height/2)
 ui.rectfill(x-3,y-3,x+width+3,y+height+3,3)
 if co>.08 then
  local s=texture.runs;local row,col=0,0
  for i=1,#s,2 do local n,k=s:byte(i,i+1);local x1=x+math.floor(col/96*width);local x2=x+math.floor((col+n)/96*width)
   if x2>=x1 then ui.rectfill(x1,y+math.floor(row/72*height),x2,y+math.floor((row+1)/72*height),k)end
   col=col+n;if col==96 then row=row+1;col=0 end
  end
 elseif co<-.08 then
  ui.rectfill(x,y,x+width,y+height,12)
  ui.rect(x+4,y+4,x+width-4,y+height-4,8)
  if width>150 then ui.print('Catarina - 2019',198,121,1)end
 else ui.rectfill(x,y,x+width,y+height,9)end
 if P.found and co<-.72 then ui.print('Catarina - 2019',184,216,241)
 else ui.print('Uma foto de familia.',160,216,241)end
 ui.print('DIRECIONAL: GIRAR   A: VOLTAR',124,248,241)
end
return P
