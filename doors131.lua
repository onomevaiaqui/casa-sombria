-- One shared state per physical door, regardless of the side used to open it.
local D={opened={}}
D.list={{["id"]='quarto',["label"]='QUARTO',["bit"]=1,["asset"]=4,["hinge"]={8.5,4.828},["closed"]=0,["open"]=180,["ends"]={["corredor"]={["x"]=4.1,["y"]=1.8,["axis"]=2},["quarto"]={["x"]=1.7,["y"]=0,["axis"]=2}}},{["id"]='banheiro',["label"]='BANHEIRO',["bit"]=2,["asset"]=4,["hinge"]={5.6,4.828},["closed"]=0,["open"]=180,["ends"]={["corredor"]={["x"]=1.2,["y"]=1.8,["axis"]=2},["banheiro"]={["x"]=1.2,["y"]=0,["axis"]=2}}},{["id"]='entrada',["label"]='ENTRADA',["bit"]=4,["asset"]=8,["hinge"]={2.9,0.028},["closed"]=0,["open"]=180,["ends"]={["sala"]={["x"]=3.3,["y"]=0,["axis"]=2},["area"]={["x"]=1.5,["y"]=1.5,["axis"]=2}}},{["id"]='garagem',["label"]='GARAGEM',["bit"]=8,["asset"]=4,["hinge"]={5.6,2.972},["closed"]=0,["open"]=180,["ends"]={["corredor"]={["x"]=1.2,["y"]=0,["axis"]=2},["garagem"]={["x"]=1.2,["y"]=5.7,["axis"]=2}}},{["id"]='cozinha_quintal',["label"]='COZINHA_QUINTAL',["bit"]=16,["asset"]=4,["hinge"]={0.028,5.9},["closed"]=90,["open"]=-90,["ends"]={["cozinha"]={["x"]=0,["y"]=1.5,["axis"]=1},["quintal"]={["x"]=6.4,["y"]=4.3,["axis"]=1}}},{["id"]='corredor',["label"]='CORREDOR',["bit"]=32,["asset"]=4,["hinge"]={4.8,3.6},["closed"]=90,["open"]=0,["ends"]={["sala"]={["x"]=4.8,["y"]=4,["axis"]=1},["corredor"]={["x"]=0,["y"]=1,["axis"]=1}},["openBoxes"]={["corredor"]={0,0.8,0.58,0.62}}}}
table.insert(D.list,{id='jardim_quintal',label='PORTAO DO QUINTAL',bit=64,asset=0,hinge={-2.1,0},closed=0,open=90,ends={frente={x=4.8,y=8.6,axis=2},quintal={x=4.8,y=0,axis=2}},openBoxes={quintal={4.27,4.33,0,1}}})
D.list[5].ends.quintal.y=6.3
table.insert(D.list,{id='casinha',label='CASINHA DE FERRAMENTAS',bit=128,asset=0,hinge={-5.05,6.5},closed=0,open=-95,ends={quintal={x=1.8,y=6.5,axis=2},ferramentas={x=1.5,y=0,axis=2}},openBoxes={quintal={1.23,1.4,5.6,6.5}}})
function D.reset()D.opened={}end
function D.open(id)D.opened[id]=true end
function D.isOpen(id)return not not D.opened[id]end
function D.forPassage(room,to)
 for _,door in ipairs(D.list)do if door.ends[room]and door.ends[to]then return door end end
end
function D.blocked(room,to)
 local door=D.forPassage(room,to)
 return door and not D.isOpen(door.id)
end
function D.nearby(room,x,y)
 local best,distance
 for _,door in ipairs(D.list)do
  local p=door.ends[room]
  if p and not D.isOpen(door.id)then
   local normal=math.abs((p.axis==1 and x-p.x)or y-p.y)
   local lateral=math.abs((p.axis==1 and y-p.y)or x-p.x)
   if normal<=.85 and lateral<=.58 then
    local d=normal*normal+lateral*lateral
    if not distance or d<distance then best,distance=door,d end
   end
  end
 end
 return best
end
function D.stateMask(bits)
 local mask=0
 for _,bit in ipairs(bits)do for _,door in ipairs(D.list)do if door.bit==bit and D.isOpen(door.id)then mask=mask+bit end end end
 return mask
end
local function clear(box,x,y)
 local nx,ny=math.max(box[1],math.min(box[2],x)),math.max(box[3],math.min(box[4],y))
 return(x-nx)^2+(y-ny)^2>=.25*.25-1e-9
end
function D.walkable(room,x,y)
 for _,door in ipairs(D.list)do local box=door.openBoxes and door.openBoxes[room]
  if box and D.isOpen(door.id)and not clear(box,x,y)then return false end
 end
 return true
end
function D.canOpen(id,room,x,y)
 for _,door in ipairs(D.list)do if door.id==id then local box=door.openBoxes and door.openBoxes[room];return not box or clear(box,x,y)end end
 return false
end
return D
