local M=require('metric_rooms')
local master={};for i,pair in ipairs(M.bank)do master[i]=pair[1]end
local screen={}
for _,room in ipairs({'sala','cozinha','banheiro','garagem','quarto','corredor','frente','quintal','sala'})do
 -- Inventory/title may restore the master palette while the room is paused.
 for i,color in ipairs(master)do screen[i-1]=color end
 local count=0
 M.applyPalette(master,function(index,color)
  assert(index<224,'Room palette overwrites character colours')
  screen[index]=color;count=count+1
 end,room)
 assert(count==191,'Incomplete bank')
 for i,pair in ipairs(M.banks[room])do assert(screen[i-1]==pair[2],room..' wrong palette after switching rooms')end
end
print('All eight 191-colour banks restore correctly after room/inventory changes; character indices preserved')
