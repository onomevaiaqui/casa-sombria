local cameraModuleCache=type(package)=='table'and package.loaded or nil
-- Load only one room; require cache is explicitly released on transitions.
local D={firstprefix={["area"]="q377_main_area_1_0",["banheiro"]="q377_main_banheiro_1_0",["corredor"]="q377_main_corredor_1_0",["cozinha"]="q377_main_cozinha_1_0",["ferramentas"]="q377_main_ferramentas_1_0",["frente"]="q377_main_frente_1_0",["garagem"]="q377_main_garagem_1_0",["quarto"]="q377_main_quarto_1_0",["quintal"]="q377_main_quintal_1_0",["sala"]="q377_main_sala_1_0"}}
local current,views
setmetatable(D,{__index=function(_,room)
 if room==current then return views end
 if not D.firstprefix[room]then return nil end
 if D.beforeChange then D.beforeChange()end
 views=nil;current=nil;require('memory168').release();collectgarbage('collect')
 local name='camera_mem168_'..room
 local factory=require(name)
 local loaded=factory()
 -- The physical Lupi sandbox does not expose the package global.
 if cameraModuleCache then cameraModuleCache[name]=nil end
 current,views=room,loaded
 return views
end})
function D.release()current,views=nil,nil;require('memory168').release()end
return D
