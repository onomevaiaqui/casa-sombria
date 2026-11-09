LEFT,RIGHT,UP,DOWN=0,1,2,3
package.preload.sprites=function()return dofile('.tools/sprites168.lua')end
package.preload.palette=function()return dofile('.tools/palette142.lua')end
local keys,labels,palette={}, {},{}
ui={cls=function()end,btn=function(i)return keys[i]or false end,stat=function()return 60 end,palset=function(i,v)palette[i]=v end,print=function(s)labels[#labels+1]=s end,rectfill=function()end,rect=function()end,line=function()end,trisfill=function()end,spr=function()end}
dofile('game.lua')
local function get(k)for i=1,100 do local n,v=debug.getupvalue(update,i);if n==k then return v,i end end;error(k)end
local function set(k,v)local _,i=get(k);debug.setupvalue(update,i,v)end
local I=get('inventory');I:open();assert(I.focus=='items'and #I.bag==3)
I:handle(false,false,false,false,false,'quarto',false,true);assert(I.tab==2)
I:handle(false,false,false,false,false,'quarto',false,true);assert(I.tab==2,'held R repeats')
I:handle(false,false,false,false,false,'quarto',false,false)
I:handle(false,false,false,false,false,'quarto',true,false);assert(I.tab==1)
I:handle(false,false,false,false,false,'quarto',false,false)
I:handle(false,false,true,false,false,'quarto',false,false);assert(I.tab==1,'dpad changes tabs')
I.previous={};I.selected=1;I:handle(false,false,false,false,true,'quarto');assert(I.mode=='actions')
I.action=3;I.previous={};I:handle(false,false,false,false,true,'quarto');assert(I.inspected and I.mode=='grid')
I.mode='actions';I:back();assert(I.visible and I.mode=='grid');I:back();assert(not I.visible)
I:collect({id='family_photo',document=true});I:open();I.tab=2;I.fileSelected=#I.files;I.previous={};I:handle(false,false,false,false,true,'quarto');assert(require('photo162').active)
require('photo162').reset();I:close();set('titleOpen',false);set('currentRoom','quarto');local M=require('metric_rooms');local x,y=M.project('quarto',1.05,1.25,0);set('x',x);set('y',y)
keys={[13]=true};update();assert(I.visible);keys={};update();keys={[15]=true};update();assert(I.tab==1,'right shoulder should change previous files tab to items')
keys={};update();keys={[14]=true};update();assert(I.tab==2,'left shoulder not routed')
-- UI only uses reserved colors, names stay short until inspection.
labels={};I.tab=1;I.inspected=false;I.message=nil;I:draw(dofile('.tools/palette142.lua'));local text=table.concat(labels,'|')
assert(not text:find('PERTENCES')and not text:find('ENTREGA PENDENTE'));assert(text:find('L/R: ABAS'))
for i=240,255 do assert(palette[i])end
collectgarbage('collect');local before=collectgarbage('count');local peak=before
for n=1,2000 do I.tab=n%2+1;I:draw(dofile('.tools/palette142.lua'));labels={};peak=math.max(peak,collectgarbage('count'))end
collectgarbage('collect');assert(collectgarbage('count')-before<16,'inventory retained memory')
print(string.format('PASS inventory tabs L/R edges, dpad, inspect, back, archive photo, reserved palette; stress peak %.1f KiB growth %.1f KiB',peak,collectgarbage('count')-before))
