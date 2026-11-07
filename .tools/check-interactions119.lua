local I=require('interactions')
local S=require('subtitles')
assert(I.nearby('sala',1.4,2.45)==I.paintings)
assert(not I.nearby('sala',4,2.45)and not I.nearby('cozinha',1.4,2.45))
assert(I.paintings.pages[1]=='Um quadro representando dois rockeiros e o outro uma mulher na banheira. Léli 2015')
assert(I.paintings.pages[2]=='Parece uma ótima pintora')
local d=S.new();d:open(I.paintings.pages)
assert(d.total==utf8.len(I.paintings.pages[1])-1,'Wrapping must count Unicode glyphs and remove one inter-line space')
d:tick(.1);d:handle(true,false);assert(d.page==1 and d.revealed==d.total)
d:handle(true,false);assert(d.page==2 and d.revealed==0)
d:handle(false,true);assert(not d.active)
local accents=0
d:open({'Léli 2015','Parece uma ótima pintora'});d:handle(true,false)
d:draw({print=function(text,x,y,ink)
 assert(not text:find('[\128-\255]'),'Native font must receive ASCII plus custom accents')
 assert(x>=0 and x+#text*6<=480 and y>=0 and y<270)
end,line=function()accents=accents+1 end})
assert(accents>0,'Accent missing')

LEFT,RIGHT,UP,DOWN=0,1,2,3
local keys={};local sprites={}
for _,name in ipairs({'sala75','cozinha76','corredor100','banheiro100','quarto100','garagem100','quintal100','frente100','titulo103',
 'camera117_sala','camera117_cozinha','camera117_corredor','camera117_banheiro','camera117_quarto','camera117_garagem','camera117_quintal','camera117_frente'})do
 for i=0,2 do sprites[name..'_'..i]=true end
end
package.preload.sprites=function()return sprites end
local M=require('metric_rooms');local palette={0};for _,p in ipairs(M.bank)do palette[#palette+1]=p[1]end
package.preload.palette=function()return palette end
ui={btn=function(i)return keys[i]or false end,stat=function()return 60 end,cls=function()end,
 palset=function()end,print=function()end,line=function()end,rect=function()end,rectfill=function()end,
 trisfill=function()end,spr=function()end}
dofile('game.lua')
local function get(key)
 for i=1,100 do local name,value=debug.getupvalue(update,i);if name==key then return value,i end end
 error('missing '..key)
end
local function set(key,value)local _,i=get(key);debug.setupvalue(update,i,value)end
local function frame(k)keys=k or{};update()end
local function position(room,x,y)
 local sx,sy=M.project(room,x,y,0);assert(M.walkable(room,sx,sy))
 set('currentRoom',room);set('x',sx);set('y',sy);set('crossing',false);set('transitionCarry',nil)
end
frame({[4]=true});frame()
position('sala',1.4,2.45);frame({[4]=true})
local dialogue=get('dialogue');assert(dialogue.active and dialogue.page==1)
local x,y,phase=get('x'),get('y'),get('step')
for i=1,8 do frame({[4]=true,[1]=true,[12]=true,[15]=true})end
assert(get('x')==x and get('y')==y and get('step')==phase,'Reading must freeze movement and attacks')
assert(not get('inventory').visible and get('strike')==0)
frame();frame({[4]=true});assert(dialogue.page==1 and dialogue.revealed==dialogue.total)
frame({[4]=true});assert(dialogue.page==1,'Holding B advanced another page')
frame();frame({[4]=true});assert(dialogue.page==2)
frame();frame({[13]=true});assert(not dialogue.active and not get('inventory').visible,'A must cancel without opening inventory')
frame();frame({[4]=true});assert(dialogue.active and dialogue.page==1,'Inspection cannot be repeated')
frame();frame({[13]=true});frame()
position('sala',4,1.6);frame({[4]=true});assert(not dialogue.active and dialogue.toastTime>0,'Far-away inspection fired')
frame();frame({[13]=true});assert(get('inventory').visible,'Normal inventory stopped opening')
frame();frame({[13]=true});frame();assert(not get('inventory').visible)
position('cozinha',2.3,1.5);frame({[4]=true})
assert(get('inventory').collected.note and dialogue.toastTime>0 and not dialogue.active,'Document collection regressed')
print('Painting inspection, exact text, Unicode accents, B reveal/advance, held-button debounce, A cancellation, frozen movement, repeat inspection, inventory and collection OK')
