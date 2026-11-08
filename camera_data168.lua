-- Load only one room; require cache is explicitly released on transitions.
local D={firstprefix={["area"]="scene158_area_0_0",["sala"]="scene168_sala_0_0",["banheiro"]="scene158_banheiro_0_0",["quintal"]="scene158_quintal_0_0",["corredor"]="scene158_corredor_0_0",["quarto"]="scene158_quarto_0_0",["garagem"]="scene158_garagem_0_0",["ferramentas"]="scene158_ferramentas_0_0",["frente"]="scene158_frente_0_0",["cozinha"]="scene168_cozinha_0_0"}}
local current,views
setmetatable(D,{__index=function(_,room)
 if room==current then return views end
 if not D.firstprefix[room]then return nil end
 views=nil;current=nil;collectgarbage('collect')
 local name='camera_mem168_'..room
 local loaded=require(name)
 -- The physical Lupi sandbox does not expose the package global.
 if type(package)=='table'and type(package.loaded)=='table'then package.loaded[name]=nil end
 current,views=room,loaded
 return views
end})
return D
