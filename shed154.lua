local S={}
function S.tryOpen(inventory,doors,room,x,y)
 if room and not doors.canOpen("casinha",room,x,y)then return false,{"Afaste-se um pouco da porta."}end
 if not inventory:has('shed_key')then return false,{'Está trancada com um cadeado.','Preciso encontrar a chave.'}end
 doors.open('casinha');return true,{'A chave encaixou no cadeado.','Agora posso entrar.'}
end
return S
