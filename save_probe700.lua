-- Read-only firmware 0.7 follow-up: inspect nonstandard API tables and builtin modules.
local P={active=true,page=1}
local rows,leftPrev,rightPrev,bPrev
local function add(s)rows[#rows+1]=s end
local function words(prefix,values)
 local line=prefix
 for _,v in ipairs(values)do if #line+#v+2>65 then add(line);line='  'end;line=line..v..', 'end
 if line~=prefix then add(line:sub(1,-3))end
end
local function scan()
 rows={};add('Firmware informado: 0.7 - teste complementar')
 local checked,found={},{}
 local function inspect(label,v)
  if type(v)~='table'then return end
  local names={};local ok=pcall(function()for k,f in pairs(v)do if type(k)=='string'and type(f)=='function'then names[#names+1]=k end end end)
  if ok then table.sort(names);checked[#checked+1]=label;words(label..': ',names)
   for _,k in ipairs(names)do local n=k:lower();if n:find('save',1,true)or n:find('write',1,true)or n:find('stor',1,true)or n:find('persist',1,true)or n:find('file',1,true)or n:find('nvs',1,true)then found[#found+1]=label..'.'..k end end
  end
 end
 for k,v in pairs(_G or{})do
  if type(k)=='string'and k~='_G'and k~='Sprites'and k~='Palette'and k~='math'and k~='table'and k~='string'and k~='utf8'and k~='package'and k~='ui'then inspect(k,v)end
 end
 add('--- Modulos internos (somente require) ---')
 local absent={}
 for _,name in ipairs{'storage','save','persist','filesystem','fs','file','nvs','settings','config','data','memory','system'}do
  local ok,v=pcall(require,name)
  if ok then add(name..' encontrado: '..type(v));inspect(name,v)else absent[#absent+1]=name end
 end
 words('Nao encontrados: ',absent)
 add('--- Resultado ---')
 if #found>0 then words('Candidatos: ',found)else add('Nenhuma funcao de gravacao identificada.')end
 add('Nenhuma funcao candidata foi executada.')
end
local function held(k)local v=ui.btn(k,0);return v==true or(type(v)=='number'and v>0)end
function P.tick()
 if not rows then scan()end
 local l,r,b=held(LEFT or 0),held(RIGHT or 1),held(BTN_X or BTN_Z or 4);local pages=math.max(1,math.ceil(#rows/13))
 if l and not leftPrev then P.page=math.max(1,P.page-1)end
 if r and not rightPrev then P.page=math.min(pages,P.page+1)end
 if b and not bPrev then P.active=false end
 leftPrev,rightPrev,bPrev=l,r,b
 ui.palset(240,0);ui.palset(241,32767);ui.palset(242,21140);ui.cls(240)
 ui.print('DIAGNOSTICO COMPLEMENTAR - 16.49',12,12,241);ui.print('PAGINA '..P.page..' / '..pages,12,33,242)
 for i=1,13 do local s=rows[(P.page-1)*13+i];if s then ui.print(s,12,53+(i-1)*13,241)end end
 ui.print('DIRECIONAL: PAGINAS   ACAO: JOGO',12,237,242);ui.print('Somente leitura. Nenhum dado foi gravado.',12,253,242)
end
function P.report()if not rows then scan()end;return rows end
return P
