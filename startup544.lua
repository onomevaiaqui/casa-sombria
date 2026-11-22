local B={label='ABRIR JOGO',error=nil,loaded=false}
local core,frames= nil,0
local pending=1
local modules={} -- Compile the core before dependency tables occupy the Lua heap.
local reserve=string.rep(' ',16384)
local function memory()if type(collectgarbage)=='function'then local ok,k=pcall(collectgarbage,'count');if ok then return math.floor(k)end end;return 0 end
function B.stage(label)B.label=label end
local function canvas()
 if type(ui.camera)=='function'then ui.camera(0,0)end
 if type(ui.clip)=='function'then ui.clip(0,0,480,270)end
 ui.palset(240,0);ui.palset(241,32767);ui.cls(240)
end
local function fail(err)
 reserve=nil;core=nil
 if type(collectgarbage)=='function'then pcall(collectgarbage,'collect')end
 B.error=tostring(err);B.loaded=false
end
function B.tick()
 if B.error then
  canvas();ui.print('16.50 - FALHA NA INICIALIZACAO',10,15,241)
  ui.print('ETAPA: '..B.label,10,37,241)
  ui.print('MEMORIA LUA: '..memory()..' KB',10,55,241)
  local row=0
  for line in (B.error..'\n'):gmatch('(.-)\n')do
   for p=1,math.max(1,#line),70 do ui.print(line:sub(p,p+69),10,80+row*13,241);row=row+1;if row>=11 then break end end
   if row>=11 then break end
  end
  ui.print('Envie uma foto desta tela.',10,246,241);return
 end
 if not B.loaded then
  frames=frames+1;canvas();ui.print('16.50 - CARREGANDO JOGO',14,85,241)
  ui.print('MEMORIA LUA: '..memory()..' KB',14,110,241)
  if frames<3 then return end
  if modules[pending]then
   B.label='MODULO '..modules[pending];ui.print(B.label,14,135,241)
   local ok,err=pcall(require,modules[pending]);if not ok then fail(err);return end
   if type(collectgarbage)=='function'then pcall(collectgarbage,'collect')end
   pending=pending+1;return
  end
  local ok,err=pcall(require,'game_core697')
  local candidate=update;update=function()B.tick()end
  if not ok then fail(err);return end
  core=candidate;B.loaded=true;reserve=nil
  if type(collectgarbage)=='function'then pcall(collectgarbage,'collect')end
  return
 end
 local ok,err=pcall(core)
 if not ok then fail(err)end
end
return B
