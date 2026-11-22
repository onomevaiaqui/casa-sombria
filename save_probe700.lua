-- Read-only capability report. Never invokes storage, network or unknown functions.
local P={active=true,page=1}
local rows,previousLeft,previousRight,previousB
local function add(s)rows[#rows+1]=s end
local function scan()
 rows={};add('Alvo: firmware informado 0.7')
 local root=_G or{};local keys={}
 for k,v in pairs(root)do if type(k)=='string'then keys[#keys+1]=k end end;table.sort(keys)
 local matches=0
 for _,k in ipairs(keys)do
  local v=root[k];local lower=k:lower()
  local candidate=lower:find('save',1,true)or lower:find('stor',1,true)or lower:find('persist',1,true)or lower:find('file',1,true)or lower:find('flash',1,true)or lower:find('nvs',1,true)or k=='fs'or k=='io'or k=='sys'or k=='system'or k=='data'or k=='memory'
  if candidate then add(k..' : '..type(v));matches=matches+1 end
  if type(v)=='table'and(k=='ui'or candidate)then
   local members={};local ok=pcall(function()for n,x in pairs(v)do if type(n)=='string'and type(x)=='function'then members[#members+1]=n end end end)
   if ok then table.sort(members);for _,n in ipairs(members)do add(k..'.'..n..'()');matches=matches+1 end end
  end
 end
 if matches==0 then add('Nenhuma API candidata visivel.')end
 add('--- Funcoes globais disponiveis ---')
 for _,k in ipairs(keys)do if type(root[k])=='function'then add(k..'()')end end
 add('--- Tabelas disponiveis ---')
 for _,k in ipairs(keys)do if type(root[k])=='table'and k~='_G'then add(k)end end
end
local function held(k)local v=ui.btn(k,0);return v==true or(type(v)=='number'and v>0)end
function P.tick()
 if not rows then scan()end
 local left,right,b=held(LEFT or 0),held(RIGHT or 1),held(BTN_X or BTN_Z or 4)
 if left and not previousLeft then P.page=math.max(1,P.page-1)end
 local pages=math.max(1,math.ceil(#rows/13))
 if right and not previousRight then P.page=math.min(pages,P.page+1)end
 if b and not previousB then P.active=false end
 previousLeft,previousRight,previousB=left,right,b
 ui.palset(240,0);ui.palset(241,32767);ui.palset(242,21140);ui.cls(240)
 ui.print('DIAGNOSTICO DE SAVE - 16.48',12,12,241)
 ui.print('PAGINA '..P.page..' / '..pages,12,33,242)
 for i=1,13 do local s=rows[(P.page-1)*13+i];if s then ui.print(s:sub(1,70),12,53+(i-1)*13,241)end end
 ui.print('DIRECIONAL: PAGINAS   ACAO: JOGO',12,237,242)
 ui.print('Somente leitura; nenhum dado foi alterado.',12,253,242)
end
function P.report()if not rows then scan()end;return rows end
return P
