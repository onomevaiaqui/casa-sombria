LEFT,RIGHT,UP,DOWN=0,1,2,3
package.preload.sprites=function()return dofile('.tools/sprites168.lua')end
package.preload.palette=function()return dofile('.tools/palette142.lua')end
local keys,palette,triangles={}, {},{};local calls=0
ui={cls=function()end,btn=function(i)return keys[i]or false end,stat=function()return 60 end,
 palset=function(i,v)palette[i]=v;calls=calls+1 end,print=function()end,rectfill=function()end,rect=function()end,line=function()end,spr=function()end,
 trisfill=function(...)triangles[#triangles+1]={...}end}
dofile('game.lua');require('crowbar160').cull=tonumber(arg[1])or 0
local function get(key)for i=1,100 do local n,v=debug.getupvalue(update,i);if n==key then return v,i end end;error(key)end
local function set(key,v)local _,i=get(key);debug.setupvalue(update,i,v)end
set('titleOpen',false);get('inventory').equipped='crowbar'
local file=assert(io.open(arg[2],'wb'));file:write('[');local frameCount,totalTriangles=0,0
local function draw()
 triangles={};update();if frameCount>0 then file:write(',')end;file:write('[[',table.concat((function()local a={};for i=0,255 do a[#a+1]=tostring(palette[i]or 0)end;return a end)(),','),'],[')
 for i,t in ipairs(triangles)do if i>1 then file:write(',')end;file:write('[',table.concat(t,','),']')end
 file:write(']]');frameCount=frameCount+1;totalTriangles=totalTriangles+#triangles
end
for frame=1,180 do
 if frame<=35 then keys={[1]=true,[12]=true}elseif frame<=55 then keys={[0]=true}elseif frame<=135 then keys={[15]=true};if frame==60 or frame==102 then keys[12]=true end else keys={}end
 draw()
end
local M=require('metric_rooms');local L=require('layout140')
local rooms={};for room in pairs(L.spawns)do rooms[#rooms+1]=room end;table.sort(rooms)
for _,room in ipairs(rooms)do local p=L.spawns[room];for angle=0,7 do
 keys={};local x,y=M.project(room,p[1],p[2],0);set('currentRoom',room);set('x',x);set('y',y);set('facing',angle*math.pi/4);set('crossing',false);set('transitionCarry',nil)
 draw()
end end
file:write(']');file:close();print('CORPUS',frameCount,'triangles',totalTriangles,'native palette calls',calls)
