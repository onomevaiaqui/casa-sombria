local S={phase=nil,choice=1,pending={}}
local inv,capture,restore
local function copy(v,depth)
 if type(v)~='table'then return type(v)~='function'and type(v)~='userdata'and type(v)~='thread'and v or nil end
 if(depth or 0)>8 then return nil end
 local r={};for k,x in pairs(v)do if type(k)=='number'or type(k)=='string'then local c=copy(x,(depth or 0)+1);if c~=nil then r[k]=c end end end;return r
end
S.copy=copy
function S.primitives(t)local r={};for k,v in pairs(t)do if type(v)=='number'or type(v)=='string'or type(v)=='boolean'then r[k]=v end end;return r end
local function encode(v)
 if type(v)=='table'then local out={'{'};for k,x in pairs(v)do out[#out+1]='['..encode(k)..']='..encode(x)..','end;out[#out+1]='}';return table.concat(out)
 elseif type(v)=='string'then return string.format('%q',v)
 elseif type(v)=='number'and v==v and math.abs(v)<1e12 then return tostring(v)
 elseif type(v)=='boolean'then return tostring(v)end
 return 'nil'
end
local function read(path)
 if not io or not io.open then return end
 local ok,result=pcall(function()local f=io.open(path,'rb');if not f then return end;local s=f:read('*a');f:close();return s end);if ok then return result end
end
local browser=read('/loaded_game/save680.browser')~=nil
local path=browser and'/loaded_game/save680.dat'or'save680.dat'
local function decode(text)
 if not text or #text>65536 or text:sub(1,7)~='return 'then return end
 local fn=load(text,'saved game','t',{});if not fn then return end
 local ok,d=pcall(fn);if ok and type(d)=='table'and d.version==1 and type(d.inventory)=='table'and type(d.inventory.bag)=='table'and type(d.inventory.collected)=='table'then return d end
end
function S.exists()return S.lastData~=nil or decode(read(path))~=nil end
function S.configure(i,c,r)inv,capture,restore=i,c,r end
function S.applyEnemy(name,obj)local data=S.pending[name];if data then for k,v in pairs(data)do obj[k]=v end;S.pending[name]=nil end end
function S.load()
 local d=S.lastData or decode(read(path));if not d or not restore then return false end
 S.phase=nil;restore(d);return true
end
function S.trackEnemy(name,obj)S.tracked=S.tracked or{};S.tracked[name]=obj end
function S.beginCodeEntry()
 require('code_entry702').begin(function(code)
  local d,err=require('save_code702').decode(code);if not d then return false,err end
  if not restore then return false,'Jogo ainda nao carregado.'end
  S.phase=nil;S.lastData=copy(d);restore(d);return true
 end)
end
function S.codeEntryActive()return require('code_entry702').active end
function S.codeEntryTick(ui)return require('code_entry702').tick(ui)end
function S.save()
 if not inv or not capture then return false,'Nao foi possivel salvar.'end
 local index;for i,id in ipairs(inv.bag)do if id=='phone_token'then index=i;break end end
 if not index then return false,'Preciso de uma ficha telefonica para salvar.'end
 table.remove(inv.bag,index)
 local ok,data=pcall(capture)
 if not ok then table.insert(inv.bag,index,'phone_token');return false,'Nao foi possivel gerar o codigo. Ficha devolvida.'end
 data.version=1
 local code,err=require('save_code702').encode(data)
 if not code then table.insert(inv.bag,index,'phone_token');return false,'Nao foi possivel gerar o codigo. Ficha devolvida.'end
 S.lastData=copy(data);S.code=code
 -- The browser keeps its existing automatic persistence in addition to the code.
 if browser then
  pcall(function()
   local text='return '..encode(data);local f=assert(io.open(path,'wb'));assert(f:write(text));assert(f:close())
   print('SAVE680|'..text:gsub('.',function(c)return string.format('%02x',c:byte())end))
  end)
 end
 inv.selected=math.max(1,math.min(inv.selected,#inv.bag))
 return true,'Codigo gerado. Uma ficha foi utilizada.'
end
function S.near(x,y)return(x+3.678833)^2+(y+4.80)^2<1.05^2 end
function S.begin(i)
 inv=i;S.choice=1;S.left,S.right=true,true;S.phase='intro';return true
end
function S.busy()return S.phase~=nil end
function S.input(left,right,b,a)
 if not S.phase then return end
 if a then S.phase=nil;return end
 if left and not S.left then S.choice=1 end;if right and not S.right then S.choice=2 end;S.left,S.right=left,right
 if not b then return end
 if S.phase=='intro'then
  if inv:has('phone_token')then S.phase='confirm';S.choice=1 else S.phase=nil end
 elseif S.phase=='confirm'then
  if S.choice==2 then S.phase=nil;return end
  if not inv:has('phone_token')then S.phase='intro';return end
  local ok,msg=S.save();S.message=msg;S.phase=ok and'code'or'result'
 else S.phase=nil end
end
function S.draw(ui)
 if not S.phase then return end
 -- Use the scene's reserved subtitle colours; never overwrite the actor palette.
 local text=require('subtitles').text
 if S.phase=='code'then
  ui.palset(240,0);ui.palset(241,32767);ui.palset(242,21140);ui.cls(240)
  ui.print('CODIGO DE RETOMADA',24,18,241)
  ui.print('Uma ficha telefonica foi utilizada.',24,43,242)
  local code=require('save_code702').format(S.code or'UE1-');local row,line=0,''
  for part in code:gmatch('[^-]+')do if #line+#part+1>44 then ui.print(line,24,73+row*17,241);row=row+1;line=part else line=line==''and part or(line..'-'..part)end end
  if line~=''then ui.print(line,24,73+row*17,241)end
  ui.print('Anote ou fotografe este codigo.',24,214,242)
  ui.print('Menu: RETOMAR POR CODIGO.',24,233,242)
  ui.print('B / A: FECHAR',24,253,242)
 elseif S.phase=='intro'then
  text(ui,'Um telefone publico. Preciso de fichas para usar.',32,221,68)
  text(ui,inv:has('phone_token')and'B: CONTINUAR    A: VOLTAR'or'B / A: VOLTAR',32,250,68)
 elseif S.phase=='confirm'then
  text(ui,'Salvar jogo?',32,207,68)
  text(ui,S.choice==1 and'> Sim       Nao'or'  Sim     > Nao',32,229,68)
  text(ui,'B: CONFIRMAR    A: CANCELAR',32,250,68)
 else text(ui,S.message or'',32,221,68);text(ui,'B / A: VOLTAR',32,250,68)end
end
function S.icon(ui,x,y)return require('token681').icon(ui,x,y)end
return S
