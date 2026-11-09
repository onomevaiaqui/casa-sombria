local inspection=require('inspection165')
-- Environmental photo inspection; no 3D model or per-frame allocations.
local P={active=false,angle=0,tilt=0,found=false,transcription=false,previousB=true,previousA=true}
local texture,sprites
function P.near(room,x,y)return room=='quarto'and (x-3.5)^2+(y-3.0)^2<.58^2 end
function P.begin()P.active=true;P.angle=0;P.tilt=0;P.previousA=true;P.previousB=true;P.transcription=false;P.reading=nil;texture=require('photo_texture162');sprites=require('sprites');return true end
function P.reset()P.active=false;P.found=false;P.transcription=false;P.reading=nil;texture=nil end
function P.tick(dt,left,right,up,down,confirm,cancel)
 if left or right or up or down then P.reading=nil;P.transcription=false end
 P.angle=(P.angle+((right and 1 or 0)-(left and 1 or 0))*dt*3.4)%(2*math.pi)
 P.tilt=math.max(-.65,math.min(.65,P.tilt+((down and 1 or 0)-(up and 1 or 0))*dt*1.8))
 if not left and not right then
  if P.angle<.16 or P.angle>2*math.pi-.16 then P.angle=0 elseif math.abs(P.angle-math.pi)<.16 then P.angle=math.pi end
 end
 if math.cos(P.angle)<-.72 then P.found=true end
 if confirm and not P.previousB then
  P.reading=inspection.text('Um desenho infantil.','Catarina 2019',P.angle,P.found)
  P.transcription=P.reading=='Catarina 2019'
 end
 local close=cancel and not P.previousA
 P.previousA,P.previousB=cancel,confirm
 if close then P.active=false;texture=nil;return true end
end
function P.draw(ui)
 ui.cls(240);ui.palset(240,0);ui.palset(241,32767)
 for i,c in ipairs(texture.palette)do ui.palset(texture.indices[i],c)end
 local co=math.cos(P.angle);local width=math.max(2,math.floor(224*math.abs(co)));local height=math.floor(150*math.cos(P.tilt));local x,y=math.floor(240-width/2),math.floor(inspection.centerY-height/2)
 ui.rectfill(x-1,y-1,x+width+1,y+height+1,texture.indices[3])
 if width==224 and height==150 and sprites and sprites[co>0 and 'drawing_front164'or 'drawing_back164']then
  ui.spr(sprites[co>0 and 'drawing_front164'or 'drawing_back164'],x,y)
 elseif math.abs(co)>.08 then
  local runs=co>0 and texture.front or texture.back;local row,col=0,0
  for i=1,#runs,2 do local n,k=runs:byte(i,i+1);local x1=x+math.floor(col/texture.width*width);local x2=x+math.floor((col+n)/texture.width*width)
   if x2>x1 then ui.rectfill(x1,y+math.floor(row/texture.height*height),x2,y+math.floor((row+1)/texture.height*height),texture.indices[k+1])end
   col=col+n;if col==texture.width then row=row+1;col=0 end
  end
 else ui.rectfill(x,y,x+width,y+height,texture.indices[9])end
 inspection.caption(ui,P.reading)
 inspection.controls(ui)
end
return P
