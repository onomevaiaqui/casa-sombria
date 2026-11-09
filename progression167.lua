-- Story locks use existing door/enemy state. No invented key or new save flag.
local P={}
local entrance='Tem alguma coisa la fora. Melhor encontrar alguma coisa para me defender.'
local inner='Parece estar trancada pelo outro lado.'
function P.defeated(enemy)return enemy.hp<=0 end
function P.message(id,room,enemy,doors)
 if id=='entrada'and not P.defeated(enemy)then return entrance end
 if id=='garagem'and room=='corredor'and not doors.isOpen(id)then return inner end
 if id=='garagem_externa'and not doors.isOpen(id)then
  return room=='garagem'and 'A porta de rolo esta travada. O mecanismo fica do lado de fora.'or 'Preciso encontrar algo para abrir esta porta.'
 end
end
function P.blockedPassage(from,to,enemy)
 return((from=='sala'and to=='area')or(from=='area'and to=='sala'))and not P.defeated(enemy)
end
-- Future exterior item calls this only after its puzzle/use has succeeded.
function P.releaseGarage(doors)doors.open('garagem_externa')end
return P
