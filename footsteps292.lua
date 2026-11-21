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
 require('audio697').effect(surface);M.status='FUR NATIVO'
end

function M.houseSurface(room,x,y)
 if room=='banheiro'then return 'azulejo'end
 if room=='quintal'then return 'grama'end
 if room=='frente'then
  if y<1 or (x>13.1 and x<15.7)then return 'calcada'end
  return 'grama'
 end
 if room=='garagem'or room=='area'then return 'azulejo'end
 return 'madeira'
end
local field624='gggggggggggggggggggggggggggggggggttttttggggggggggggggttggttttttggggggggggggggtggttttttttggtgtgggggggggttttttttttttgtgttgggggggtttttttttttttggttgggtggttgttttttttttttttgggtttttttttttttttttttgggggggtttttttttttttttgtggggggggttttttttttttttttgggggggtttttttttttttttttgggggggtttttttttttttttttgtgggggggtttttttttttttgggtgggggtttttttttttttttttgggggggtttttttttttttttttggggggggttttttttttttttttgggggggtgtttttttttttttttgggggggggtttttttttttttttggggggtgtttttttttttttttgttggggggtttttttttttttttttgggggggttgttttttttttttgggggggtttttttttttttttttgtgggggtttttttttttttttttttgggggttttttttttttttttttggggggtttttttttttttttttttttgggtggtttttttttttttttgggggggggttttttttttttttttgggtggttttttttttttttttgttggggggtttttgttttttttgtggggggtttttttttttttttttttgggggttgttttttttttttttttgggggttgtggttttttttttttggggggggggtttttttttttggttgggggggggggtttttttggggggggggggggggggttttttggggggggggggggggggggggggggggggggg'
function M.fieldSurface(x,y)
 local ix=math.floor((x-.5)/23*24);local iy=math.floor((y-4.5)/35*36)
 if ix<0 or ix>=24 or iy<0 or iy>=36 then return 'grama'end
 return field624:sub(iy*24+ix+1,iy*24+ix+1)=='g'and 'grama'or 'terra'
end

return M
