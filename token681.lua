local T={active=false,angle=0}
local D=require('token681_data')
local function palette(ui)for i,c in ipairs(D.palette)do ui.palset(207+i,c)end end
function T.icon(ui,x,y)
 palette(ui)
 for yy=0,27 do for xx=0,27 do local k=D.data:byte(math.floor(yy/28*64)*64+math.floor(xx/28*64)+1);if k>0 then ui.rectfill(x+xx,y+yy,x+xx,y+yy,207+k)end end end
end
function T.begin()T.active=true;T.angle=0;T.previousA=true end
function T.tick(dt,left,right,cancel)
 T.angle=(T.angle+((right and 1 or 0)-(left and 1 or 0))*dt*3.2)%(math.pi*2)
 if cancel and not T.previousA then T.active=false end;T.previousA=cancel
end
function T.draw(ui)
 ui.cls(240);ui.palset(240,0);ui.palset(241,32767);palette(ui)
 local co=math.cos(T.angle);local w=math.max(2,math.floor(140*math.abs(co)));local x=math.floor(240-w/2)
 if co>=0 then
  for yy=0,63 do for xx=0,63 do local k=D.data:byte(yy*64+xx+1);if k>0 then ui.rectfill(x+math.floor(xx/64*w),38+math.floor(yy/64*140),x+math.floor((xx+1)/64*w),38+math.floor((yy+1)/64*140),207+k)end end end
 else
  for yy=0,139 do local r=math.sqrt(math.max(0,1-((yy-70)/70)^2));ui.line(240-r*w/2,38+yy,240+r*w/2,38+yy,214)end
 end
 ui.print('Ficha telefonica LOCAL - 1990',150,201,241);ui.print('Consumida ao salvar em um telefone publico.',112,218,241);ui.print('DIRECIONAL: GIRAR    A: VOLTAR',145,248,241)
end
return T
