local B={label='PREPARAR JOGO',error=nil,loaded=false}
local initializer,core,frames=nil,nil,0
local pending=1
local inputFrames=0;local inputPrevious={}
local function inputTrace()
 inputFrames=inputFrames+1;if inputFrames>1800 then return end
 local names={'BTN_Z','BTN_X','BTN_Q','BTN_E','BTN_F','BTN_G','BTN_A','BTN_B','UP','DOWN'}
 for _,name in ipairs(names)do local key=_G[name];if type(key)=='number'then local ok,v=pcall(ui.btn,key,0);local down=ok and(v==true or type(v)=='number'and v>0);if down and not inputPrevious[name]then if type(ui.log)=='function'then pcall(ui.log,'INPUT719 '..name..'='..key)else print('INPUT719 '..name..'='..key)end end;inputPrevious[name]=down end end
end
local modules={'save680','sprite_refs697','boot349','interaction287','death171','shutter169','turn168','progression167','photo162','survival158','steering157','enemy153','window_enemy563','gc150','frame_time','metric_rooms','cameras168','doors131','passage156','lock158','crowbar160','combat164','interactions','subtitles','perspective','navigation'}
local reserve=string.rep(' ',8192)
local function memory()local ok,k=pcall(collectgarbage,'count');return ok and math.floor(k)or 0 end
local function log(message)if type(ui.log)=='function'then pcall(ui.log,'BOOT716 '..message)else print('BOOT716 '..message)end end
function B.stage(label)B.label=label;log(label)end
local function canvas()
 if type(ui.camera)=='function'then ui.camera(0,0)end
 if type(ui.clip)=='function'then ui.clip(0,0,480,270)end
 ui.palset(240,0);ui.palset(241,32767);ui.cls(240)
end
local function fail(err)
 reserve=nil;core=nil;initializer=nil;pcall(collectgarbage,'collect');B.error=tostring(err);B.loaded=false;log('FAIL '..B.label..': '..B.error)
end
function B.tick(frame)
 if B.error then
  canvas();ui.print('16.56 - FALHA NA INICIALIZACAO',10,15,241);ui.print('ETAPA: '..B.label,10,37,241);ui.print('MEMORIA LUA: '..memory()..' KB',10,55,241)
  local row=0
  for line in(B.error..'\n'):gmatch('(.-)\n')do for p=1,math.max(1,#line),70 do ui.print(line:sub(p,p+69),10,80+row*13,241);row=row+1;if row>=11 then break end end;if row>=11 then break end end
  ui.print('Envie uma foto desta tela.',10,246,241);return
 end
 if not B.loaded then
  frames=frames+1;canvas();ui.print('16.56 - CARREGANDO JOGO',14,70,241);ui.print('MEMORIA LUA: '..memory()..' KB',14,95,241);ui.print('ETAPA: '..B.label,14,120,241)
  ui.print('QUADRO: '..frames,14,145,241)
  if frames<3 then return end
  if not initializer then
   B.stage('COMPILAR NUCLEO');local ok,result=pcall(require,'game_core697');if not ok then fail(result);return end
   if type(result)~='function'then fail('Inicializador do jogo ausente');return end
   initializer=result;pcall(collectgarbage,'collect');return
  end
  if modules[pending]then
   B.stage('MODULO '..modules[pending]);local ok,result=pcall(require,modules[pending]);if not ok then fail(result);return end
   pending=pending+1;pcall(collectgarbage,'collect');return
  end
  B.stage('CONFIGURAR MENU');local ok,candidate=pcall(initializer)
  if not ok then fail(candidate);return end
  if type(candidate)~='function'then fail('Atualizacao do jogo ausente');return end
  core=candidate;B.loaded=true;initializer=nil;reserve=nil;pcall(collectgarbage,'collect');log('MENU READY '..memory()..' KB');log('KEYS Z='..tostring(BTN_Z)..' X='..tostring(BTN_X)..' G='..tostring(BTN_G)..' Q='..tostring(BTN_Q)..' F='..tostring(BTN_F)..' E='..tostring(BTN_E));return
 end
 require('frame_time').consoleFrame=frame;local ok,err=pcall(core,frame);if not ok then fail(err)end
end
return B
