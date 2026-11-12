-- Recorded Hazard Pay footstep, converted offline to Furnace / NES PCM.
local M={status='PRONTO',count=0,preview=false}
local progress,cooldown,lastSurface=0,0,nil
local paths={calcada='music/passo_calcada',asfalto='music/passo_asfalto'}
function M.configure(preview)M.preview=not not preview end
function M.reset()progress=0;cooldown=0;lastSurface=nil end
function M.surface(x,y)
 if x>5.2 and y<12.7 then return nil end -- dirt passage: no pavement sound
 if y>=12 then
  local r=x*x+(y-18)^2
  return r>7.25^2 and 'calcada'or 'asfalto'
 end
 return math.abs(x)>=3.1 and 'calcada'or 'asfalto'
end
function M.tick(moved,dt,running,surface,paused)
 cooldown=math.max(0,cooldown-(dt or 0))
 if paused or not surface or moved<=.00001 then progress=0;lastSurface=nil;return end
 if surface~=lastSurface then progress=.72;lastSurface=surface end
 progress=progress+moved/(running and 1.5059204352 or .8788280859)
 if progress<1 or cooldown>0 then return end
 progress=progress%1;cooldown=.22;M.count=M.count+1
 if M.preview then print('STEP292|'..surface);M.status='PREVIA FUR';return end
 if type(music)~='table'or type(music.play)~='function'then M.status='SEM API';return end
 local ok,value,reason=pcall(music.play,paths[surface],0)
 if not ok or value==false or(value==nil and type(reason)=='string')then M.status='ERRO AUDIO'
 else M.status='FUR SOLICITADO'end
end
return M
