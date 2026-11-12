local P={active=false}
local question=require('subtitles').new()
local mesh,bag,id,angle,tilt,previousB,previousA,reading
local buffers={}
local colors={3206,5355,8560,11797,4362,7633,10904,21374}
function P.reset()question:close();P.active=false;mesh=nil;bag=nil;buffers={}end
function P.begin(item,inventory)
 question:close();id,bag=item,inventory;angle,tilt=0,0;reading=nil;previousB,previousA=true,true;P.active=true
end
function P.tick(dt,left,right,up,down,b,a)
 if question.active then
  question:tick(dt);question:handle(b and not previousB,a and not previousA,left or up,right or down)
  previousB,previousA=b,a;return
 end
 angle=(angle+((right and 1 or 0)-(left and 1 or 0))*dt*3.4)%(2*math.pi)
 tilt=math.max(-.65,math.min(.65,tilt+((down and 1 or 0)-(up and 1 or 0))*dt*1.8))
 local back=math.cos(angle)<-.72
 if id=='collar'and back then bag.clueRevealed=true end
 if left or right or up or down then reading=nil end
 if b and not previousB then
  if id=='collar'and back and bag.clueRevealed and not bag.collected.back_key39 then
   if not bag.collarBoxOpen then bag.collarBoxOpen=true;reading='Abri a caixinha. Ha uma chave dentro.'
   else
    question:ask('Pegar a chave?',function()
     for i,item in ipairs(bag.bag)do if item=='collar'then bag.bag[i]='back_key39';bag.selected=i;break end end
     bag.collected.back_key39=true;id='back_key39';angle,tilt=0,0
     reading='Retirei uma pequena chave da coleira.'
    end)
   end
  elseif id=='back_key39' then reading='Uma etiqueta desbotada diz: Fundos - 39.'
  elseif id=='collar'and back and bag.collected.back_key39 then reading='A caixinha em forma de osso esta vazia.'
  else reading='Uma coleira velha e suja. Ha um nome gravado: Cloe.'end
 end
 local close=a and not previousA;previousB,previousA=b,a
 if close then P.active=false;mesh=nil;bag=nil;buffers={};return true end
end
local palette=require('clue214_palette')
local sprites
local inspectionSlots339
local inspectionKeys339={4330,6446,2183,2184,13877,12891,6513,10574,9549,5423,7435,24412,20152,9516,6580,19230,7469,5287,5354,8459,3241,5389,6614,7705,5388,4332,3139,6547,6546,5457,4366,2149,10540,1127,9482,5490,9483,7367,5253,3207,2148,2217,12721,3172,1092,4230,1057,3173}
function P.draw(ui)
 ui.cls(240);ui.palset(240,0);ui.palset(241,32767)
 if not inspectionSlots339 then local by={};for i,c in ipairs(require('palette'))do by[c]=i-1 end;inspectionSlots339={};for i,c in ipairs(inspectionKeys339)do inspectionSlots339[i]=assert(by[c],'Inspection palette missing')end end
 for i,c in ipairs(palette)do ui.palset(inspectionSlots339[i],c)end
 if not sprites then sprites=require('sprites')end
 local frame=math.floor(angle/(2*math.pi)*16+.5)%16
 local level=tilt>.15 and 1 or 0
 local state=id=='back_key39'and 'key'or(bag.collarBoxOpen and frame>=5 and frame<=11 and 'open'or 'closed')
 if state=='key'then level=0 end
 local name='inspect214_'..state..'_'..level..'_'..frame
 ui.spr(sprites[name]or name,112,20)
 if reading then ui.print(reading,28,210,241)
 elseif id=='collar'and math.cos(angle)<-.72 then ui.print(bag.collarBoxOpen and 'Ha uma chave dentro da caixinha.'or 'Ha uma pequena tampa no verso do ossinho.',28,210,241)end
 if question.active then question:draw(ui)else ui.print('DIRECIONAL: GIRAR   B: EXAMINAR   A: VOLTAR',24,248,241)end
end
return P
