LEFT,RIGHT,UP,DOWN=0,1,2,3
package.preload.sprites=function()return dofile('.tools/sprites168.lua')end
package.preload.palette=function()return dofile('.tools/palette142.lua')end
local writes=0
local keys={}
ui={cls=function()end,btn=function(i)return keys[i]or false end,stat=function()return 60 end,
 palset=function()writes=writes+1 end,print=function()end,rectfill=function()end,rect=function()end,line=function()end,spr=function()end,trisfill=function()end}
dofile('game.lua');require('gc150').configure(arg[1]or 'generational')
local function get(key)for i=1,100 do local n,v=debug.getupvalue(update,i);if n==key then return v,i end end;error(key)end
local _,index=get('titleOpen');debug.setupvalue(update,index,false);get('inventory').equipped='crowbar'
for i=1,30 do update()end
collectgarbage('collect');local low=collectgarbage('count');local peak=low
local started=os.clock();local maximum=0
for i=1,10000 do
 local tick=os.clock()
 keys={[15]=true,[12]=(i%45==1)};update()
 peak=math.max(peak,collectgarbage('count'));maximum=math.max(maximum,os.clock()-tick)
end
collectgarbage('collect');local after=collectgarbage('count')
assert(after<low+128,'combat retains memory: '..(after-low))
assert(peak<4096,'Lua heap exceeds stress budget: '..peak)
print(string.format('PASS 10000 combat updates, GC active: peak %.1f KB, retained growth %.1f KB',peak,after-low))

print(string.format('GC %s: %.4fs CPU total, %.3fms worst desktop update; API %s',require('gc150').mode,os.clock()-started,maximum*1000,require('gc150').api))
