local E={active=false,text='',cursor=0,error=nil}
local alphabet='23456789ABCDEFGHJKLMNPQRSTUVWXYZ'
local previous={}
local callback
local function held(k)local v=ui.btn(k,0);return v==true or(type(v)=='number'and v>0)end
function E.begin(done)E.active=true;E.text='';E.cursor=0;E.error=nil;callback=done;previous={b=true};if ui and type(ui.readtext)=='function'then for _=1,128 do if not ui.readtext()then break end end end end
local function accept()
 local ok,message=callback('UE1-'..E.text)
 if ok then E.active=false else E.error=message or'Codigo invalido.'end
end
function E.tick(ui)
 local keys={l=held(LEFT or 0),r=held(RIGHT or 1),u=held(UP or 2),d=held(DOWN or 3),b=held(BTN_Z or 4),a=held(BTN_G or 13)}
 if keys.a and not previous.a then E.active=false;return end
 for _,p in ipairs{{'l',-1},{'r',1},{'u',-8},{'d',8}}do if keys[p[1]]and not previous[p[1]]then E.cursor=(E.cursor+p[2])%34 end end
 local typed=false;local enter=false
 if type(ui.readtext)=='function'then
  local chars={};for _=1,128 do local c=ui.readtext();if not c then break end;chars[#chars+1]=c end
  typed=#chars>0
  local raw=table.concat(chars);enter=raw:find('\n',1,true)~=nil or raw:find('\r',1,true)~=nil
  local s=raw:upper():gsub('%s',''):gsub('-','');if s:sub(1,3)=='UE1'then s=s:sub(4)end
  for i=1,#s do local c=s:sub(i,i);if alphabet:find(c,1,true)and #E.text<1024 then E.text=E.text..c;E.error=nil end end
 end
 if enter then accept()end
 if keys.b and not previous.b and not typed then
  if E.cursor<32 then if #E.text<1024 then E.text=E.text..alphabet:sub(E.cursor+1,E.cursor+1);E.error=nil end
  elseif E.cursor==32 then E.text=E.text:sub(1,-2);E.error=nil else accept()end
 end
 previous=keys
 ui.palset(240,0);ui.palset(241,32767);ui.palset(242,21140);ui.cls(240)
 ui.print('RETOMAR POR CODIGO',24,15,241);ui.print('UE1-',24,39,242)
 local shown=E.text:sub(math.max(1,#E.text-143));for i=1,#shown,48 do ui.print(shown:sub(i,i+47),24,54+((i-1)//48)*14,241)end
 for i=0,31 do local x=56+(i%8)*46;local y=116+(i//8)*23;if E.cursor==i then ui.rect(x-5,y-4,x+16,y+13,241)end;ui.print(alphabet:sub(i+1,i+1),x,y,241)end
 ui.print((E.cursor==32 and'> 'or'  ')..'APAGAR',62,214,241);ui.print((E.cursor==33 and'> 'or'  ')..'CARREGAR',270,214,241)
 ui.print(E.error or'DIRECIONAL: ESCOLHER   B: CONFIRMAR',24,240,242);ui.print('A: VOLTAR',24,255,242)
end
return E
