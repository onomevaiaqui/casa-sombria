LEFT,RIGHT,UP,DOWN=0,1,2,3
package.preload.sprites=function()return dofile('.tools/sprites168.lua')end
package.preload.palette=function()return dofile('.tools/palette142.lua')end
local keys,texts={},{}
ui={cls=function()end,btn=function(i)return keys[i]or false end,stat=function()return 60 end,palset=function()end,print=function(s)texts[#texts+1]=s end,rectfill=function()end,rect=function()end,line=function()end,trisfill=function()end,spr=function()end}
dofile('game.lua')
local function get(k)for i=1,100 do local n,v=debug.getupvalue(update,i);if n==k then return v,i end end;error(k)end
local function set(k,v)local _,i=get(k);debug.setupvalue(update,i,v)end
local P=require('photo162');local M=require('metric_rooms');local I=get('inventory');local E=require('enemy153')
set('titleOpen',false);set('currentRoom','quarto');local sx,sy=M.project('quarto',3.5,3.0,0);set('x',sx);set('y',sy)
assert(M.walkable('quarto',sx,sy),'photo approach blocked')
local bx,by=M.project('quarto',3.5,3.58,0);assert(not M.walkable('quarto',bx,by),'new stand has no collision')
update();keys[BTN_Z or 4]=true;update();assert(P.active,'photo interaction did not open')
assert(I.files[#I.files]=='family_photo'and #I.bag==3,'photo should be archived outside six slots')
keys[BTN_Z or 4]=nil;update();assert(not P.found)
texts={};P.draw(ui);assert(not table.concat(texts,' '):find('2019'),'front leaks clue')
for i=1,30 do P.tick(1/30,false,true,false,false,false,false)end
assert(P.found,'back clue not discovered');texts={};P.draw(ui);assert(table.concat(texts,' '):find('Catarina %- 2019'))
P.tick(.01,false,false,false,false,false,true);assert(not P.active)
-- Re-open from the archived photo.
I:open();I.tab=2;I.focus='files';I.fileSelected=#I.files;I.previous={};I:handle(false,false,false,false,true,'quarto');assert(P.active)
-- Bounded inspection buffers across repeated rotations.
collectgarbage('collect');local before=collectgarbage('count')
for i=1,2000 do P.tick(1/60,false,true,false,false,false,false);P.draw(ui);for j=#texts,1,-1 do texts[j]=nil end end
collectgarbage('collect');assert(collectgarbage('count')-before<8,'inspection retains allocations')
P.reset();assert(not P.found and not P.active)
print('PASS second stand collision/access, environmental interaction, archive, hidden back clue, rotation, close and bounded memory')
