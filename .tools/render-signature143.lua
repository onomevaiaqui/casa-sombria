LEFT,RIGHT,UP,DOWN=0,1,2,3
package.preload.sprites=function()return dofile('.tools/sprites168.lua')end
package.preload.palette=function()return dofile('.tools/palette142.lua')end
local keys={};local hash,count=1,0
ui={cls=function()end,btn=function(i)return keys[i]or false end,stat=function()return 60 end,
 palset=function()end,print=function()end,rectfill=function()end,rect=function()end,line=function()end,spr=function()end,
 trisfill=function(...)for _,v in ipairs({...})do hash=(hash*31+math.floor(v))%2147483647 end;count=count+1 end}
dofile('game.lua')
local function get(key)for i=1,100 do local n,v=debug.getupvalue(update,i);if n==key then return v,i end end;error(key)end
local function set(key,v)local _,i=get(key);debug.setupvalue(update,i,v)end
set('titleOpen',false);get('inventory').equipped='crowbar'
for frame=1,180 do
 if frame<=35 then keys={[1]=true,[12]=true}
 elseif frame<=55 then keys={[0]=true}
 elseif frame<=135 then keys={[15]=true};if frame==60 or frame==102 then keys[12]=true end
 else keys={}end
 update()
end
print(hash,count)
