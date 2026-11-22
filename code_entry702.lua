local E={active=false,text='',cursor=0,error=nil,phase=nil,clock=0}
local labels={'1','2','3','4','5','6','7','8','9','<','0','OK'}
local previous={};local callback
local function held(k)local v=ui.btn(k,0);return v==true or(type(v)=='number'and v>0)end
function E.begin(done)
 E.active=true;E.text='';E.cursor=0;E.error=nil;E.phase=nil;E.clock=0;callback=done;previous={b=true}
 if type(ui.readtext)=='function'then for _=1,128 do if not ui.readtext()then break end end end
end
local function accept()
 if E.phase or #E.text~=7 then return end
 local info=require('phone_checkpoints703').info(E.text)
 E.phase=info and 'ring'or 'busy';E.clock=0;E.error=nil
 require('sound626').emit(info and 'telefone_toca'or 'telefone_desligado')
end
function E.tick(ui)
 local keys={l=held(LEFT or 0),r=held(RIGHT or 1),u=held(UP or 2),d=held(DOWN or 3),b=held(BTN_Z or 4),a=held(BTN_G or 13)}
 if E.phase then
  E.clock=E.clock+(require('frame_time').dt or 1/60)
  if E.phase=='busy'and E.clock>=.85 then E.phase=nil;E.text='';E.cursor=0;E.error='Numero incorreto. Tente novamente.'
  elseif E.phase=='ring'and E.clock>=1.9 then
   local ok,message=callback(E.text)
   if ok then E.active=false;previous=keys;return else E.phase=nil;E.text='';E.error=message end
  end
 else
  if keys.a and not previous.a then E.active=false;return end
  for _,p in ipairs{{'l',-1},{'r',1},{'u',-3},{'d',3}}do if keys[p[1]]and not previous[p[1]]then E.cursor=(E.cursor+p[2])%12 end end
  local typed=false
  if type(ui.readtext)=='function'then
   for _=1,128 do local c=ui.readtext();if not c then break end;typed=true
    for i=1,#c do local ch=c:sub(i,i);if ch:match('%d')and #E.text<7 then E.text=E.text..ch;E.error=nil elseif ch=='\b'then E.text=E.text:sub(1,-2)end end
   end
  end
  if keys.b and not previous.b and not typed then
   if E.cursor==9 then E.text=E.text:sub(1,-2);E.error=nil
   elseif E.cursor==11 then accept()
   elseif #E.text<7 then E.text=E.text..labels[E.cursor+1];E.error=nil end
  end
  if #E.text==7 then accept()end
 end
 previous=keys
 local fade=E.phase=='ring'and math.max(0,math.min(1,(E.clock-1.25)/.65))or 0
 local function color(c)local k=1-fade;return math.floor((c&31)*k)|(math.floor(((c>>5)&31)*k)<<5)|(math.floor(((c>>10)&31)*k)<<10)end
 ui.palset(240,0);ui.palset(241,color(32767));ui.palset(242,color(21140));ui.cls(240)
 ui.print('CONTINUAR - DIGITE O PASSWORD',24,15,241)
 local digits=E.text..string.rep('_',7-#E.text);require('phone_art703').draw(ui,digits:sub(1,3)..'-'..digits:sub(4),E.cursor,fade)
 ui.print(E.phase=='ring'and 'Chamando...'or E.phase=='busy'and 'Linha desligada...'or E.error or'DIRECIONAL: ESCOLHER   B: DISCAR',10,246,242)
 ui.print('*: APAGAR   7 DIGITOS: LIGAR   A: VOLTAR',10,260,242)
end
return E
