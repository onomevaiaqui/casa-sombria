-- Temporary console diagnostics: no images or model changes.
local D={pending=false,label='MENU',error=nil}
local tasks,index,wait
local emergency=string.rep(" ",2048)
function D.stage(label)D.label=label end
function D.queue(list)tasks=list;index=1;wait=4;D.pending=true;D.error=nil end
local function canvas()
 if type(ui.camera)=='function'then ui.camera(0,0)end
 if type(ui.clip)=='function'then ui.clip(0,0,480,270)end
 ui.palset(240,0);ui.palset(241,32767);ui.cls(240)
end
function D.tick()
 local task=tasks[index]
 if not task then tasks=nil;D.pending=false;D.label='PRIMEIRO QUADRO';return end
 D.label=task[1]
 canvas();ui.print('15.93 - INICIANDO PARTIDA',16,35,241)
 ui.print('ETAPA '..index..'/'..#tasks..': '..D.label,16,65,241)
 if wait>0 then wait=wait-1;return end
 task[2]();index=index+1;wait=4
end
function D.fail(err)D.error=tostring(err);D.pending=false;tasks=nil;emergency=nil;if type(collectgarbage)=='function'then pcall(collectgarbage,'collect')end end
function D.drawError()
 canvas();ui.print('15.93 - FALHA CAPTURADA',12,16,241)
 ui.print('ETAPA: '..D.label,12,36,241)
 local text=D.error or 'Erro sem mensagem';local row=0
 for line in (text..'\n'):gmatch('(.-)\n')do
  local textLine=#line==0 and ' 'or line
  for p=1,#textLine,72 do ui.print(textLine:sub(p,p+71),12,62+row*13,241);row=row+1;if row>=12 then break end end
  if row>=12 then break end
 end
 ui.print('FOTOGRAFE ESTA TELA. A: MENU',12,248,241)
end
function D.reset()tasks=nil;D.pending=false;D.error=nil;D.label='MENU'end
return D
