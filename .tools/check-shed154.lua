local M=require('metric_rooms');local D=require('doors131');local S=require('shed154');local inv=require('inventory').new({})
D.reset();local ok,pages=S.tryOpen(inv,D,'quintal',1.8,5.85);assert(not ok and #pages==2 and not D.isOpen('casinha'))
assert(not inv:has('shed_key'));inv.bag[#inv.bag+1]='shed_key'
ok,pages=S.tryOpen(inv,D,'quintal',1.8,5.85);assert(ok and D.isOpen('casinha')and D.stateMask({128})==128)
local x,y=M.project('corredor',2.7,.9,0);local p=inv:nearby('corredor',x,y);assert(not p or p.id~='crowbar','first weapon still in corridor')
x,y=M.project('ferramentas',1.5,1.95,0);p=inv:nearby('ferramentas',x,y);assert(p and p.id=='crowbar')
assert(inv:collect(p)=='ITEM COLETADO'and inv:has('crowbar'));assert(not inv:nearby('ferramentas',x,y),'weapon can be collected twice')
D.reset();local sx,sy=M.project('quintal',1.8,6.5,0);assert(not M.walkable('quintal',sx,sy),'shed threshold leaks without room transition')
print('PASS shed locked without key, unlock with key, first crowbar only inside, one-time collection, solid shed walls')
