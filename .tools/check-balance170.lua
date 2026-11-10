local E=require('enemy153');local M=require('metric_rooms');local P=require('progression167')
for _,case in ipairs({{false,5,8},{true,4,12}})do
 E.reset();assert(E.hp==4 and E.maxHp==4)
 local angle=M.facing('frente',0,1)
 for n=1,case[2]do
  assert(E.tryHit('frente',E.x,E.y-.8,angle,case[1]))
  assert(E.hp==math.max(0,40-case[3]*n)/10)
  assert(P.defeated(E)==(n==case[2]))
  assert(E.state==(n==case[2]and 'dying'or 'alive'))
 end
 assert(not E.tryHit('frente',E.x,E.y-.8,angle,case[1]))
end
E.reset();local a=M.facing('frente',0,1)
for _,baton in ipairs({true,false,true,false})do assert(E.tryHit('frente',E.x,E.y-.8,a,baton))end
assert(E.hp==0 and E.state=='dying');E.reset();assert(E.hp==4)
print('PASS balance: hatchet 1.2 (4 hits), punch 0.8 (5 hits), mixed hits, immediate death and reset')
