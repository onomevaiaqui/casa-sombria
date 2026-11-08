LEFT,RIGHT,UP,DOWN=0,1,2,3
package.preload.sprites=function()return dofile('.tools/sprites168.lua')end
package.preload.palette=function()return dofile('.tools/palette142.lua')end
local writes=0
ui={cls=function()end,btn=function()return false end,stat=function()return 60 end,
 palset=function()writes=writes+1 end,print=function()end,rectfill=function()end,rect=function()end,line=function()end,spr=function()end,trisfill=function()end}
dofile('game.lua')
local function get(key)for i=1,100 do local n,v=debug.getupvalue(update,i);if n==key then return v,i end end;error(key)end
local _,index=get('titleOpen');debug.setupvalue(update,index,false);get('inventory').equipped='crowbar'
for i=1,30 do update()end
writes=0;collectgarbage('collect');local start=os.clock()
for i=1,1000 do update()end
print(string.format('Desktop Lua idle 1000 updates %.4fs; native palset calls %d (not hardware FPS)',os.clock()-start,writes))
