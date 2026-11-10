local D=require('death171');local L=require('survival158')
local writes,prints,rects=0,{},0
local last
local overlay=false
local ui={palset=function(i,c)assert(c>=0 and c<=32767);if overlay then assert(i==240 or i==241,'death UI overwrites actor palette')end;last=c;writes=writes+1 end,
 rectfill=function()rects=rects+1 end,print=function(s)prints[#prints+1]=s end}
L.reset();for i=1,4 do L.damage()end
assert(L.dead and L.time==0)
local function frame(t)
 L.time=t;prints={};rects=0
 local set=D.palette(ui,L);set(1,32767);local shade=last
 overlay=true;D.draw(ui,L);overlay=false;return shade,table.concat(prints,'|')
end
local full,text=frame(0);assert(full==32767 and text=='')
local mid,falling=frame(.8);assert(mid<full and falling:find('V|O|C|E')and not falling:find('TENTAR'))
local dark,done=frame(L.clip.duration);assert(dark<mid and dark>0 and done:find('TENTAR NOVAMENTE')and done:find('MENU INICIAL'))
assert(rects==1,'unexpected full-screen graphics work')
assert(L.input(false,true)==nil,'held action skipped death')
L.input(false,false);assert(L.input(false,true)=='retry')
L.reset();assert(not L.dead and L.time==0)
L.hud(ui);assert(prints[#prints]=='VIDA 4/4')
-- A fixed-size palette operation, independent of screen resolution.
L.dead=true;L.time=1
collectgarbage('collect');local before=collectgarbage('count')
for n=1,5000 do local set=D.palette(ui,L);for i=0,255 do set(i,32767)end end
collectgarbage('collect');assert(collectgarbage('count')-before<8,'fade accumulates memory')
print('PASS death: title during fall, monotonic palette fade, visible background, delayed retry/menu, reset and bounded memory')
