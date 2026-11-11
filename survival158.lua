local clip=require('player_death158')
local hit=require('player_hit161')
local L={hitClip=hit,hp=4,maxHp=4,dead=false,time=0,clip=clip}
function L.reset()L.hp=4;L.dead=false;L.time=0;L.hitTime=nil;L.previousA=true;L.previousB=true end
function L.damage()
 if L.dead then return false end
 L.hp=math.max(0,L.hp-1)
 if L.hp>0 then L.hitTime=0 end
 if L.hp==0 then L.dead=true;L.time=0;L.hitTime=nil;L.previousA=true;L.previousB=true end
 return true
end
function L.heal(amount)
 if L.dead or L.hp<=0 or L.hp>=L.maxHp then return 0 end
 local before=L.hp
 L.hp=math.min(L.maxHp,L.hp+math.max(0,amount or 0))
 return L.hp-before
end
function L.tick(dt)if L.dead then L.time=math.min(clip.duration,L.time+dt)end;if L.hitTime then L.hitTime=L.hitTime+dt;if L.hitTime>=hit.duration then L.hitTime=nil end end end
function L.input(a,b)
 local action
 if L.dead and L.time>=clip.duration then
  if b and not L.previousB then action='retry'elseif a and not L.previousA then action='menu'end
 end
 L.previousA,L.previousB=a,b;return action
end
function L.hud(ui)
 if L.dead then require('death171').draw(ui,L);return end
 ui.rectfill(0,28,139,38,240);ui.print('VIDA '..L.hp..'/4',8,30,241)
end
return L
