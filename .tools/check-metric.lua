local M=require('metric_rooms')
local P=require('perspective')
local function close(a,b)assert(math.abs(a-b)<1e-7,tostring(a)..' != '..tostring(b))end
for _,entry in ipairs({{'banheiro',1.25,1.65},{'banheiro',1.30,2.3},{'garagem',2.3,1.35},{'garagem',2.3,4.9}})do
 local room,gx,gy=table.unpack(entry)
 local x,y=M.project(room,gx,gy,0)
 local a,b=M.ground(room,x,y);close(a,gx);close(b,gy)
 local hx,hy=M.project(room,gx,gy,1.8)
 local v=P.vertex(room,x,y,0,1.852,0,0)
 assert(math.abs(v[1]-hx)<=.51 and math.abs(v[2]-hy)<=.51,'actor does not match offline camera')
 assert(M.walkable(room,x,y),'metric spawn not walkable')
end
for _,entry in ipairs({{'banheiro',.5,2.4},{'banheiro',1.85,2.5},{'banheiro',2.1,1.5},{'garagem',1.1,3},{'garagem',3.1,3.5}})do
 local room,x,y=table.unpack(entry);local sx,sy=M.project(room,x,y,0)
 assert(not M.walkable(room,sx,sy),'fixture collision missing')
end
local x,y=M.project('garagem',2.3,5.35,0)
assert(M.walkable('garagem',x,y))
assert(M.inOpening('garagem',x,y,{2.1,2.85,5.25,5.48,1}))
local master,seen={},{}
for i,entry in ipairs(M.bank)do master[i]=entry[1] end
M.applyPalette(master,function(index,color)
 assert(index<224,'background overwrites character palette')
 assert(color==M.bank[index+1][2],'incorrect palette bank color')
 seen[index]=true
end)
local count=0;for _ in pairs(seen)do count=count+1 end
assert(count==191,'incomplete palette bank')
print('Exact Blender camera projection, 1.80m mesh, fixture collisions, metric portals and 191-color palette bank OK')
