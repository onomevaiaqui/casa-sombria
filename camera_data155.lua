-- Load only one room; require cache is explicitly released on transitions.
local D={firstprefix={["ferramentas"]="scene155_ferramentas_0_0",["sala"]="scene155_sala_0_0",["quarto"]="scene155_quarto_0_0",["area"]="scene155_area_0_0",["frente"]="scene155_frente_0_0",["cozinha"]="scene155_cozinha_0_0",["garagem"]="scene155_garagem_0_0",["corredor"]="scene155_corredor_0_0",["quintal"]="scene155_quintal_0_0",["banheiro"]="scene155_banheiro_0_0"}}
local current,views
setmetatable(D,{__index=function(_,room)
 if room==current then return views end
 if not D.firstprefix[room]then return nil end
 views=nil;current=nil;collectgarbage('collect')
 local name='camera_mem165_'..room
 local loaded=require(name);package.loaded[name]=nil
 current,views=room,loaded
 return views
end})
return D
