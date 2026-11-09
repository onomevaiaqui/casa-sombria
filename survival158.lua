local clip=require('player_death158')
local L={hp=4,maxHp=4,dead=false,time=0,clip=clip}
function L.reset()L.hp=4;L.dead=false;L.time=0;L.previousA=true;L.previousB=true end
function L.damage()
 if L.dead then return false end
 L.hp=math.max(0,L.hp-1)
 if L.hp==0 then L.dead=true;L.time=0;L.previousA=true;L.previousB=true end
 return true
end
function L.tick(dt)if L.dead then L.time=math.min(clip.duration,L.time+dt)end end
function L.input(a,b)
 local action
 if L.dead and L.time>=clip.duration then
  if b and not L.previousB then action='retry'elseif a and not L.previousA then action='menu'end
 end
 L.previousA,L.previousB=a,b;return action
end
function L.hud(ui)
 ui.rectfill(0,28,139,38,240);ui.print('VIDA '..L.hp..'/4',8,30,241)
 if L.dead and L.time>=clip.duration then
  ui.rectfill(102,88,378,180,240);ui.print('VOCE MORREU',192,106,241)
  ui.print('B: TENTAR NOVAMENTE',142,132,241);ui.print('A: MENU INICIAL',154,152,241)
 end
end
return L
